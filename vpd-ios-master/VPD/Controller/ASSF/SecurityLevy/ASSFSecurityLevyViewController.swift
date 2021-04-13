//
//  ASSFSecurityLevyViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 10/08/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit
import SwiftyJSON

class ASSFSecurityLevyViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userAcctNumber: DesignableUITextField!
    @IBOutlet weak var userAcctName: DesignableUITextField!
    @IBOutlet weak var paymentPlan: DesignableUITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var buttonUI: DesignableButton!
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var paymentPlanLabel: UILabel!
    @IBOutlet weak var paymentPlanWrapper: DesignableView!
    
    
    var months = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"];
    let piker1 = UIPickerView()
    
    var tag_number = 0
    
    var acct_name = ""
    var acct_number = ""
    var payment_plan = ""
    var wallet_id = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        userAcctNumber.setLeftPaddingPoints(14)
        userAcctName.setLeftPaddingPoints(14)
        paymentPlan.setLeftPaddingPoints(14)
        
        userAcctNumber.delegate = self
        userAcctName.delegate = self
        paymentPlan.delegate = self
        
        piker1.dataSource = self
        piker1.delegate = self
        
        paymentPlan.inputView = piker1
        
        for i in accountArray {
            if i.currency == "NGN" {
                wallet_id = i.wallet_uid
            }
        }
        
        configToolBar()
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
        
        userAcctNumber.inputAccessoryView = toolBar;
    }
    
   
    //MARK: functionality for done
    @objc func donePicker() {
        
        if tag_number == 2 && userAcctNumber.text?.count == 10  {
            acct_number = userAcctNumber.text!
            NetworkCallUserAcctInfo()
        }
        view.endEditing(true)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        tag_number = textField.tag
        return true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true);
    }
    
    
    //MARK: KeyBoard handler
    @objc func keyboardwillChange(notification: Notification) {
        
        guard   let userInfo = notification.userInfo as? [String: NSObject],
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect  else { return }
        
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification  {
            view.frame.origin.y = -keyboardFrame.height / 3
        }
        else {
            view.frame.origin.y = 0
        }
        
    }
    
    //MARK: Deinitializing Notification from keyboard
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil);
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        }
        else {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil);
            view.frame.origin.y = 0
        }
        
        
    }
    
    
    //MARK: Make network to create user wallet
    func NetworkCallUserAcctInfo() {
        view.endEditing(true)
        view.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        buttonUI.isHidden = true
        
        let utililty = UtilClass()
        let device = utililty.getPhoneId()
        
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        let params = [
            
            "AppID":device.sha512,
            "language":"en",
            "RequestID": timeInSecondsToString,
            "SessionID": session,
            "CustomerID": customer_id,
            "AgentID": agentIDFromReg,
            "WalletID": wallet_id,
            "accountNumber": acct_number
        ]
        
        
        
        utililty.delayToNextPage(params: params, path: "agent_user") { result in
            switch result {
            case .failure(let error):
                self.activityIndicator.stopAnimating()
                self.buttonUI.isHidden = !true
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
                    self.buttonUI.isHidden = !true
                    self.buttonUI.setTitle("Submit", for: .normal)
                    self.view.isUserInteractionEnabled = true
                    
                    self.accountNameLabel.isHidden = !true
                              
                    self.paymentPlanLabel.isHidden = !true
                    self.paymentPlanWrapper.isHidden = false
                    self.userAcctName.isHidden = false
                              
                    self.userAcctName.text = decriptorJson["response"]["name"].stringValue
                    
                }
                else if (message == "Session has expired") {
                    self.activityIndicator.stopAnimating()
                    self.buttonUI.isHidden = !true
                    self.view.isUserInteractionEnabled = true
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.activityIndicator.stopAnimating()
                    self.buttonUI.isHidden = !true
                    self.view.isUserInteractionEnabled = true
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
    func networkCallToGetOTP() {
        
        activityIndicator.startAnimating()
        buttonUI.isHidden = true
        
        let utililty = UtilClass()
        let device = utililty.getPhoneId()
        
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        
        
        //******getting parameter from string
        let params = [
            "AppID":device.sha512,
            "language":"en",
            "RequestID": timeInSecondsToString,
            "SessionID": session,
            "CustomerID": customer_id,
            "WalletID": wallet_id,
            "AgentID": agentIDFromReg,
            "accountNumber": acct_number,
            "plan": payment_plan
            
        ]
        
        
        utililty.delayToNextPage(params: params, path: "agent_security_levy") { result in
            switch result {
            case .failure(let error):
                self.activityIndicator.stopAnimating()
                
                print(error)
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Please check that you have internet connection");
                self.present(alertVC, animated: true)
                
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
                    self.performSegue(withIdentifier: "goToOTP", sender: self)
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
    
    @IBAction func payButtonPressed(_ sender: Any) {
        
        if userAcctNumber.text == "" || userAcctName.text == "" || paymentPlan.text == "" {
            
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "Please fill all fields");
            self.present(alertVC, animated: true)
        }
        else {
            
            acct_name = userAcctName.text!;
            acct_number = userAcctNumber.text!;
            
            //Call api to get token and Api should go to next page
            networkCallToGetOTP()
            
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToOTP" {
            let destination = segue.destination as! ASSFSecurityLevyOTPViewController
            
            destination.payment_plans = payment_plan
            destination.agentIDFromReg = agentIDFromReg
            destination.accountNumber = acct_number
            destination.wallet_id = wallet_id
        }
    }

    
}


extension ASSFSecurityLevyViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return months.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return months[row]

    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        paymentPlan.text = "\(months[row]) - Month"
        payment_plan = months[row]
        
        self.view.endEditing(true)


    }
    
}
