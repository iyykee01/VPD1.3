//
//  SecurityViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 22/08/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import LocalAuthentication

var trnas = false
var log = false
var face = false
var pinPlusFingerprint = false

class SecurityViewController: UIViewController {
    
    var type = ""
    var bool = ""
    var auth = false
    var key = ""
    var face_or_finger = ""
    var on_off = ""
    var addAuth = face
    var pin = ""
    
    var switchSelected: UISwitch!
    
    
    @IBOutlet weak var switch_one: UISwitch!
    @IBOutlet weak var switch_two: UISwitch!
    @IBOutlet weak var switch_three: UISwitch!
    @IBOutlet weak var switch_four: UISwitch!
    @IBOutlet weak var viewThree: UIView!
    @IBOutlet weak var viewFour: UIView!
    @IBOutlet weak var faceLoginBody: UILabel!
    @IBOutlet weak var faceloginHeader: UILabel!
    @IBOutlet weak var faceTransactionHeader: UILabel!
    @IBOutlet weak var faceTransactionBody: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
          print(addAuth, "bool value for face")
        if trnas {
            switch_one.isOn = true
        }
        if log  {
            switch_two.isOn = true
        }
        if face {
            switch_three.isOn = true
        }
        if pinPlusFingerprint {
            switch_four.isOn = true
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if LocalAuth.shared.hasFaceId() {
            faceLoginBody.text = "Whenever you want to login back to VPD, your FaceID can be used to log back in"
            
            faceTransactionBody.text = "Whenever you make any transaction, your FaceID and PIN will be used to authenticate/ authorize the transaction"
        }
        else {
            faceloginHeader.text = "FingerPrint Login"
            faceTransactionHeader.text = "PIN + FingerPrint transaction"
        }
    }
    
    
    //MARK: -  activatate face or fingerprint
    func APICall(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        var params = [String: String]()
     
        if auth {
            //******getting parameter from string
            params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, type: on_off, face_or_finger : key]
        }
        
        else {
            //******getting parameter from string
            params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, type: bool]
        }
    
        
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
        
        
        let url = "\(utililty.url)preference"
        
        postToCallAPI(url: url, parameter: parameter, token: token, header: headers)
    }
    
    //MARK: - VALIDATE
    ///////////***********Post Data MEthod*********////////
    func postToCallAPI(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        let loader = LoaderPopup()
        let loaderVC = loader.Loader()
        self.present(loaderVC, animated: true)
        
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
                
                
                if(status) {
                    
                    if self.addAuth == false {
                        print("added......")
                        face.toggle()
                        UserDefaults.standard.set(user_name.sha512, forKey: "authKey")
                        UserDefaults.standard.synchronize()
                    }
                    else {
                        print("remove........")
                        face.toggle()
                        UserDefaults.standard.removeObject(forKey: "authKey")
                        UserDefaults.standard.synchronize()
                    }
                    
                    self.view.isUserInteractionEnabled = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        let alertSV = SuccessAlertTransaction()
                        let alert = alertSV.alert(success_message: message) {
                            self.navigationController?.popToViewController(ofClass: ListOfBeneficiaryViewController.self)
                        }
                        self.present(alert, animated: true)
                        
                    }
                    
                }
                else if (message == "Session has expired") {
                    self.dismiss(animated: true, completion: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                    }
                }
                    
                else {
                    
                    self.view.isUserInteractionEnabled = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        ////From the alert Service
                        let alertService = AlertService()
                        let alertVC = alertService.alert(alertMessage: message)
                        self.present(alertVC, animated: true)
                        
                    }
                }
            }
            else {
                
                self.view.isUserInteractionEnabled = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.dismiss(animated: true, completion: nil)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                    self.present(alertVC, animated: true)
                    
                }
                
            }
        }
    }
    
    
    //MARK: -  activatate face or fingerprint
    func APICallForFaceTransaction(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        var params = [String: String]()
      
    
        print(pinPlusFingerprint, "State for fingerPrint transacxtion")
        
        if pinPlusFingerprint {
            //******getting parameter from string
            params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "transaction_authentication": on_off, "face_key" : key]
        }
            
        else {
            params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "transaction_authentication": on_off, "transaction_pin": pin]
        }
        
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
        
        
        let url = "\(utililty.url)preference"
        
        postToCallAPIForTransaction(url: url, parameter: parameter, token: token, header: headers)
    }
    
    //MARK: - VALIDATE
    ///////////***********Post Data MEthod*********////////
    func postToCallAPIForTransaction(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        let loader = LoaderPopup()
        let loaderVC = loader.Loader()
        self.present(loaderVC, animated: true)
        
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
                
                
                if(status) {
                    
                    self.view.isUserInteractionEnabled = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        let alertSV = SuccessAlertTransaction()
                        let alert = alertSV.alert(success_message: message) {
                            self.navigationController?.popToViewController(ofClass: ListOfBeneficiaryViewController.self)
                        }
                        self.present(alert, animated: true)
                        
                    }
                    
                }
                else if (message == "Session has expired") {
                    self.dismiss(animated: true, completion: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                    }
                }
                    
                else {
                    
                    self.view.isUserInteractionEnabled = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        ////From the alert Service
                        let alertService = AlertService()
                        let alertVC = alertService.alert(alertMessage: message)
                        self.present(alertVC, animated: true)
                        
                    }
                }
            }
            else {
                
                self.view.isUserInteractionEnabled = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.dismiss(animated: true, completion: nil)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                    self.present(alertVC, animated: true)
                    
                }
                
            }
        }
    }
    
    
    @IBAction func mySwiftPressed(_ sender: UISwitch) {
        
        if(sender.tag == 1){
        
            auth = false
            trnas.toggle()
            type = "transaction_notification"
            switchSelected = switch_one
            
            if trnas {
                switch_one.isOn = true
                bool = "on"
                APICall()
                return
            }
            else {
                switch_one.isOn = false
                bool = "off"
                APICall()
            }
        }
        
        if(sender.tag == 2){
          
            log.toggle()
            auth = false
            type = "login_notification"
            switchSelected = switch_two
            
            if log {
                switch_two.isOn = true
                bool = "on"
                APICall()
                return
            }
            else {
                switch_two.isOn = false
                bool = "off"
                APICall()
            }
        }
        
        if(sender.tag == 3) {
            
            auth = true
            switchSelected = switch_three
            
            if LocalAuth.shared.hasTouchId() {
                type = "face_authentication"
                face_or_finger = "face_key"
                key = UserDefaults.standard.string(forKey: "userName")!.sha512
                
                if !face {
                    switch_three.isOn = true
                    on_off = "on"
                    APICall()
                    addAuth = face
                    print("I called here and set face to true")
                    return
                }
                else {
                    switch_three.isOn = false
                    on_off = "off"
                    key = ""
                    APICall()
                    addAuth = face
                    print("I called here for else set face to false")
                    auth = false
                }
            }
            else if LocalAuth.shared.hasFaceId() {
                type = "face_authentication"
                face_or_finger = "face_key"
                key = UserDefaults.standard.string(forKey: "userName")!.sha512
                print("sent from finger")
                if face {
                    switch_three.isOn = true
                    on_off = "on"
                    APICall()
                    addAuth = face
                    // SET UserDefaults
                    return
                }
                else {
                    switch_three.isOn = false
                    on_off = "off"
                    key = ""
                    APICall()
                    addAuth = face
                    auth = false
                }
            }
        }
        
        if(sender.tag == 4) {
            
         
            pinPlusFingerprint.toggle()
            auth = true
            switchSelected = switch_four
            
            if pinPlusFingerprint {
                switch_four.isOn = true
                on_off = "on"
                pinPlusFingerprint = true
                key = UserDefaults.standard.string(forKey: "userName")!.sha512
                APICallForFaceTransaction()
                return
  
            }
            else {
                if UserDefaults.standard.object(forKey: "PIN") != nil  {
                    pin = "1111"//UserDefaults.standard.string(forKey: "PIN")!
                    
                }
                 pin = "1111"
                switch_four.isOn = false
                on_off = "off"
                APICallForFaceTransaction()
            }
            
        }
        
    }
    
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
