//
//  TransactionDetailsViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 03/11/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class TransactionDetailsViewController: UIViewController {
    
    var transaction_histrory_detail = [TransactionHistory]()
    
    @IBOutlet weak var transactionStatus: UILabel!
    @IBOutlet weak var time_date: UILabel!
    @IBOutlet weak var transaction_type: UILabel!
    @IBOutlet weak var references: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var sender: UILabel!

    @IBOutlet weak var remark: UILabel!
    @IBOutlet weak var account_number: UILabel!
    @IBOutlet weak var receivers_name: UILabel!
    
   
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var button_to_hide: DesignableButton!
    
    @IBOutlet weak var problemLabel: UILabel!
    @IBOutlet weak var AccountNumberToHide: UILabel!
    @IBOutlet weak var recieverNameToHide: UILabel!
    @IBOutlet weak var accountNumberStack: UIStackView!
    @IBOutlet weak var accountNumberStackHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var accountNumberStackTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var accountNumbeStackBottomConstraint: NSLayoutConstraint!
    
    
    let yourAttributes : [NSAttributedString.Key: Any] = [
    NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
    NSAttributedString.Key.foregroundColor : UIColor(hexFromString: "#34B5CE"),
    NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        // views to hide
        for i in transaction_histrory_detail {
            transactionStatus.text = i.status
            time_date.text = i.date
            transaction_type.text = i.type
            references.text = i.tx
            amount.text = i.amount
            sender.text = i.sender
            remark.text = i.memo
            receivers_name.text = i.receiver
            
            if i.account_number != "" {
                let full_account_number = i.account_number
                let first_three_numbers = full_account_number.substring(toIndex: full_account_number.length - 7)
                
                let astrix = "******"
                let last_2_numbers = full_account_number.substring(fromIndex: 8)
                account_number.text = "\(first_three_numbers)\(astrix)\(last_2_numbers)"
                
            }
            
            if i.account_number == "" {
                account_number.isHidden = true
                AccountNumberToHide.isHidden = true
                accountNumberStack.isHidden = true
                accountNumberStackHeightConstraint.constant = 0
                accountNumberStackTopConstraint.constant = 0
                accountNumbeStackBottomConstraint.constant = 0
            }
            
            if i.receiver == "" {
                recieverNameToHide.isHidden = true
                receivers_name.isHidden = true
            }
        }

    }
    
    
    //MARK: This will post the data to Make Payment
       func makeAPIcallGenerateReciept(){
        
           /******Import  and initialize Util Class*****////
           let utililty = UtilClass()
           
           let device = utililty.getPhoneId()
           
           //print("shaDevicePpties")
           let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
           let timeInSecondsToString = String(timeInSeconds)
           
           let session = UserDefaults.standard.string(forKey: "SessionID")!
           let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
           
           //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "operation": "receipt", " TransactionID": transaction_histrory_detail[0].tx]
           
           
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
           
           postData2(url: url, parameter: parameter, token: token, header: headers)
       }
       
       ///////////***********Post Data MEthod*********////////
       func postData2(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        self.activityIndicator.startAnimating()
        self.button_to_hide.isHidden = true
        self.view.isUserInteractionEnabled = false
           
           Alamofire.request(url, method: .post, parameters: parameter, headers: header).responseJSON {
               response in
               if response.result.isSuccess {
                   print("SUCCESSFUL.....")
                   
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
                   self.button_to_hide.isHidden = false
                   
                   if(status) {
                       self.activityIndicator.stopAnimating()
                       self.view.isUserInteractionEnabled = true
                      
                       let alertSV = SuccessAlertTransaction()
                       let alert = alertSV.alert(success_message: message) {
                           guard let VCS = self.navigationController?.viewControllers else {return }
                           for controller in VCS {
                               if controller.isKind(of: TabBarViewController.self) {
                                   let tabVC = controller as! TabBarViewController
                                   tabVC.selectedIndex = 0
                                   self.navigationController?.popToViewController(ofClass: TabBarViewController.self, animated: true)
                                   
                               }
                           }
                       }
                       self.present(alert, animated: true)
                   }
                   
                   else if  message == "Session has expired" {
                       self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                   }
                       
                   else {
                       self.activityIndicator.stopAnimating()
                       self.view.isUserInteractionEnabled = true
                       ////From the alert Service
                       let alertService = AlertService()
                       let alertVC = alertService.alert(alertMessage: message)
                       self.present(alertVC, animated: true)
                   }
               }
               else {
                   self.activityIndicator.stopAnimating()
                   self.view.isUserInteractionEnabled = true
                   ////From the alert Service
                   let alertService = AlertService()
                   let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                   self.present(alertVC, animated: true)
               }
           }
       }

    @IBAction func generateRecieptButtonPressed(_ sender: Any) {
        makeAPIcallGenerateReciept()
    }
    
    @IBAction func goBackButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        
    }
    
}

extension String {

    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}

