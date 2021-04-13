//
//  LoaderViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 02/07/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import UIKit
import SVProgressHUD

//var LoginResponse: JSON!
//var Profile: JSON!

/******Protocol to Handle image from Camera******/
protocol ErrorFromLogin {
    func Error(error: String)
}


//var account_number_g = ""

class LoaderViewController: UIViewController {
    
    
    /***********Delegate property for Protocol*************/
    var delegate: ErrorFromLogin?
    
    @IBOutlet weak var circle4: UIImageView!
    @IBOutlet weak var circle1: UIImageView!
    @IBOutlet weak var circle2: UIImageView!
    @IBOutlet weak var circle3: UIImageView!
    
    var username: String!
    var password: String!
    var securityQuestion = ""
    var sessionID = ""
    var accountNumber = ""
    
    
    var arrayOfflag = ["flag", "us", "uk", "eu"]
    var message = ""


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        delayToNextPage()
        
//        account_number_g = accountNumber
//        print("account number global \(account_number_g)")
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        animateLogo()
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
        
        let url = "\(utililty.url)login"
        
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
        
        
        let url = "\(utililty.url)profile"
        
        profileApiCall(url: url, parameter: parameter, token: token, header: headers)
    }
    
    
    ///////////***********Post Data MEthod*********////////
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

                LoginResponse = decriptorJson

                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                self.securityQuestion = decriptorJson["response"]["securityQuestion"].stringValue
                let session = decriptorJson["response"]["session"].stringValue


                if(status && message == "Security verification required") {
                    self.sessionID = session
                    UserDefaults.standard.set(session, forKey: "SessionID")
                    UserDefaults.standard.synchronize()
                    self.gotoVerification()
                }
                    
                else if status == true {
                    
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
                    self.delegate?.Error(error: message)
                    self.performSegue(withIdentifier: "goBackToLogin", sender: self)
                }
            }
            else {
                print(Error.self)
                self.message = "Network Error"
                self.delegate?.Error(error: "Network Error")
                self.navigationController?.popViewController(animated: true)
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
                print(decriptorJson)
                
                //*******Parameters for successful response and for data response*******///
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                
                if(status) {
                    Profile = decriptorJson
                    
                    //*****Perform segue to dashboard**********

                }
                else {
                    //*******check if delegate is not nil*********
                    self.message = message
                    self.delegate?.Error(error: message)
                    self.navigationController?.popViewController(animated: true)
                }
            }
            else {
                self.message = "Network Error"
                self.delegate?.Error(error: "Network Error")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    func gotoVerification () {
        performSegue(withIdentifier: "goToVerification", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToVerification" {
            let SQVC = segue.destination as! NewDeviceViewController
            SQVC.securityQuestion = securityQuestion
            SQVC.sessionID = sessionID
        }
       ///*****Using protocol to send error message back to login screen****//HERE
        
        if segue.identifier == "goBackToLogin" {
            let SQVC = segue.destination as! LoginViewController
            SQVC.message = message
        }
    }
    
    
    /////////Method that animates logo on App
    func animateLogo() {
        UIView.animate(withDuration: 1.5, delay: 0, options: [.repeat], animations: {
            self.circle1.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }) { (finished) in
            UIView.animate(withDuration: 1, animations: {
                self.circle1.transform = CGAffineTransform.identity
            })
        }
        
        UIView.animate(withDuration: 1.5, delay: 1, options: [.repeat],  animations: {
            self.circle2.transform = CGAffineTransform(scaleX: 1.7, y: 1.7)
        }) { (finished) in
            UIView.animate(withDuration: 1, animations: {
                self.circle2.transform = CGAffineTransform.identity
            })
        }
        
        UIView.animate(withDuration: 1.5, delay: 1.2, options: [.repeat],  animations: {
            self.circle3.transform = CGAffineTransform(scaleX: 1.9, y: 1.9)
        }) { (finished) in
            UIView.animate(withDuration: 1, animations: {
                self.circle3.transform = CGAffineTransform.identity
            })
        }
        
        
        UIView.animate(withDuration: 1.5, delay: 1.5, options: [.repeat],  animations: {
            self.circle4.transform = CGAffineTransform(scaleX: 2.1, y: 2.1)
        }) { (finished) in
            UIView.animate(withDuration: 1, animations: {
                self.circle4.transform = CGAffineTransform.identity
            })
        }
    }

}
