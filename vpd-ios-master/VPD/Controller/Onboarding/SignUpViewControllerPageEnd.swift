//
//  SignUpViewControllerPageEnd.swift
//  VPD
//
//  Created by Ikenna Udokporo on 26/04/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SignUpViewControllerPageEnd: UIViewController {
    
    ////***********Prepare for segue successfull***********///////
    var accountNumber: String = ""
    var username:  String = ""
    var password: String = ""
    var sessionID = ""
    var message = ""
    
    @IBOutlet weak var activateButton: UIButton!
    @IBOutlet weak var lable1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    
    @IBOutlet weak var emailverificationLabel: UILabel!
    @IBOutlet weak var emailverificationLabel2: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let relativeFontConstant: CGFloat = 0.04
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        label4.text = accountNumber
        
        //        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        //        let underlineAttributedString = NSAttributedString(string: "Please verify your email", attributes: underlineAttribute)
        //
        //        let underlineAttributedString2 = NSAttributedString(string: "address to use our features", attributes: underlineAttribute)
        //        emailverificationLabel.attributedText = underlineAttributedString
        //        emailverificationLabel2.attributedText = underlineAttributedString2
        
    }
    
    //MARK: ******* Login API Call******///
    func delayToNextPage(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        ///**********************//////
        //***********///******************//
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        
        //dob = '02-04-1999'
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "username": username, "password": password]
        
        let jsonEncode = JSONEncoder()
        let jsonData = try! jsonEncode.encode(params)
        let json = String(data: jsonData, encoding: .utf8)!
        
        
        ///*********converting shaDeivcepptiies to hexString*********////////
        /////*********converting shaDeivcepptiies to hexString*********////////
        let hexShaDevicePpties = utililty.convertToHexString(json)
        print(hexShaDevicePpties)
        
        
        
        let parameter = ["reqData": hexShaDevicePpties]
        let token = UserDefaults.standard.string(forKey: "Token")!
        print(token)
        let headers: HTTPHeaders = ["X-Authorization": token, "AppGroup": "IOS"]
        
        let url = "\(utililty.urlv3)login"
        
        //utililty.postData(path: url, paramter: parameter, headers: headers)
        
        postData(url: url, parameter: parameter, token: token, header: headers)
    }
    
    
    //MARK: ******* Profile API Call******///
    func delayToNextPageProfile(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "SessionID": session, "CustomerID": customer_id]
        
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
        
        
        let url = "\(utililty.urlv3)profile"
        
        
        profileApiCall(url: url, parameter: parameter, token: token, header: headers)
    }
    
    
    ///////////***********Post Data MEthod*********////////
    func postData(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        activityIndicator.startAnimating()
        activateButton.isHidden = true
        
        
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
                
                LoginResponse = decriptorJson
                
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                let session = decriptorJson["response"]["session"].stringValue
                
                
                if status {
                    let customer_id = decriptorJson["response"]["accounts"].arrayValue[0]["customer_id"].stringValue
                    
                    //*************Store Session Id in Local Storage**************//
                    UserDefaults.standard.set(session, forKey: "SessionID")
                    UserDefaults.standard.set(customer_id, forKey: "CustomerID")
                    UserDefaults.standard.synchronize()
                    
                    self.delayToNextPageProfile()
                }
                else {
                    //*******check if delegate is not nil*********
                    self.message = message
                    self.activityIndicator.stopAnimating()
                    self.activateButton.isHidden = !true
                    
                    let alertService = AlertService()
                    let alertVC =  alertService.alert(alertMessage: "\(message)")
                    self.present(alertVC, animated: true)
                    
                }
            }
            else {
                self.activityIndicator.stopAnimating()
                self.activateButton.isHidden = !true
                let alertService = AlertService()
                let alertVC =  alertService.alert(alertMessage: "Network Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    
    ///////////***********Post Data MEthod*********////////
    func profileApiCall(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        
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
                
                //*******Parameters for successful response and for data response*******///
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                
                if(status) {
                    Profile = decriptorJson
                    self.activityIndicator.stopAnimating()
                    self.activateButton.isHidden = !true
                    //*****Perform segue to dashboard**********
                    self.performSegue(withIdentifier: "goToDashboard", sender: self);
                    self.pushNotification_call()
                    
                }
                else {
                    //*******check if delegate is not nil*********
                    self.message = message
                    self.activityIndicator.stopAnimating()
                    self.activateButton.isHidden = !true
                    
                    let alertService = AlertService()
                    let alertVC =  alertService.alert(alertMessage: "\(message)")
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.message = "Network Error"
                self.activityIndicator.stopAnimating()
                self.activateButton.isHidden = !true
                
                let alertService = AlertService()
                let alertVC =  alertService.alert(alertMessage: "\(self.message)")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    //MARK: ******* Push notification API Call******///
    func pushNotification_call(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        var device_id = ""
        
        if let constantName = UserDefaults.standard.string(forKey: "Device_id") {
            //statements using 'constantName'
            device_id = constantName
        } else {
            print("No device_id found")
        }
        
        print(device_id, ".................from page 395")
        
        //******getting parameter from string
        let params = ["AppID":device.sha512, "key": device_id]
        
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
        
        
        let url = "\(utililty.urlv3)connectpush"
        
        
        pushNotificationAPIcall(url: url, parameter: parameter, token: token, header: headers)
    }
    
    
    ///////////***********Post Data MEthod*********////////
    func pushNotificationAPIcall(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        
        
        Alamofire.request(url, method: .post, parameters: parameter, headers: header).responseJSON {
            response in
            if response.result.isSuccess {
                print("SUCCESSFUL.....", "I try to register token")
                
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
                    self.view.isUserInteractionEnabled = true
                    print("COnnected push notification successful")
                    
                }
                else {
                    
                    self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    let alertService = AlertService()
                    let alertVC =  alertService.alert(alertMessage: "\(message)")
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
        }
    }
    
    
    @IBAction func ActivatePressed(_ sender: Any) {
        delayToNextPage()
    }
    
    
    func setLabelText(){
        if(UIScreen.main.bounds.size.width >= 320 || UIScreen.main.bounds.height >= 568){
        }
        
        lable1.font = lable1.font.withSize(self.view.frame.height * relativeFontConstant)
        label2.font = label2.font.withSize(self.view.frame.height * relativeFontConstant)
        label3.font = label3.font.withSize(self.view.frame.height * relativeFontConstant)
        label4.font = label4.font.withSize(self.view.frame.height * relativeFontConstant)
        label5.font = label5.font.withSize(self.view.frame.height * relativeFontConstant)
    }
}
