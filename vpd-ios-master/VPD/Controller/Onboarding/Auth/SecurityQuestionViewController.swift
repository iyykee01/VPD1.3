//
//  SecurityQuestionViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 11/07/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CommonCrypto

class SecurityQuestionViewController: UIViewController, UITextFieldDelegate, seguePerform {
    
    @IBOutlet weak var securityQuestionLabel: UILabel!
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var seeAnswer: UIButton!
    
    var securityQuestion = ""
    var securityQuestionAnswer = ""
    
    var sessionID = ""
    var from_segue = ""
    var message = ""
    var see_answer = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //securityQuestionLabel.text = securityQuestion
        answerTextField.delegate = self
        
        answerTextField.setLeftPaddingPoints(14)
        securityQuestionLabel.text = "\(securityQuestion)?"
        
        activityIndicator.isHidden = true
    }
    
    
    //Text field should return and close keyboard//
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        answerTextField.resignFirstResponder()
        return false
    }
    
    
    //++++++=========Delay function @if token is true move to next page+++++++===========//
    func delayToNextPage(){
        
        //******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID":sessionID, "question": "1", "validate":securityQuestionAnswer]
        
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
        postData(url: url, parameter: parameter, token: token, header: headers)
        
    }
    
    
    func postData(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        //**** Animate UI indicator ****/
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        button.isHidden = true
        
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
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.button.isHidden = false
                    self.message = message
                    
                    //                    if self.from_segue == "forgot password" {
                    //                        self.performSegue(withIdentifier: "goToOTP", sender: self)
                    //                    }
                    //                    else {
                    self.performSegue(withIdentifier: "goToSuccess", sender: self)
                    //                    }
                }
                else {
                    //**** Animate UI indicator ****/
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.button.isHidden = false
                    self.showToast(message: message, font: UIFont(name: "Muli", size: 14)!)
                }
            }
            else {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.button.isHidden = false
                
                let alertService = AlertService()
                
                let alertVC = alertService.alert(alertMessage: "Connection Timed Out")
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
    
    @IBAction func seeAnswerButtonPressed(_ sender: Any) {
        see_answer.toggle()
        if see_answer {
            answerTextField.isSecureTextEntry = false
            seeAnswer.setImage(UIImage(named: "eye1"), for: .normal);
        }
        else {
            answerTextField.isSecureTextEntry = true
            seeAnswer.setImage(UIImage(named: "eye"), for: .normal);
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        
        
        if answerTextField.text != "" {
            securityQuestionAnswer = answerTextField.text!
            delayToNextPage()
        }
        else {
            let alertService = AlertService()
            let alertVC =  alertService.alert(alertMessage: "Invalid Field")
            self.present(alertVC, animated: true)
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



