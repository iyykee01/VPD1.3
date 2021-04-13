//
//  TransactionHistorySearchViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 04/11/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class TransactionHistorySearchViewController: UIViewController {
    
    
    var transactionHistoryFiltered = [TransactionHistory]()
    var group_transaction = [[TransactionHistory]]()
    var  headerheight: CGFloat = 44
    
    var converted_firstDate = ""
    var converted_lastDate = ""
    var message = ""
    
    
    var select_transaction: [TransactionHistory] = []
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var labelMessage: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = 60
        
        //print(transactionHistoryFiltered.count, type(of: transactionHistoryFiltered))
        self.callTransactionApi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
        }
        
    }
    
    
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
        
        tableView.reloadData()
    }
    
    //MARK: - Delay function @if token is true move to next //
    func callTransactionApi(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "SessionID": session, "CustomerID": customer_id, "dateFrom": converted_firstDate, "dateTo": converted_lastDate, "page": "1", "pageLimit": "20"]
        
       // print(params)
        
        let jsonEncode = JSONEncoder()
        let jsonData = try! jsonEncode.encode(params)
        let json = String(data: jsonData, encoding: .utf8)!
        
        
        ///*********converting shaDeivcepptiies to hexString*********////////
        /////*********converting shaDeivcepptiies to hexString*********////////
        let hexShaDevicePpties = utililty.convertToHexString(json)
        print(hexShaDevicePpties)
        
        
        let parameter = ["reqData": hexShaDevicePpties]
        let token = UserDefaults.standard.string(forKey: "Token")!
        let headers: HTTPHeaders = ["X-Authorization": token, "AppGroup": "IOS"]
        
     
        
        let url = "\(utililty.url)transaction_history"
        
        postToTransactionHistory(url: url, parameter: parameter, token: token, header: headers)
    }
    
    // MARK: -NETWORK CALL- Post TO Transanction History
    func postToTransactionHistory(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//
//            // should segue only when animation is done
//            let loader = LoaderPopup()
//            let loaderVC = loader.Loader()
//            self.present(loaderVC, animated: true)
//        }
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        
        Alamofire.request(url, method: .post, parameters: parameter, headers: header).responseJSON {
            response in
            if response.result.isSuccess {
                //print("SUCCESSFUL.....")
                
                //******Getting Data******//
                let data: JSON = JSON(response.result.value!)
                
                //****Decode json hear****/
                let hexKey = data["reqResponse"].stringValue
                
                /******Import  and initialize Util Class*****////
                let utililty = UtilClass()
                
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
                            self.message = message
                            
                        }
                        
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.activityIndicator.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                    }
                    
                }
                    
                 else if message == "Session has expired" {
                    self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.message = message
                    self.activityIndicator.stopAnimating()
                    let alertService = AlertService()
                    let alertVC =  alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                let alertService = AlertService()
                let alertVC =  alertService.alert(alertMessage: "Network Error")
                self.present(alertVC, animated: true)
            }
            self.tableView.reloadData()
            self.attemptToGroup()
        }
    }
    

 
    @IBAction func goBackPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToTransactionDetails" {
            let destination = segue.destination as! TransactionDetailsViewController
            destination.transaction_histrory_detail = select_transaction
        }
        
    }
    
}

extension TransactionHistorySearchViewController:  UITableViewDelegate, UITableViewDataSource  {

  
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
        
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            select_transaction = [group_transaction[indexPath.section][indexPath.row]]
            performSegue(withIdentifier: "goToTransactionDetails", sender: self)
        }
}
