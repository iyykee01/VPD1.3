//
//  EnterVPDPINViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 03/04/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class EnterVPDPINViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var VDPPIN: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var stackViewHide: UIStackView!
    
    @IBOutlet weak var viewToHide1: DesignableView!
    @IBOutlet weak var viewToHide2: DesignableView!
    @IBOutlet weak var messageLabel: UILabel!
    
    var userPin = ""
    var message = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        VDPPIN.isSecureTextEntry = true
        self.viewToHide2.isHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        VDPPIN.resignFirstResponder()
    }
    
    
    func validatePin(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "SessionID": session, "CustomerID": customer_id, "transaction_pin": userPin]
        
        
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
        
        secondAPICall(url: url, parameter: parameter, token: token, header: headers)
        
    }
    
    //MARK: API CALL
    ///////////***********Post Data MEthod*********////////
    func secondAPICall(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        self.stackViewHide.isHidden = true
        self.activityIndicator.startAnimating()
        
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
                    self.stackViewHide.isHidden = false
                    self.activityIndicator.stopAnimating()
                    self.message = message
                    //Show some kinder alert letting user know it was successful
                    self.dismiss(animated: true, completion: nil)
                }
                    
                else if (message == "Session has expired") {
                    
                    self.dismiss(animated: true, completion: nil)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                    }
                    
                }
                    
                else {
                    //*******check if delegate is not nil*********
                    self.stackViewHide.isHidden = false
                    self.message = message
                    self.activityIndicator.stopAnimating()
                    self.messageLabel.text = message
                    self.viewToHide1.isHidden = !false
                    self.viewToHide2.isHidden = false
                }
                
            }
                
            else {
                self.stackViewHide.isHidden = false
                self.activityIndicator.stopAnimating()
                self.viewToHide1.isHidden = !false
                self.viewToHide2.isHidden = false
                self.messageLabel.text = "Network Error"
            }
        }
    }
    
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        
        if VDPPIN.text == "" {
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "Invalid PIN")
            self.present(alertVC, animated: true)
        }
        else {
            userPin = VDPPIN.text!
            validatePin()
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func redCancelButton(_ sender: Any) {
        VDPPIN.text = ""
        self.viewToHide1.isHidden = false
        self.viewToHide2.isHidden = !false
    }
    
}
