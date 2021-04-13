//
//  ASSFTransactionsViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 10/08/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ASSFTransactionsViewController: UIViewController {
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var labelMessage: UILabel!
    
    
    var transactionHistoryFiltered = [TransactionHistory]()
    var group_transaction = [[TransactionHistory]]()
    var  headerheight: CGFloat = 44
    var select_transaction: [TransactionHistory] = []
    
    var wallet_id = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableview.delegate = self
        tableview.dataSource = self
        
        tableview.rowHeight = 60
        
        for i in accountArray {
            if i.currency == "NGN" {
                wallet_id = i.wallet_uid
            }
        }
        
        networkCall()
    }
    
    //MARK: Grouping Transaction History
    fileprivate func attemptToGroup () {
        
        let groupedMessages = Dictionary(grouping: transactionHistoryFiltered) { (elem) -> Date in
            let date = Date.dateFromCustom(customString: elem.date)
            return date
        }
        
        //provide sorting for keys
        let sortedKeys = groupedMessages.keys.sorted().reversed()
        sortedKeys.forEach { (key) in
            let values = groupedMessages[key]
            self.group_transaction.append(values ?? [])
        }
        
        tableview.reloadData()
    }
    
    
    
    //MARK: Make network request
    func networkCall() {
        
        activityIndicator.startAnimating()
        
        
        let utililty = UtilClass()
        let device = utililty.getPhoneId()
        
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        let date = Date()
        
        let five_months_ago = date.addMonth(n: -5)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let converted_current_date = dateFormatter.string(from: date)
        let converted_months_ago = dateFormatter.string(from: five_months_ago)
        
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "SessionID": session, "CustomerID": customer_id, "wallet": wallet_id, "dateFrom": converted_months_ago, "dateTo": converted_current_date, "page": "1", "pageLimit": "50", "AgentID": agentIDFromReg]
        
        print(params)
        
        
        utililty.delayToNextPage(params: params, path: "agent_transactions") { result in
            switch result {
            case .failure(let error):
                self.activityIndicator.stopAnimating()
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Please check that you have internet connection")
                self.present(alertVC, animated: true)
                print(error)
                break
                
            case .success:
                
                let data: JSON = JSON(result.value!)
                
                //****Decode json hear****/
                let hexKey = data["reqResponse"].stringValue
                //******Import  and initialize Util Class*****////
                
                //********decripting Hex key**********//
                let decriptor = utililty.convertHexStringToString(text: hexKey)
                
                //**********Changing Data back to Json format***///
                let jsonData = decriptor.data(using: .utf8)!
                
                
                let decriptorJson: JSON = JSON(jsonData)
                print(decriptorJson)
                
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                let response = decriptorJson["response"].arrayValue.count
                
                if(status) {
                    if response == 0 {
                        self.labelMessage.isHidden = false
                        self.labelMessage.text = message
                    }
                    else {
                        
                        self.transactionHistoryFiltered = [TransactionHistory]()
                        for i in decriptorJson["response"].arrayValue {
                            
                            let history = TransactionHistory()
                            
                            history.amount = i["amount"].stringValue
                            history.memo = i["memo"].stringValue
                            history.method = i["method"].stringValue
                            history.currency = i["currency"].stringValue
                            history.type = i["type"].stringValue
                            history.tx = i["tx"].stringValue
                            
                            let date = i["date"].stringValue
                            let new_date = date.split(separator: " ")
                            history.date = String(new_date[0])
                            //print( String(new_date[0]) )
                            self.transactionHistoryFiltered.append(history)
                            self.activityIndicator.stopAnimating()
                            
                        }
                    }
                    
                }
                    
                else if (message == "Session has expired") {
                    self.activityIndicator.stopAnimating()
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.activityIndicator.stopAnimating()
                    
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
                break
            }
            self.tableview.reloadData()
            self.attemptToGroup()
        }
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
}


//MARK: - TRANSACTION HISTORY
extension ASSFTransactionsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //print("\(group_transaction.count) ... from line 897")
        return group_transaction.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //            print("\(group_transaction[section].count)....from line 892")
        
        //MARK: THIS IS WHERE THE PROBLEM OCCURS
        return group_transaction[section].count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath) as! TransactionHistoryCellTableViewCell
        
        //******Remove styling from selected cell
        cell.selectionStyle = .none
        
        let cell_dictionary = group_transaction[indexPath.section][indexPath.row]
        
        let myAttribute = [NSAttributedString.Key.font: UIFont(name: "Muli-Bold", size: 17.0)!]
        let attributCurrency = NSMutableAttributedString(string: cell_dictionary.currency)
        
        let myAttrString = NSAttributedString(string: cell_dictionary.amount, attributes: myAttribute)
        
        //        let space = NSAttributedString(string: " ")
        //
        //        attributCurrency.append(space)
        attributCurrency.append(myAttrString)
        
        cell.sideLable.attributedText = attributCurrency
        
        let splited_memo = cell_dictionary.memo.split(separator: "/")
        
        //cell.imageView?.image = UIImage(named: "watch")
        cell.headerLabel.text = String(splited_memo.first ?? "")
        
        cell.bodyLabel.text = cell_dictionary.tx
        
        
        if String(splited_memo.first ?? "") == "TRF" {
            cell.transactionImage.image = UIImage(named: "transfer")
            
        }
            
        else if String(splited_memo.first ?? "") == "NIP transfer fee" {
            cell.transactionImage.image = UIImage(named: "transfer")
            
        }
            
        else if String(splited_memo.first ?? "") == "Data" {
            cell.transactionImage.image = UIImage(named: "topup")
        }
            
        else if String(splited_memo.first ?? "") == "Airtime" {
            cell.transactionImage.image = UIImage(named: "topup")
        }
            
            
        else if String(splited_memo.first ?? "") == "Wallet Funding" {
            cell.transactionImage.image = UIImage(named: "utility_bill1")
        }
            
        else {
            cell.transactionImage.image = UIImage(named: "utility_bill")
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerheight
    }
    
    //MARK: Header view representation
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = Bundle.main.loadNibNamed("HeaderViewTableViewCell", owner: self, options: nil)?.first as! HeaderViewTableViewCell
        
        let groupHeader = group_transaction[section].first
        
        if let firstDate = groupHeader {
            
            
            print(type(of: firstDate.date))
            print(firstDate.date)
            let date = Date.dateFromCustom(customString: firstDate.date)
            let customDate = Date.dateFormaterMonth(date: date)
            let split_date = customDate.split(separator: " ")
            
            headerView.dateOutlet.text = "\(String(Int(split_date[0])!.ordinal)) \(split_date[1])"
            
        }
        
        return headerView
    }
    
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        select_transaction = [group_transaction[indexPath.section][indexPath.row]]
//        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "transaction") as? TransactionDetailsViewController
//        
//        vc?.transaction_histrory_detail = select_transaction
//        self.navigationController?.pushViewController(vc!, animated: true)
//    }
}




