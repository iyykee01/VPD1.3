//
//  ChangeDeviceLoginSixDigitCodeViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 02/04/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ChangeDeviceLoginSixDigitCodeViewController: UIViewController, UITextFieldDelegate, seguePerform {

   
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var buttonUI: DesignableButton!
    @IBOutlet weak var resendCodeButtonLabel: UIButton!
    
    
    var four_digit_code = ""
    var message = ""
    @IBOutlet weak var textField1: DesignableUITextField!
    
    @IBOutlet weak var textField2: DesignableUITextField!
    @IBOutlet weak var textField3: DesignableUITextField!
    
    @IBOutlet weak var textField4: UITextField!
    @IBOutlet weak var textField5: UITextField!
    @IBOutlet weak var textField6: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        textField1.addTarget(self, action: #selector(textChanged), for: .editingChanged)
           textField2.addTarget(self, action: #selector(textChanged), for: .editingChanged)
           textField3.addTarget(self, action: #selector(textChanged), for: .editingChanged)
           textField4.addTarget(self, action: #selector(textChanged), for: .editingChanged)
           textField5.addTarget(self, action: #selector(textChanged), for: .editingChanged)
           textField6.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        
           
           textField1.delegate = self
           textField2.delegate = self
           textField3.delegate = self
           textField4.delegate = self
           textField5.delegate = self
           textField6.delegate = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.donePicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        
        textField1.inputAccessoryView = toolBar
        textField2.inputAccessoryView = toolBar
        textField3.inputAccessoryView = toolBar
        textField4.inputAccessoryView = toolBar
        textField5.inputAccessoryView = toolBar
        textField6.inputAccessoryView = toolBar
        
    }
    
    
    //***********Method to handle date format and date dismiss*********//
    @objc func donePicker(datePicker: UIDatePicker) {
        view.endEditing(true)
    }
    
    @objc func textChanged(sender: UITextField) {
        if (sender.text?.count)! > 0 {
            let nextField = self.view.viewWithTag(sender.tag + 1) as? UITextField
            nextField?.becomeFirstResponder()
        }
        if sender.text!.count <= 0 {
           let nextField = self.view.viewWithTag(sender.tag - 1) as? UITextField
            nextField?.becomeFirstResponder()
        }
    }
    
    
    //***********//*****************//***************************
    /***********************/
    func delayToNextPage(){
        
       //******Import  and initialize Util Class*****////
       let utililty = UtilClass()

        let device = utililty.getPhoneId()
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        
       let params = ["AppID": device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "validate": four_digit_code, "email": "1"]
        
        
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
        
        let url = "\(utililty.url)change_device"
        postData(url: url, parameter: parameter, token: token, header: headers)
        
    }
    
    
    func postData(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        ////From the alert Service
        let alertService = AlertService()
       //******Import  and initialize Util Class*****////
       let utililty = UtilClass()
        
        //**** Animate UI indicator ****/
        self.activityIndicator.startAnimating()
        buttonUI.isHidden = true
        
        
        Alamofire.request(url, method: .post, parameters: parameter, headers: header).responseJSON {
            response in
            //print(response)
            if response.result.isSuccess {
                print("SUCCESSFUL.....")
                
                //******Getting Data******//
                let data: JSON = JSON(response.result.value!)
                
                
                //****Decode json hear****/
                let hexKey = data["reqResponse"].stringValue
                
                
                //print("\(hexKey).............from decodedKey")
                
                //********decripting Hex key**********//
                let decriptor = utililty.convertHexStringToString(text: hexKey)
                print(decriptor)
                
                //**********Changing Data back to Json format***///
                let jsonData = decriptor.data(using: .utf8)!
                
                let decriptorJson: JSON = JSON(jsonData)
                print(decriptorJson)
                
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                
                
                if(status) {
                    //**** Animate UI indicator ****/
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.buttonUI.isHidden = false
                    self.message = message
                    
                    self.performSegue(withIdentifier: "goToSuccess", sender: self)
                    
                }
                else {
                    //**** Animate UI indicator ****/
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.buttonUI.isHidden = false
                    let alertVC =  alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
                
            }
            else {
                //**** Animate UI indicator ****/
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.buttonUI.isHidden = false
                let alertVC =  alertService.alert(alertMessage: "Connection Timed Out")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    func resendCodeApi(){
        
        //******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "validate": four_digit_code, "email": "1"]
        
        
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
        postToResendCode(url: url, parameter: parameter, token: token, header: headers)
        
    }
    
    
    func postToResendCode(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        ///From the alert Service
        let alertService = AlertService()
        
        //******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        //**** Animate UI indicator ****/
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        buttonUI.isHidden = true
        
        
        Alamofire.request(url, method: .post, parameters: parameter, headers: header).responseJSON {
            response in
            if response.result.isSuccess {
                print("SUCCESSFUL.....")
                
                //******Getting Data******//
                let data: JSON = JSON(response.result.value!)
                
                
                //****Decode json hear****/
                let hexKey = data["reqResponse"].stringValue
                
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
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.buttonUI.isHidden = false
                    
                }
                else {
                    //**** Animate UI indicator ****/
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.buttonUI.isHidden = false
                    let alertVC =  alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
                
            }
            else {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.buttonUI.isHidden = false
                let alertVC =  alertService.alert(alertMessage: "Connection Timed Out")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    
    func goNext(next: String) {
        navigationController?.popToViewController(ofClass: LoginViewController.self)
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    var timer = Timer()
    var isTimerRunning = false
       //*************************************************//
       var seconds = 15.00
       
       
       func runTimer(on: Bool) {
           
           timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {[weak self](_) in
               
               guard let strongSelf = self else {return}
               
               strongSelf.seconds -= 1
               strongSelf.resendCodeButtonLabel.setTitle("Resend code in \(strongSelf.seconds)", for: .normal)
               
               if strongSelf.seconds == 0 {
                   strongSelf.timer.invalidate()
               }
           })

       }
       
       
    
    //Resend Code action goes in here
    @IBAction func resendCodePressed(_ sender: Any) {
        
        
        if seconds == 0 {
            isTimerRunning = false
            seconds = 15.00
            resendCodeApi()
        }
        else {
            isTimerRunning.toggle()
            runTimer(on: isTimerRunning)
        }
        
    }
    
    @IBAction func authorizeButtonPressed(_ sender: Any) {
        //This will call api to validated code
        four_digit_code = "\(textField1.text ?? "nil")\(textField2.text ?? "nil")\(textField3.text ?? "nil")\(textField4.text ?? "nil")\(textField5.text ?? "nil")\(textField6.text ?? "nil")"
        
        if(textField1.text == "" || textField2.text == "" || textField3.text == "" || textField4.text == "" || textField5.text == "" || textField6.text == ""){
            let alertService = AlertService()
            let alertVC =  alertService.alert(alertMessage: "Invalid Code")
            self.present(alertVC, animated: true)

        }
        else {
            delayToNextPage()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSuccess" {
            let destination = segue.destination as! Success2LaunchViewController
            destination.message_segue = message
            destination.delegate = self
        }
    }
}
