//
//  JustAMoment2ViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 03/11/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import SwiftGifOrigin
import SwiftyJSON
import Alamofire

class JustAMoment2ViewController: UIViewController, UITextFieldDelegate {
    
    
    /***********Delegate property for Protocol*************/
    var delegate: ErrorFromLaunch?
    
    
    @IBOutlet weak var upagradeWalletLabel: UILabel!
    @IBOutlet weak var OTPTextfield: UITextField!
    @IBOutlet weak var one_time_otpLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    
    
    
    var from_segue = ""

    
    var message = ""
    var OTP = ""
    var seletedAccount: LinkedAccountModel?
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var viewwrapper: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        OTPTextfield.setLeftPaddingPoints(15)
        OTPTextfield.delegate = self
       
       // Do any additional setup after loading the view.
        imageView.loadGif(name: "spinner")
       

        headerLabel.text = "Upgrading bank account for you"
        
        if seletedAccount?.auth != "" {
            ifBankCode()
        }
        
    }


    ///  API call here /////
    //MARK: - createBank  - Create of bank accounts
    func ifBankCode(){
        
       
        /******Import  and initialize Util Class*****/
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "bankCode": seletedAccount?.bank_code, "requestLink": seletedAccount?.account_number ]
        
        
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
                
                if(status && message == "Request Processed. OTP Authentication Required" ) {
                    self.OTPTextfield.isHidden = false
                    self.one_time_otpLabel.isHidden = false
                    self.upagradeWalletLabel.isHidden = false

                    self.upagradeWalletLabel.text = message
                    ////////////////// ///// ////// ///// ////
                    self.headerLabel.isHidden = true
                    self.imageView.isHidden = true
                }
                
                else if (message == "Session has expired") {
                    let logout = UtilClass()
                    logout.returnToLogin(controller: self)
                }
         
                else {
                    ///From the alert Service
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
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "WalletID": wallet_is_current[0].wallet_uid, "token": OTP, "bankCode": seletedAccount?.bank_code, "proceedLink": seletedAccount?.account_number]
        
        
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
        
        postData3(url: url, parameter: parameter, token: token, header: headers)
    }
    
    
    ///////////***********Post Data MEthod*********////////
    func postData3(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        OTPTextfield.isHidden = true
        one_time_otpLabel.isHidden = true
        upagradeWalletLabel.isHidden = true
        
        ////////////////// ///// ////// ///// ////
        headerLabel.isHidden = false
        imageView.isHidden = false
        

        
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
                    self.performSegue(withIdentifier: "goToSuccess", sender: self)
                }
                    
                else if (message == "Session has expired") {
                    let logout = UtilClass()
                    logout.returnToLogin(controller: self)
                }
          
                else {
                    ///From the alert Service
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
        
}
