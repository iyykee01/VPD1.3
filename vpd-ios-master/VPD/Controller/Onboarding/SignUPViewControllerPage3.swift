//
//  SignUPViewControllerPage3.swift
//  VPD
//
//  Created by Ikenna Udokporo on 25/04/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

var user_phone_number = ""


class SignUPViewControllerPage3: UIViewController, UITextFieldDelegate {
    
    var mobile = ""
    var country: String!
    var longitude: String!
    var latitude: String!
    var accountType: String!
    
    var userInputSixDigit = String()
    var whatsapp = "0"
    
    
    //******Import  and initialize Util Class*****////
    var utililty = UtilClass()
    

    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var textField3: UITextField!
    @IBOutlet weak var textField4: UITextField!
    @IBOutlet weak var textField5: UITextField!
    @IBOutlet weak var textField6: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var buttonUI: UIButton!
    @IBOutlet weak var tryWhatsappLinkButton: UIButton!
    

    @IBOutlet weak var resendCodeButtonLabel: UIButton!
    

    
    let yourAttributes : [NSAttributedString.Key: Any] = [
    NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15),
    NSAttributedString.Key.foregroundColor : UIColor(hexFromString: "#33B5CD"),
    NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]
    
    
    
    ////From the alert Service
    let resendCode = ResendCode()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        border()
 
        
        
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
        
        
        let attributeString = NSMutableAttributedString(string: "Try Whatsapp",
                                                        attributes: yourAttributes);
        tryWhatsappLinkButton.setAttributedTitle(attributeString, for: .normal)
        
        print(mobile)
        
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
        textField5.inputAccessoryView = toolBar
        textField6.inputAccessoryView = toolBar
     
    }
    
    @objc func donePicker() {
        textField1.resignFirstResponder()
        textField2.resignFirstResponder()
        textField3.resignFirstResponder()
        textField4.resignFirstResponder()
        textField5.resignFirstResponder()
        textField6.resignFirstResponder()
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
    
    
    //MARK: -Api Call to Verify digit Code
    func delayToNextPage(){
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        
        let sixDigitCode = "\(textField1.text ?? "nil")\(textField2.text ?? "nil")\(textField3.text ?? "nil")\(textField4.text ?? "nil")\(textField5.text ?? "nil")\(textField6.text ?? "nil")"
        
        print(sixDigitCode)
        
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "phone": mobile, "token": sixDigitCode]

        
        
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
        
        let url = "\(utililty.url)phone_verify"
        postData(url: url, parameter: parameter, token: token, header: headers)
        
    }
    
    //MARK: -Api Call to send otp to Whatsapp
       func callToWhatsApp(){
           
           let device = utililty.getPhoneId()
           
           //print("shaDevicePpties")
           let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
           let timeInSecondsToString = String(timeInSeconds)
        
           
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "phone": mobile, "whatsapp": whatsapp]

           
           
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
           
           let url = "\(utililty.url)phone_verify"
           postToResendCode(url: url, parameter: parameter, token: token, header: headers)
           
       }
    
    
    func postData(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        ////From the alert Service
        let alertService = AlertService()
        
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
                let decriptor = self.utililty.convertHexStringToString(text: hexKey)
                //print(decriptor)
                
                //**********Changing Data back to Json format***///
                let jsonData = decriptor.data(using: .utf8)!
                
                let decriptorJson: JSON = JSON(jsonData)
                
                
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                
                
                if(status) {
                    //**** Animate UI indicator ****/
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.buttonUI.isHidden = false
                    self.navigatOnCountryIso()
                    self.seconds = 15
                }
                else {
                    //**** Animate UI indicator ****/
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.buttonUI.isHidden = false
                    self.seconds = 15
                    let alertVC =  alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
                
            }
            else {
                //**** Animate UI indicator ****/
                self.seconds = 15
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
        
        
        let params = ["phone": mobile, "AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString]
        print(params)
        
        let jsonEncode = JSONEncoder()
        let jsonData = try! jsonEncode.encode(params)
        let json = String(data: jsonData, encoding: .utf8)!
        
        
        ///*********converting shaDeivcepptiies to hexString*********////////
        /////*********converting shaDeivcepptiies to hexString*********////////
        let hexShaDevicePpties = utililty.convertToHexString(json)
        //print(hexShaDevicePpties)
        
        
        let parameter = ["reqData": hexShaDevicePpties]
        
        //**********Get Token and set Token to header***********//
        let token = UserDefaults.standard.string(forKey: "Token")!
        let headers: HTTPHeaders = ["X-Authorization": token, "AppGroup": "IOS"]
        
        let url = "\(utililty.url)phone_verify"
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
    
    
    func navigatOnCountryIso() {
         self.performSegue(withIdentifier: "goToSVC4", sender: self)
//        if(country != "NGA"){
//            self.performSegue(withIdentifier: "goToSVCForeign1", sender: self)
//        }
//
//        else {
//            self.performSegue(withIdentifier: "goToSVC4", sender: self)
//        }
    }
    
    @IBAction func tryWhatappButtonPressed(_ sender: Any) {
        whatsapp = "1"
        callToWhatsApp()
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
            
            let alertVC =  resendCode.popUp(){
                
                self.resendCodeApi()
            }
            present(alertVC, animated: true)
        }
        else {
            isTimerRunning.toggle()
            runTimer(on: isTimerRunning)
        }
        
    }
    
    
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        
       
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
        
        if(segue.identifier == "goToSVCForeign1" &&  country != "NGA") {
            let FSVC1 = segue.destination as! ForeignSignUpViewControllerPage1
            FSVC1.accountType = accountType
            FSVC1.latitude = latitude
            FSVC1.longitude = longitude
            FSVC1.country = country
            FSVC1.mobile = mobile
        }
        else {
            let SVC4 = segue.destination as! SignUpViewControllerPage4
            SVC4.accountType = accountType
            SVC4.latitude = latitude
            SVC4.longitude = longitude
            SVC4.country = country
            SVC4.mobile = mobile
        }
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

