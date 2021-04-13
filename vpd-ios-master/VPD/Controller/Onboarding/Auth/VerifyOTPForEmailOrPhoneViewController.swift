//
//  VerifyOTPForEmailOrPhoneViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 01/01/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class VerifyOTPForEmailOrPhoneViewController: UIViewController, UITextFieldDelegate, seguePerform {
    
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var textField3: UITextField!
    @IBOutlet weak var textField4: UITextField!
    @IBOutlet weak var textField5: UITextField!
    @IBOutlet weak var textField6: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var buttonUI: UIButton!
    
    @IBOutlet weak var viewConstraints: NSLayoutConstraint!
    
    var username_segue = ""
    var token = ""
    
    var from_segue_verify = "email"
    var userInputSixDigit = String()
    var message_from_segue = ""
    var message = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        NsInformation()
        // Do any additional setup after loading the view.
        
        activityIndicator.isHidden = true

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
        
        
        print(from_segue_verify)
    }
    
    func NsInformation(){
         
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardDidShowNotification, object: nil)
     }
     
     ///Move button up
     @objc func keyboardWillChange(notification: Notification){
         
         guard let info = notification.userInfo else { return }
         guard let frameInfo = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
         let keyboardFrame = frameInfo.cgRectValue
         
         let keyboardHeight = Int(keyboardFrame.height)
    

         
         UIView.animate(withDuration: 0.1){
             self.viewConstraints.constant = CGFloat(keyboardHeight + 90)
             self.view.layoutIfNeeded()
         }
         
     }
     
     
     func textFieldDidBeginEditing(_ textField: UITextField) {
         NsInformation()
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
    
    
    func goNext(next: String) {
        navigationController?.popToViewController(ofClass: LoginViewController.self)
    }
    
    //Stop listening for keyboard hide/show events//////
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
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
        
        
        let sixDigitCode = "\(textField1.text ?? "nil")\(textField2.text ?? "nil")\(textField3.text ?? "nil")\(textField4.text ?? "nil")\(textField5.text ?? "nil")\(textField6.text ?? "nil")"
        
       token = sixDigitCode
        
       let params = ["AppID": device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "validate": sixDigitCode, from_segue_verify: "1"]
        
        
        let jsonEncode = JSONEncoder()
        let jsonData = try! jsonEncode.encode(params)
        let json = String(data: jsonData, encoding: .utf8)!
        
        
        ///*********converting shaDeivcepptiies to hexString*********////////
        /////*********converting shaDeivcepptiies to hexString*********////////
        let hexShaDevicePpties = utililty.convertToHexString(json)
        print(hexShaDevicePpties)
        
        
        let parameter = ["reqData": hexShaDevicePpties]
        
        let token = UserDefaults.standard.string(forKey: "Token")!
        print("//**************************************************************************??***************//******")
        //print("\(token) ..............from app storage")
        
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
        self.activityIndicator.isHidden = false
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
  
    @IBAction func nextButtonPressed(_ sender: Any) {
        
        viewConstraints.constant = 90
        textField1.resignFirstResponder()
        textField2.resignFirstResponder()
        textField3.resignFirstResponder()
        textField4.resignFirstResponder()
        textField5.resignFirstResponder()
        textField6.resignFirstResponder()

        userInputSixDigit = "\(textField1.text ?? "nil")\(textField2.text ?? "nil")\(textField3.text ?? "nil")\(textField4.text ?? "nil")\(textField5.text ?? "nil")\(textField6.text ?? "nil")"

        if(textField1.text == "" || textField2.text == "" || textField3.text == "" || textField4.text == "" || textField5.text == "" || textField6.text == ""){
            print("Please make sure")
        }
        else {
            delayToNextPage()
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       let destination = segue.destination as! Success2LaunchViewController
        destination.message_segue = message
        destination.delegate = self
    }

    //TODO///
    //=========ADD Border Radius to input fields=========//
    func border(){
        textField1.layer.cornerRadius = 10;
        textField1.layer.masksToBounds = true;
        textField1.layer.borderWidth = 1
        textField1.layer.borderColor = UIColor.lightGray.cgColor
        
        textField2.layer.cornerRadius = 10;
        textField2.layer.masksToBounds = true;
        textField2.layer.borderWidth = 1
        textField2.layer.borderColor = UIColor.lightGray.cgColor
        
        textField3.layer.cornerRadius = 10;
        textField3.layer.masksToBounds = true;
        textField3.layer.borderWidth = 1
        textField3.layer.borderColor = UIColor.lightGray.cgColor
        
        textField4.layer.cornerRadius = 10;
        textField4.layer.masksToBounds = true;
        textField4.layer.borderWidth = 1
        textField4.layer.borderColor = UIColor.lightGray.cgColor
        
        textField5.layer.cornerRadius = 10;
        textField5.layer.masksToBounds = true;
        textField5.layer.borderWidth = 1
        textField5.layer.borderColor = UIColor.lightGray.cgColor
        
        textField6.layer.cornerRadius = 10;
        textField6.layer.masksToBounds = true;
        textField6.layer.borderWidth = 1
        textField6.layer.borderColor = UIColor.lightGray.cgColor
    }
    
}



