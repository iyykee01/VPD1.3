//
//  CashboxBalanceViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 12/12/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


protocol seguePerformBackwards {
    func goBack()
}

class CashboxBalanceViewController: UIViewController, seguePerform {
    
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var card_blance: UILabel!
    @IBOutlet weak var mature_funds: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var transactionTableView: UITableView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var transferButtonOutlet: DesignableButton!
    
    var wallet_id = currentWalletSelected["walletId"]
    
    var  headerheight: CGFloat = 44
    
    
    var delegate: seguePerformBackwards?
    
    var transction_history = [TransactionHistory]()
    
    var group_transaction2 = [[TransactionHistory]]()
    var no_record = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        validateAPI()
        transactionTableView.rowHeight = 80
        transactionTableView.delegate = self
        transactionTableView.dataSource = self
        
        errorLabel.isHidden = true
        transferButtonOutlet.isHidden = true
        
        
    }
    
    
    //MARK: - Validate Bank Acount************************
    func validateAPI(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        
        //******getting parameter from string
        let params = [
            "AppID":device.sha512,
            "language":"en",
            "RequestID": timeInSecondsToString,
            "SessionID": session,
            "CustomerID": customer_id,
            "wallet": wallet_id
        ]
        
        
        
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
        
        
        
        let url = "\(utililty.url)cashbox"
        
        postForValidate(url: url, parameter: parameter, token: token, header: headers)
    }
    
    
    // MARK: - NETWORK CALL- Post TO LIST OF BANKs
    func postForValidate(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        self.activityIndicator.startAnimating()
        
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
                
                
                if(status) {
                    
                    self.activityIndicator.stopAnimating()
                    self.balance.text = "N\(decriptorJson["response"]["total"].stringValue)"
                    self.card_blance.text = "N\(decriptorJson["response"]["total"].stringValue)"
                    self.mature_funds.text = "N\(decriptorJson["response"]["matured"].stringValue)"
                    
                    if decriptorJson["response"]["matured"].stringValue != "0.00" {
                        self.transferButtonOutlet.isHidden = false
                    }
                    
                    self.callTransactionApi()
                }
                    
                    
                else if (message == "Session has expired") {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    
                    self.activityIndicator.stopAnimating()
                    let alertService = AlertService()
                    let alertVC =  alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                
                self.activityIndicator.stopAnimating()
                let alertService = AlertService()
                let alertVC =  alertService.alert(alertMessage: "Network Error")
                self.present(alertVC, animated: true)
                
            }
            
        }
    }
    
    
    
    
    //MARK: Grouping Transaction History
    fileprivate func attemptToGroup () {
        
        let groupedMessages = Dictionary(grouping: transction_history) { (elem) -> Date in
            let date = Date.dateFromCustom(customString: elem.date)
            return date
        }
        
        //provide sorting for keys
        let sortedKeys = groupedMessages.keys.sorted().reversed()
        sortedKeys.forEach { (key) in
            let values = groupedMessages[key]
            group_transaction2.append(values ?? [])
        }
        
    }
    
    
    //MARK: Transaction API HERE(Transaction History)************************
    //++++++=========Delay function @if token is true move to next page+++++++===========//
    func callTransactionApi(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        
        let now = NSDate()
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
        
        let five_months_ago = formatter.string(from: date.getPreviousMonth()!)
        let today = formatter.string(from: now as Date)
        //let five_day_ago = formatter.string(from: Date.yesterday as Date)
        
        print(five_months_ago)
        
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "SessionID": session, "CustomerID": customer_id, "dateFrom": five_months_ago, "dateTo": today, "page": "1", "pageLimit": "20", "wallet": wallet_id]
        
        // print(params)
        
        let jsonEncode = JSONEncoder()
        let jsonData = try! jsonEncode.encode(params)
        let json = String(data: jsonData, encoding: .utf8)!
        
        
        ///*********converting shaDeivcepptiies to hexString*********////////
        /////*********converting shaDeivcepptiies to hexString*********////////
        let hexShaDevicePpties = utililty.convertToHexString(json)
        //print(hexShaDevicePpties)
        
        
        let parameter = ["reqData": hexShaDevicePpties]
        let token = UserDefaults.standard.string(forKey: "Token")!
        let headers: HTTPHeaders = ["X-Authorization": token, "AppGroup": "IOS"]
        
        
        
        let url = "\(utililty.url)cashbox_transactions"
        
        postToTransactionHistory(url: url, parameter: parameter, token: token, header: headers)
    }
    
    
    
    
    // MARK: - NETWORK CALL- Post TO Transanction History
    func postToTransactionHistory(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
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
                //print(decriptorJson)
                
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                
                
                if(status) {
                    self.transction_history = [TransactionHistory]()
                    self.no_record = message
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
                        self.transction_history.append(history)
                        
                       
                    }
                }
                    
                else if (message == "Session has expired") {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    let alertService = AlertService()
                    let alertVC =  alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                let alertService = AlertService()
                let alertVC =  alertService.alert(alertMessage: "Network Error")
                self.present(alertVC, animated: true)
            }
            self.attemptToGroup()
            self.transactionTableView.reloadData()
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        delegate?.goBack()
        navigationController?.popViewController(animated: true)
    }
    
    //Delegate method here
    func goNext(next: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let alertSV = SuccessAlertTransaction()
            let alert = alertSV.alert(success_message: next) {
                
            }
            self.present(alert, animated: true)
            
        }
        navigationController?.popViewController(animated: true)
    }
    
    
    
    @IBAction func moreButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToSearch", sender: self)
    }
    
    @IBAction func transferButtonPressed(_ sender: Any) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToSearch" {
            let destination = segue.destination as! DateSearchViewController
            destination.from_segue = "cashbox"
        }
        
        if segue.identifier == "goToPopup" {
            
            let destination = segue.destination as! CashboxPopupViewController
            destination.wallet_uid = wallet_id!
            destination.delegate = self
        }
        
    }
}


//MARK: - TRANSACTION HISTORY
//MARK: Extension for UI Table View and Delegate for transaction History
extension CashboxBalanceViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return group_transaction2.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("\(group_transaction[section].count)....from line 892")
        
        //MARK: THIS IS WHERE THE PROBLEM OCCURS
        return group_transaction2[section].count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath) as! TransactionTableViewCell
        
        print(transction_history.count)
        //******Remove styling from selected cell
        cell.selectionStyle = .none
        
        if transction_history.count == 0 {
            errorLabel.isHidden = false
            errorLabel.text = no_record
        }
        
        let cell_dictionary = group_transaction2[indexPath.section][indexPath.row]
        
        let myAttribute = [NSAttributedString.Key.font: UIFont(name: "Muli-Bold", size: 17.0)!]
        let attributCurrency = NSMutableAttributedString(string: cell_dictionary.currency)
        
        let myAttrString = NSAttributedString(string: cell_dictionary.amount, attributes: myAttribute)
        
        //        let space = NSAttributedString(string: " ")
        //
        //        attributCurrency.append(space)
        attributCurrency.append(myAttrString)
        
        cell.amount.attributedText = attributCurrency
        
        let splited_memo = cell_dictionary.memo.split(separator: "/")
        
        //cell.imageView?.image = UIImage(named: "watch")
        cell.memo.text = String(splited_memo.first ?? "")
        
        cell.trasaction_id.text = cell_dictionary.tx
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerheight
    }
    
    //MARK: Header view representation
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = Bundle.main.loadNibNamed("HeaderViewTableViewCell", owner: self, options: nil)?.first as! HeaderViewTableViewCell
        
        let groupHeader = group_transaction2[section].first
        
        if let firstDate = groupHeader {
            
            
            let date = Date.dateFromCustom(customString: firstDate.date)
            let customDate = Date.dateFormaterMonth(date: date)
            let split_date = customDate.split(separator: " ")
            
            headerView.dateOutlet.text = "\(String(Int(split_date[0])!.ordinal)) \(split_date[1])"
            
        }
        
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("nill")
        //performSegue(withIdentifier: "goToTrasactionDetails", sender: self)
    }
}
 

extension Date {
    func getNextMonth() -> Date? {
        return Calendar.current.date(byAdding: .month, value: 1, to: self)
    }

    func getPreviousMonth() -> Date? {
        return Calendar.current.date(byAdding: .month, value: -5, to: self)
    }
}




