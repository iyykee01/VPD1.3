//
//  NewDeviceViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 10/07/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CommonCrypto

class NewDeviceViewController: UIViewController {
    
    var securityQuestion = ""
    var sessionID = ""
    @IBOutlet weak var mobileView: DesignableView!
    @IBOutlet weak var EmailView: DesignableView!
    @IBOutlet weak var securityQuestionView: DesignableView!
    @IBOutlet weak var noneOfTheseView: DesignableView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var phonePressed = ""
    var emailPressed = ""
    var to_segue = ""
    var message = ""
    
    var key = ""
    var value = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        print(sessionID)
    }
    
    
    @IBAction func goBackButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        mobileView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(mobileViewFunc)))
//        EmailView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(EmailViewFunc)))
        securityQuestionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(securityQuestionViewFunc)))
//        noneOfTheseView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(noneOfTheseViewFunc)))
    }
//
//    @objc func mobileViewFunc (sender : UITapGestureRecognizer) {
//        self.mobileView.becomeFirstResponder()
//       phonePressed = "1"
//       mobileView.layer.borderColor = UIColor.blue.cgColor
//        EmailView.layer.borderColor = UIColor.lightGray.cgColor
//
//        self.to_segue = "phone"
//        //************This will pick the key that is selected ************//
//
//        apiToMobilePhone()
//    }
    
//    @objc func EmailViewFunc (sender : UITapGestureRecognizer) {
//        self.EmailView.becomeFirstResponder()
//        EmailView.layer.borderColor = UIColor.blue.cgColor
//        mobileView.layer.borderColor = UIColor.lightGray.cgColor
//
//        self.to_segue = "email"
//        //************This will pick the key that is selected ************//
//        apiToEmail()
//
//    }
    
    @objc func securityQuestionViewFunc (sender : UITapGestureRecognizer) {
        self.securityQuestionView.becomeFirstResponder()
        performSegue(withIdentifier: "goToSecurityQuestion", sender: self)
    }
    
//    @objc func noneOfTheseViewFunc (sender : UITapGestureRecognizer) {
//        self.noneOfTheseView.becomeFirstResponder()
//        navigationController?.popToViewController(ofClass: LoginViewController.self)
//    }
    
    //***********Call delay to next here************//
    @IBAction func nextButtonClicked(_ sender: Any) {
        print(key, value)
        apiToSecurityQuestion()
    }

    
    //MARK: - Delay function @if token is true move to next//
    func apiToSecurityQuestion(){
        
        //******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID":sessionID, key: value]
            
            let jsonEncode = JSONEncoder()
            let jsonData = try! jsonEncode.encode(params)
            let json = String(data: jsonData, encoding: .utf8)!
            
            
            ///*********converting shaDeivcepptiies to hexString*********////////
            /////*********converting shaDeivcepptiies to hexString*********////////
            let hexShaDevicePpties = utililty.convertToHexString(json)
            print(hexShaDevicePpties)
            
            
            let parameter = ["reqData": hexShaDevicePpties]
            
            //**********Get Token and set Token to header***********//
            let token = UserDefaults.standard.string(forKey: "Token")!
            let headers: HTTPHeaders = ["X-Authorization": token, "AppGroup": "IOS"]
            
            let url = "\(utililty.url)change_device"
            postData1(url: url, parameter: parameter, token: token, header: headers)

    }
    
    //MARK: - For Security question//
    func postData1(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
//        //**** Animate UI indicator ****/
//        self.activityIndicator.startAnimating()
//        self.activityIndicator.isHidden = false
//        buttonUI.isHidden = true
       
        
        Alamofire.request(url, method: .post, parameters: parameter, headers: header).responseJSON {
            response in
            if response.result.isSuccess {
                print("SUCCESSFUL.....")
                
                //******Getting Data******//
                let data: JSON = JSON(response.result.value!)
                
                
                //****Decode json hear****/
                let hexKey = data["reqResponse"].stringValue
                //******Import  and initialize Util Class*****////
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
                    //**** Animate UI indicator ****/
                    //self.stopActiveIndicator()
                }
                else {
                    //**** Animate UI indicator ****/
                    //self.stopActiveIndicator()
                    self.showToast(message: message, font: UIFont(name: "Muli", size: 14)!)
                }
                
            }
            else {
                //self.stopActiveIndicator()
                let alertService = AlertService()
                let alertVC =  alertService.alert(alertMessage: "Connection Timed Out")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    
     //MARK: - API for mobile phone verification//
        func apiToMobilePhone(){
            
            //******Import  and initialize Util Class*****////
            let utililty = UtilClass()
            
            let device = utililty.getPhoneId()
            
            //print("shaDevicePpties")
            let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
            let timeInSecondsToString = String(timeInSeconds)
            
            let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID":sessionID, "phone": "1"]
  
                
                let jsonEncode = JSONEncoder()
                let jsonData = try! jsonEncode.encode(params)
                let json = String(data: jsonData, encoding: .utf8)!
                
                
                ///*********converting shaDeivcepptiies to hexString*********////////
                /////*********converting shaDeivcepptiies to hexString*********////////
                let hexShaDevicePpties = utililty.convertToHexString(json)
                print(hexShaDevicePpties)
                
                
                let parameter = ["reqData": hexShaDevicePpties]
                
                //**********Get Token and set Token to header***********//
                let token = UserDefaults.standard.string(forKey: "Token")!
                let headers: HTTPHeaders = ["X-Authorization": token, "AppGroup": "IOS"]
                
                let url = "\(utililty.url)change_device"
                postData2(url: url, parameter: parameter, token: token, header: headers)

        }
        
        
        func postData2(url: String, parameter: [String: String], token: String, header: [String: String]) {
            
            //**** Animate UI indicator ****/
            activityIndicator.startAnimating()
           
            Alamofire.request(url, method: .post, parameters: parameter, headers: header).responseJSON {
                response in
                if response.result.isSuccess {
                    print("SUCCESSFUL.....")
                    
                    //******Getting Data******//
                    let data: JSON = JSON(response.result.value!)
                    
                    
                    //****Decode json hear****/
                    let hexKey = data["reqResponse"].stringValue
                    //******Import  and initialize Util Class*****////
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
                        //**** Animate UI indicator ****/
                        print("I got here somhow.........")
                        self.activityIndicator.stopAnimating()
                        self.to_segue = "phone"
                        self.message = message
                        self.performSegue(withIdentifier: "goToVerify", sender: self)
                    }
                    else {
                        //**** Animate UI indicator ****/
                        self.activityIndicator.stopAnimating()
                        self.showToast(message: message, font: UIFont(name: "Muli", size: 14)!)
                    }
                    
                }
                else {
                    self.activityIndicator.stopAnimating()
                    let alertService = AlertService()
                    let alertVC =  alertService.alert(alertMessage: "Connection Timed Out")
                    self.present(alertVC, animated: true)
                }
            }
        }
    
     //MARK: - API for  verification//
        func apiToEmail(){
            
            //******Import  and initialize Util Class*****////
            let utililty = UtilClass()
            
            let device = utililty.getPhoneId()
            
            //print("shaDevicePpties")
            let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
            let timeInSecondsToString = String(timeInSeconds)
            
            let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID":sessionID, "email": "1"]
                
                let jsonEncode = JSONEncoder()
                let jsonData = try! jsonEncode.encode(params)
                let json = String(data: jsonData, encoding: .utf8)!
                
                
                ///*********converting shaDeivcepptiies to hexString*********////////
                /////*********converting shaDeivcepptiies to hexString*********////////
                let hexShaDevicePpties = utililty.convertToHexString(json)
                print(hexShaDevicePpties)
                
                
                let parameter = ["reqData": hexShaDevicePpties]
                
                //**********Get Token and set Token to header***********//
                let token = UserDefaults.standard.string(forKey: "Token")!
                let headers: HTTPHeaders = ["X-Authorization": token, "AppGroup": "IOS"]
                
                let url = "\(utililty.url)change_device"
                postData3(url: url, parameter: parameter, token: token, header: headers)

        }
        
        
    func postData3(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        //**** Animate UI indicator ****/
        activityIndicator.startAnimating()
        
        
        Alamofire.request(url, method: .post, parameters: parameter, headers: header).responseJSON {
            response in
            if response.result.isSuccess {
                print("SUCCESSFUL.....")
                
                //******Getting Data******//
                let data: JSON = JSON(response.result.value!)
                
                
                //****Decode json hear****/
                let hexKey = data["reqResponse"].stringValue
                //******Import  and initialize Util Class*****////
                let utililty = UtilClass()
                
                //********decripting Hex key**********//
                let decriptor = utililty.convertHexStringToString(text: hexKey)
                
                
                //**********Changing Data back to Json format***///
                let jsonData = decriptor.data(using: .utf8)!
                
                let decriptorJson: JSON = JSON(jsonData)
                print(decriptorJson)
                
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                
                
                if status {
                    //**** Animate UI indicator ****/
                    self.activityIndicator.stopAnimating()
                    self.performSegue(withIdentifier: "goToVerify", sender: self)
                    
                    self.message = message
                }
                else {
                    //**** Animate UI indicator ****/
                    self.activityIndicator.stopAnimating()
                    self.showToast(message: message, font: UIFont(name: "Muli", size: 14)!)
                }
                
            }
            else {
                //self.stopActiveIndicator()
                let alertService = AlertService()
                let alertVC =  alertService.alert(alertMessage: "Connection Timed Out")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSecurityQuestion" {
            let SQVC = segue.destination as! SecurityQuestionViewController
            SQVC.securityQuestion = securityQuestion
            SQVC.sessionID = sessionID
        }
        
        if segue.identifier == "goToVerify" {
            let des = segue.destination as! VerifyOTPForEmailOrPhoneViewController
            des.from_segue_verify = to_segue
            des.message_from_segue = message
        }
    }

}
