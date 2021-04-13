//
//  JustAMomentViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 21/10/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import SwiftGifOrigin
import SwiftyJSON
import Alamofire

/******Protocol to Handle image from Camera******/
protocol ErrorFromLaunch {
    func Error(error: String)
}


class JustAMomentViewController: UIViewController, goBack, UITextFieldDelegate {
    
    /***********Delegate property for Protocol*************/
    var delegate: ErrorFromLaunch?
    var back = false
    @IBOutlet weak var upagradeWalletLabel: UILabel!
    @IBOutlet weak var OTPTextfield: UITextField!
    @IBOutlet weak var one_time_otpLabel: UILabel!
    
    var account_linked = [LinkedAccountModel]()
    
    var from_segue = ""
    //var account_number = UserDefaults.standard.string(forKey: "AccountNumber")!
    
    var message = ""
    var OTP = ""

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var viewwrapper: UIView!
    
    @IBOutlet weak var headerLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        OTPTextfield.setLeftPaddingPoints(15)
        OTPTextfield.delegate = self
        
        print(wallet_is_current[0].wallet_uid)
        // Do any additional setup after loading the view.
        imageView.loadGif(name: "spinner")
        
        print(from_segue)
        headerLabel.text = from_segue
        
        print(from_segue)
        if from_segue == "Just a moment" {
            getList()
        }
        else if from_segue == "Creating bank account for you" {
           createBank()
        }
        
    }
    
  ////Animation for text field on logIn/Signup screen
     override func viewWillAppear(_ animated: Bool) {
        if back {
            dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: Delegates here
    func go_back(bool: Bool) {
        dismiss(animated: true, completion: nil)
    }
    
//    func cellWasTapped(bool: Bool, acct_number: String) {
//        account_number = acct_number
//        print(acct_number)
//        if bool {
//             createBank()
//        }
//    }
 
    
    ////  API call here /////
    //MARK: -> getList  - list of bank account -> Step One
    func getList(){
        
       
        print("get list was activated from line  92 self...")
        /******Import  and initialize Util Class*****/
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "getList": "1"]
        
        
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
        
        
        let url = "\(utililty.url)link_bank_account"
        
        postData(url: url, parameter: parameter, token: token, header: headers)
    }
    
    ////////***********Post Data MEthod*********////////
    func postData(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
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
                let response = decriptorJson["response"].arrayValue.count
                
                if(status && (response >= 0)) {
                    
                    self.account_linked = [LinkedAccountModel]()
                            
                    let response_acct = decriptorJson["response"].arrayValue
                    for i in response_acct {
                        let account = LinkedAccountModel()
                        account.account_name = i["account_name"].stringValue
                        account.account_number = i["account_number"].stringValue
                        account.bank_code = i["bank_code"].stringValue
                        account.auth = i["auth"].stringValue
                        
                        self.account_linked.append(account)
                    }
                    self.performSegue(withIdentifier: "goToLinkBank", sender: self)
                }
                    
                else if (message == "Session has expired") {
                    let logout = UtilClass()
                    logout.returnToLogin(controller: self)
                }
                    
                else {

                    ////From the alert Service
                    //*******check if delegate is not nil*********
                    self.message = message
                    self.delegate?.Error(error: message)
                    self.dismiss(animated: true, completion: nil)
                }
            }
            else {
                ////From the alert Service
                self.delegate?.Error(error: "Network Error")
                self.dismiss(animated: true, completion: nil)
                self.message = "Network Error"
                
            }
        }
    }
    
    
    ////  API call here /////
    //MARK: - createBank  - Create of bank accounts
    func createBank(){
        
       
        /******Import  and initialize Util Class*****/
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "request": "1", "WalletID": wallet_is_current[0].wallet_uid]
        
        
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
        
        
        let url = "\(utililty.url)upgrade_wallet"
        
        postData2(url: url, parameter: parameter, token: token, header: headers)
    }
    
    ///////////***********Post Data MEthod*********////////
    func postData2(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
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
                let auth = decriptorJson["response"]["auth"].stringValue
                //let response = decriptorJson["response"].arrayValue.count
                
                if(status && auth == "OTP") {
                    self.OTPTextfield.isHidden = false
                    self.one_time_otpLabel.isHidden = false
                    self.upagradeWalletLabel.isHidden = false
                    
                    self.upagradeWalletLabel.text = message
                    ////////////////// ///// ////// ///// ////
                    self.headerLabel.isHidden = true
                    self.imageView.isHidden = true
                }
                    
                else if auth == "NONE" {
                    self.performSegue(withIdentifier: "goToFinish", sender: self)
                }
                
                else if (message == "Session has expired") {
                    let logout = UtilClass()
                    logout.returnToLogin(controller: self)
                }
                    
                else {
                    ////From the alert Service
                    self.message = message
                    self.delegate?.Error(error: message)
                    self.dismiss(animated: true, completion: nil)
                }
            }
            else {
                
                ////From the alert Service
                self.delegate?.Error(error: "Network Error")
                self.dismiss(animated: true, completion: nil)
                self.message = "Network Error"
            }
        }
    }
    
    //MARK: Text field delegates here
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        OTP = OTPTextfield.text ?? ""
        OTPTextfield.endEditing(true)
        if OTP != "" {
            createBankWithOTP()
        }
        return false
    }
    
    //MARK: STEP 2: - Request OTP
    func createBankWithOTP(){
        
       
        /******Import  and initialize Util Class*****/
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "WalletID": wallet_is_current[0].wallet_uid, "token": OTP]
        
        
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
        
        
        let url = "\(utililty.url)upgrade_wallet"
        
        postData3(url: url, parameter: parameter, token: token, header: headers)
    }
    
    var is_true = false
    ///////////***********Post Data MEthod*********////////
    func postData3(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        OTPTextfield.isHidden = true
        one_time_otpLabel.isHidden = true
        upagradeWalletLabel.isHidden = true
        
        ////////////////// ///// ////// ///// ////
        headerLabel.isHidden = false
        imageView.isHidden = false
        
        is_true = true
        
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
                //let response = decriptorJson["response"].arrayValue.count
                
                if(status) {
            
                    self.performSegue(withIdentifier: "goToFinish", sender: self)
                }
                else if self.is_true {
                    self.message = message
                    self.performSegue(withIdentifier: "goToLinkBank", sender: self)
                }
                
                else if (message == "Session has expired") {
                    let logout = UtilClass()
                    logout.returnToLogin(controller: self)
                }
                    
                else {
                    
                    ////From the alert Service
                    self.message = message
                    self.delegate?.Error(error: message)
                    self.dismiss(animated: true, completion: nil)
                }
            }
            else {
                
                ////From the alert Service
                self.delegate?.Error(error: "Network Error")
                self.dismiss(animated: true, completion: nil)
                self.message = "Network Error"
            }
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToLinkBank" {
            let destination = segue.destination as! LinkedExitingAccountViewController
            destination.is_true = is_true
            destination.message = message
            destination.linked_account = account_linked
            
            
            //destination.delegate = self
            destination.delegate2 = self
        }
    }
}
