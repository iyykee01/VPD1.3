//
//  CreatePinViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 30/03/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

var pinAvailbale = false
class CreatePinViewController: UIViewController, UITextFieldDelegate, goBackToTop {
   
    

    @IBOutlet weak var headerText: UILabel!
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var textField3: UITextField!
    @IBOutlet weak var textField4: UITextField!
    @IBOutlet weak var confirmButton: DesignableButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var body_text: UILabel!
    
    var head_text = "Create PIN"
    
    var userPin = ""
    var message = ""
    var old_pin = ""
    var old = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        headerText.text = head_text
        textFieldsConfig();
        
        if head_text != "Create PIN" {
            body_text.text = "Please enter your old 4-digit"
            old = true
        }
        
    }
    
    func textFieldsConfig() {
        textField1.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        textField2.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        textField3.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        textField4.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        
        
        textField1.delegate = self
        textField2.delegate = self
        textField3.delegate = self
        textField4.delegate = self
        
        
        //***********Setting up Date Picker********************//
        
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
    }
    
    
    @objc func donePicker() {
        
        if textField1.text! == "" || textField2.text! == "" || textField3.text! == "" || textField4.text! == "" {
            confirmButton.backgroundColor = UIColor(hexFromString: "#959595");
            confirmButton.isUserInteractionEnabled = false;
        }
        
        else {
            confirmButton.backgroundColor = UIColor(hexFromString: "#4F99B7");
            confirmButton.isUserInteractionEnabled = true
        }
        
        textField1.resignFirstResponder()
        textField2.resignFirstResponder()
        textField3.resignFirstResponder()
        textField4.resignFirstResponder()
    }

    
    func createPin(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        
        var params = [String: String]()
        
        if !old {
            params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "SessionID": session, "CustomerID": customer_id, "transaction_pin": userPin]
        }
            
        else {
            params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "SessionID": session, "CustomerID": customer_id, "transaction_pin": userPin, "transaction_old_pin": old_pin]
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
        
        secondAPICall(url: url, parameter: parameter, token: token, header: headers)
        
    }
    
    //MARK: API CALL
    ///////////***********Post Data MEthod*********////////
    func secondAPICall(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        self.confirmButton.isHidden = true
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
                
                
                //*******Parameters for successful response and for data response*******///
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                let user_PIN = "true"
                let PIN = self.userPin
                
                print("This is the pin i set.......", PIN)
                if(status) {
                    
                    if self.head_text == "Create PIN" {
                        self.confirmButton.isHidden = false
                        self.activityIndicator.stopAnimating()
                        UserDefaults.standard.set(user_PIN, forKey: "userPIN")
                        UserDefaults.standard.set(PIN, forKey: "PIN")
                        UserDefaults.standard.synchronize()
                        self.message = message
                        //Show some kinder alert letting user know it was successful
                        self.performSegue(withIdentifier: "goToSuccess", sender: self);
                        return
                    }
                    
                    
                }
                    
                else if (message == "Session has expired") {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    //*******check if delegate is not nil*********
                    self.confirmButton.isHidden = false
                    self.message = message
                    self.activityIndicator.stopAnimating()
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
                
            }
            else {
                self.confirmButton.isHidden = false
                self.activityIndicator.stopAnimating()
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    //VPD Account PIN changed Successfully
    
    //Protocol stubs
    func goBack() {
        navigationController?.popToViewController(ofClass: PinManagementViewController.self)
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
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true);
    }
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        
        if textField1.text! == "" || textField1.text! == "" || textField1.text! == "" || textField1.text! == "" {
            
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "Invalid Pin")
            self.present(alertVC, animated: true)
        }
        
        
        if head_text != "Create PIN" {
            
            let pin = "\(textField1.text ?? "nil")\(textField2.text ?? "nil")\(textField3.text ?? "nil")\(textField4.text ?? "nil")"
            
            old_pin = pin
            print(old_pin)
            
            self.textField1.text = ""
            self.textField2.text = ""
            self.textField3.text = ""
            self.textField4.text = ""
            head_text = "Create PIN"
            self.body_text.text = "Please enter your new 4-digit"
            confirmButton.backgroundColor = UIColor(hexFromString: "#959595");
            confirmButton.isUserInteractionEnabled = false;
            return;
            
        }
            
        else {
            let pin = "\(textField1.text ?? "nil")\(textField2.text ?? "nil")\(textField3.text ?? "nil")\(textField4.text ?? "nil")"
            
            userPin = pin
            LoginResponse["response"]["authentication"]["pin_setup_complete"].boolValue  = true
            createPin()
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! SucessfulPinManagementViewController
        destination.delegate = self
    }

}

