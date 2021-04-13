//
//  ChangePasscodeViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 22/08/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ChangePasscodeViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var currentPasswordField: UITextField!
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var secureImage: UIButton!
    @IBOutlet weak var secureImage1: UIButton!
    @IBOutlet weak var secureImage2: UIButton!
    @IBOutlet weak var colorRedView: UIImageView!
    @IBOutlet weak var colorYellowView: UIImageView!
    @IBOutlet weak var colorGreenView: UIImageView!
    
    
    var message = ""
    var password = ""
    var password1 = ""
    var confirmPassword = ""
    
    
    //let dashboardAlert = DashBoardAlertService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        currentPasswordField.delegate = self
        newPasswordField.delegate = self
        confirmPasswordTextField.delegate = self
        
        
        currentPasswordField.setLeftPaddingPoints(14)
        newPasswordField.setLeftPaddingPoints(14)
        confirmPasswordTextField.setLeftPaddingPoints(14)
        
        newPasswordField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        currentPasswordField.resignFirstResponder()
        newPasswordField.resignFirstResponder()
        confirmPasswordTextField.resignFirstResponder()
        view.endEditing(true)
        return true
    }
    
    
    //************Handles search when input text is filled************//
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        if textField.tag == 1 {
            
            let (capitalresult, numberresult, specialresult) = checkTextSufficientComplexity(text: textField.text!)
            
            
            if capitalresult || numberresult || specialresult {
                colorRedView.image = UIImage(named: "red")
            }
            else {
                colorRedView.image = UIImage(named: "")
                
            }
            
            if (capitalresult && numberresult) || (capitalresult && specialresult) || (specialresult && numberresult) {
                colorYellowView.image = UIImage(named: "yellow")
            }
            else {
                colorYellowView.image = UIImage(named: "")
            }
            
            if specialresult && capitalresult && numberresult {
                colorGreenView.image = UIImage(named: "green")
            }
                
            else  {
                colorGreenView.image = UIImage(named: "")
            }
            view.reloadInputViews()
        }
    }
    
    
    func checkTextSufficientComplexity( text : String) -> (Bool, Bool, Bool){
        
        let capitalLetterRegEx  = ".*[A-Z]+.*"
        let texttest = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
        let capitalresult = texttest.evaluate(with: text)
        
        let numberRegEx  = ".*[0-9]+.*"
        let texttest1 = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        let numberresult = texttest1.evaluate(with: text)
        
        
        let specialCharacterRegEx  = ".*[^A-Za-z0-9].*"
        let texttest2 = NSPredicate(format:"SELF MATCHES %@", specialCharacterRegEx)
        let specialresult = texttest2.evaluate(with: text)
        
        
        return (capitalresult, numberresult, specialresult)
        
    }
    
    
    //++++++=========Delay function @if token is true move to next page+++++++===========//
    func verifyPassword(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "SessionID": session, "CustomerID": customer_id, "current_password": password]
        
        
        
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
        
        print(token)
        
        let url = "\(utililty.url)change_password"
        
        firstApiCall(url: url, parameter: parameter, token: token, header: headers)
        
    }
    
    
    
    //MARK: API CALL
    ///////////***********Post Data MEthod*********////////
    func firstApiCall(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        self.activityIndicator.startAnimating()
        self.nextButton.isHidden = true
        
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
                    self.changePassword()
                    //Show some kinder alert letting user know it was successful
                }
                    
                else if (message == "Session has expired") {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    //*******check if delegate is not nil*********
                    self.nextButton.isHidden = false
                    self.message = message
                    self.activityIndicator.stopAnimating()
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
                
            }
            else {
                self.nextButton.isHidden = false
                self.activityIndicator.stopAnimating()
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    func changePassword(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "SessionID": session, "CustomerID": customer_id, "new_password": password1, "confirmPassword": confirmPassword]
        
        
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
        
        
        let url = "\(utililty.url)change_password"
        
        secondAPICall(url: url, parameter: parameter, token: token, header: headers)
        
    }
    
    //MARK: API CALL
    ///////////***********Post Data MEthod*********////////
    func secondAPICall(url: String, parameter: [String: String], token: String, header: [String: String]) {
        self.nextButton.isHidden = true
        
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
                    let successService = SuccessService()
                    let alertVC = successService.popUp(alertMessage: message)
                    self.present(alertVC, animated: true)
                    
                    self.nextButton.isHidden = false
                    self.activityIndicator.stopAnimating()
                    self.currentPasswordField.text = ""
                    self.newPasswordField.text = ""
                    self.confirmPasswordTextField.text = ""
                    self.colorGreenView.image = UIImage(named: "");
                    self.colorRedView.image = UIImage(named: "");
                    self.colorYellowView.image = UIImage(named: "");                    //Show some kinder alert letting user know it was successful
                }
                    
                else if (message == "Session has expired") {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    //*******check if delegate is not nil*********
                    self.nextButton.isHidden = false
                    self.message = message
                    self.activityIndicator.stopAnimating()
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
                
            }
            else {
                self.nextButton.isHidden = false
                self.activityIndicator.stopAnimating()
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    var image1 = false;
    var image2 = false;
    var image3 = false;
    
    func changeSecureImage(num: Int) {
        if num == 1 {
            if image1 {
                secureImage.setImage(UIImage(named: "eye1"), for: .normal)
                return;
            }
            else {
                secureImage.setImage(UIImage(named: "eye"), for: .normal)
            }
        }
        
        if num == 2 {
            if image2 {
                secureImage1.setImage(UIImage(named: "eye1"), for: .normal)
                return;
            }
            else {
                secureImage1.setImage(UIImage(named: "eye"), for: .normal)
            }
        }
        if num == 3 {
            if image3 {
                secureImage2.setImage(UIImage(named: "eye1"), for: .normal)
                return;
            }
            else {
                secureImage2.setImage(UIImage(named: "eye"), for: .normal)
            }
        }
        
    }
    
    @IBAction func togglePassowords(_ sender: UIButton) {
        if sender.tag == 1 {
            currentPasswordField.isSecureTextEntry.toggle()
            image1.toggle()
            changeSecureImage(num: 1)
            return;
        }
        if sender.tag == 2 {
            newPasswordField.isSecureTextEntry.toggle()
            image2.toggle()
            changeSecureImage(num: 2)
            return;
        }
        if sender.tag == 3 {
            confirmPasswordTextField.isSecureTextEntry.toggle()
            image3.toggle()
            changeSecureImage(num: 3)
            return;
        }
    }
    
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        
        if currentPasswordField.text != "" || newPasswordField.text != "" || confirmPasswordTextField.text != "" {
            password = currentPasswordField.text!
            password1 = newPasswordField.text!
            confirmPassword = confirmPasswordTextField.text!
            verifyPassword()
            return
        }
            
        else {
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "Please fill all fields")
            self.present(alertVC, animated: true)
        }
    }
    
}
