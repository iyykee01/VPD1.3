//
//  BecomeAnAgentOTPViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 03/08/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit
import SwiftyJSON

class BecomeAnAgentOTPViewController: UIViewController, UITextFieldDelegate {
    
    var assf_number = ""
    var phone_number = ""
    var counter = 15.0
    
    
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var textField3: UITextField!
    @IBOutlet weak var textField4: UITextField!
    @IBOutlet weak var textField5: UITextField!
    @IBOutlet weak var textField6: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var buttonUI: UIButton!
    @IBOutlet weak var resendCodeButton: UIButton!
    @IBOutlet weak var sendAgain: UIButton!
    
    
    let yourAttributes : [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font : UIFont(name: "Muli-Regular", size: 12)!,
        NSAttributedString.Key.foregroundColor : UIColor.gray,
        NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let attributeString = NSMutableAttributedString(string: "Send Again",
                                                        attributes: yourAttributes);
        sendAgain.setAttributedTitle(attributeString, for: .normal);
        
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
        
        if #available(iOS 12.0, *) {
            textField1.textContentType = .oneTimeCode
            textField2.textContentType = .oneTimeCode
            textField3.textContentType = .oneTimeCode
            textField4.textContentType = .oneTimeCode
            textField5.textContentType = .oneTimeCode
            textField6.textContentType = .oneTimeCode
        }
        
        textField1.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
        textField2.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
        textField3.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
        textField4.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
        textField5.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
        textField6.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
        //textField1.becomeFirstResponder()
        
        configToolBar()
        //setUpOneTimeCode()
    }
    
       //When changed value in textField
       @objc func textFieldDidChange(textField: UITextField){
           let text = textField.text
           if  text?.count == 1 {
               switch textField{
                   
               case textField1:
                   textField2.becomeFirstResponder()
               case textField2:
                   textField3.becomeFirstResponder()
               case textField3:
                   textField4.becomeFirstResponder()
               case textField4:
                   textField5.becomeFirstResponder()
               case textField5:
                   textField6.becomeFirstResponder()
               case textField6:
                   textField6.resignFirstResponder()
                   self.view.endEditing(true)
               default:
                   break
               }
           }
           if  text?.count == 0 {
               switch textField{
               case textField1:
                   textField1.becomeFirstResponder()
               case textField2:
                   textField1.becomeFirstResponder()
               case textField3:
                   textField2.becomeFirstResponder()
               case textField4:
                   textField3.becomeFirstResponder()
               case textField5:
                   textField4.becomeFirstResponder()
               case textField6:
                   textField5.becomeFirstResponder()
               default:
                   break
               }
           }
           else{
               
           }
       }
    
//    func setUpOneTimeCode() {
//        textField1.textContentType = .oneTimeCode
//        textField2.textContentType = .oneTimeCode
//        textField3.textContentType = .oneTimeCode
//        textField4.textContentType = .oneTimeCode
//        textField5.textContentType = .oneTimeCode
//        textField6.textContentType = .oneTimeCode
//    }
    
    
    //MARK: Go to next text field
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
    
    //MARK: - Set up tool bar
    func configToolBar() {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.donePicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false);
        
        textField1.inputAccessoryView = toolBar;
        textField2.inputAccessoryView = toolBar;
        textField3.inputAccessoryView = toolBar;
        textField4.inputAccessoryView = toolBar;
        textField5.inputAccessoryView = toolBar;
        textField6.inputAccessoryView = toolBar;
    }
    
    //MARK: functionality for done
    @objc func donePicker() {
        view.endEditing(true)
    }
    
    
    //MARK: Make network request
    func networkCall() {
        
        activityIndicator.startAnimating()
        buttonUI.isHidden = true
        
        let utililty = UtilClass()
        let device = utililty.getPhoneId()
        
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        
        let token = "\(textField1.text ?? "nil")\(textField2.text ?? "nil")\(textField3.text ?? "nil")\(textField4.text ?? "nil")\(textField5.text ?? "nil")\(textField6.text ?? "nil")"
        
        
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "phone": phone_number, "agentcode": assf_number, "token": token]
        
        print(params)
        
        
        utililty.delayToNextPage(params: params, path: "register_agent") { result in
            switch result {
            case .failure(let error):
                self.activityIndicator.stopAnimating()
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Please check that you have internet connection")
                self.present(alertVC, animated: true)
                print(error)
                break
                
            case .success:
                
                let data: JSON = JSON(result.value!)
                
                //****Decode json hear****/
                let hexKey = data["reqResponse"].stringValue
                //******Import  and initialize Util Class*****////
                
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
                    self.buttonUI.isHidden = false
                    //MARK: - to come back to
                    agentIDFromReg = decriptorJson["response"]["id"].stringValue
                    let alertSV = SuccessAlertTransaction()
                    let alert = alertSV.alert(success_message: message) {
                        guard let VCS = self.navigationController?.viewControllers else {return }
                        for controller in VCS {
                            if controller.isKind(of: TabBarViewController.self) {
                                let tabVC = controller as! TabBarViewController
                                tabVC.selectedIndex = 2
                                self.navigationController?.popToViewController(ofClass: TabBarViewController.self, animated: true)
                                
                            }
                        }
                    }
                    self.present(alert, animated: true)
                }
                 
                else if (message == "Session has expired") {
                    self.buttonUI.isHidden = false
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                
                else {
                    self.activityIndicator.stopAnimating()
                    self.buttonUI.isHidden = false
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
                break
            }
        }
    }
    
    //MARK: Make network request
    func resendCodeNetworkCall() {
        
        activityIndicator.startAnimating()
        buttonUI.isHidden = true
        
        let utililty = UtilClass()
        let device = utililty.getPhoneId()
        
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "phone": phone_number, "agentcode": assf_number]
        
        
        print(params)
        
        
        utililty.delayToNextPage(params: params, path: "register_agent") { result in
            switch result {
            case .failure(let error):
                self.activityIndicator.stopAnimating()
                
                print(error)
                print("Please check that you have internet connection")
                break
                
            case .success:
                
                let data: JSON = JSON(result.value!)
                
                //****Decode json hear****/
                let hexKey = data["reqResponse"].stringValue
                //******Import  and initialize Util Class*****////
                
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
                    self.buttonUI.isHidden = false
                  
                }
                else if (message == "Session has expired") {
                    self.buttonUI.isHidden = false
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                
                else {
                    self.activityIndicator.stopAnimating()
                    self.buttonUI.isHidden = false
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
                break
            }
        }
    }
    
    //MARK: Update counter and call API
    @objc func updateCounter(_ timer: Timer) {
        
        if counter > 0 {
            resendCodeButton.setTitle("Resend code in \(counter)", for: .normal)
            counter -= 1.0
        }
        
        if counter == 1.0 {
            timer.invalidate()
            resendCodeNetworkCall()
            counter = 15.0
            resendCodeButton.setTitle("Resend code in \(counter)", for: .normal)
        }
    }
    

    var myTimer : Timer?
    
    //MARK: Resend code network call
    @IBAction func sendAgainButtonPressed(_ sender: Any) {
        self.myTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true);
    }
    
    
    //MARK: Submit button handler
    @IBAction func submitButtonPressed(_ sender: Any) {
        // Validate if code isn't present
        
        if textField1.text == "" || textField2.text == "" || textField3.text == "" || textField4.text == "" || textField5.text == "" || textField6.text == "" {
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "Invalid OTP Code")
            self.present(alertVC, animated: true)
            return
        }
        else {
            networkCall()
        }
    }
    
    //MARK: Back button handler
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}




