//
//  LoginWIthFaceOrTouchIDViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 01/04/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit
import LocalAuthentication
import Alamofire
import SwiftyJSON
import Intercom


class LoginWIthFaceOrTouchIDViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var passwordTextField: DesignableUITextField!
    
    @IBOutlet weak var fingerPrintButton: DesignableButton!
    @IBOutlet weak var switchAccount: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var loginWIthLocalAuth: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: DesignableButton!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var orLabel: UILabel!
    
    var fullname = UserDefaults.standard.string(forKey: "fullName")!
    var username = UserDefaults.standard.string(forKey: "userName")!
    var password = ""
    var securityQuestion = ""
    var sessionID = ""
    var accountNumber = ""
    var face_or_touch = false
    
    var errorFromLoader = ""
    var message = ""
    var username_details = ""
    var save_login_details = false
    var see_password = false
    
    
    let yourAttributes : [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font : UIFont(name: "Muli-Regular", size: 12)!,
        NSAttributedString.Key.foregroundColor : UIColor.white,
        NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]
    
    let yourAttributes2 : [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font : UIFont(name: "Muli-Regular", size: 14)!,
        NSAttributedString.Key.foregroundColor : UIColor.white,
        NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let attributeString = NSMutableAttributedString(string: "Switch account",
                                                        attributes: yourAttributes);
        switchAccount.setAttributedTitle(attributeString, for: .normal);
        
        let attributeString2 = NSMutableAttributedString(string: "Reset",
                                                         attributes: yourAttributes2);
        resetButton.setAttributedTitle(attributeString2, for: .normal);
        
        
        usernameLabel.text = fullname
        
        passwordTextField.setLeftPaddingPoints(14);
        passwordTextField.delegate = self
        passwordTextField.isSecureTextEntry = true
        
        
        
        if (LocalAuth.shared.hasTouchId() && UserDefaults.standard.object(forKey: "authKey") != nil) || log  {
            loginWIthLocalAuth.text = "Login with TouchID"
            orLabel.isHidden = false
            fingerPrintButton.isHidden = false
            loginWIthLocalAuth.isHidden = false
            fingerPrintButton.setImage(UIImage(named: "fingerprint"), for: .normal);
        }
            
        else if LocalAuth.shared.hasFaceId() && pinPlusFingerprint {
            loginWIthLocalAuth.text = "Login with FaceID"
            loginWIthLocalAuth.isHidden = false
            orLabel.isHidden = false
            fingerPrintButton.isHidden = false
            fingerPrintButton.setImage(UIImage(named: "face-id_white"), for: .normal);
        }
            
        else {
            loginWIthLocalAuth.isHidden = !false
            orLabel.isHidden = !false
            fingerPrintButton.isHidden = !false
        }
    }
    
    func login() {
        //Api call here
        let context: LAContext = LAContext()
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil){
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Login to Voguepay Digital") { (success, nil)
                in
                
                if success {
                    
                    DispatchQueue.main.async {
                        print("cant touch this")
                        self.delayToNextPage()
                    }
                }
                else {
                    print("invalid password")
                }
            }
        }
        else {
            print("Biometrics not supported. Please enter you password")
        }
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        passwordTextField.resignFirstResponder()
    }
    
    
    @IBAction func seebuttonPressed(_ sender: Any) {
        see_password.toggle()
        
        if see_password {
            passwordTextField.isSecureTextEntry = false
        }
        else {
            passwordTextField.isSecureTextEntry = true
        }
    }
    
    
    @IBAction func questionMarkButtonPressed(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "contactUs") as? ContactUsViewController
        self.navigationController?.pushViewController(vc!, animated: true);
    }
    
    @IBAction func switchAccountButtonPressed(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Login") as? LoginViewController
        self.navigationController?.pushViewController(vc!, animated: true);
    }
    
    @IBAction func resetButtonPressed(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "enterUsername") as? EnterUsernameViewController
        self.navigationController?.pushViewController(vc!, animated: true);
    }
    
    
    @IBAction func fingerPrintButtonPressed(_ sender: Any) {
        self.face_or_touch = true
        login()
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        face_or_touch = false
        ////From the alert Service
        let alertService = AlertService()
        
        if(passwordTextField.text == ""){
            let alertVC =  alertService.alert(alertMessage: "Please complete each fields ")
            present(alertVC, animated: true)
        }
        else {
            password = passwordTextField.text!
            
            delayToNextPage()
            
        }
    }
    
    //MARK: ******* Login API Call******///
    func delayToNextPage(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        ///**********************//////
        //***********///******************//
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
       
        
        //dob = '02-04-1999'
        //******getting parameter from string
        
        var params = [String: String]()
      
        if self.face_or_touch {
            print("i call here first ")
            params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "username": username, "auth_key": username.sha512]
        }
        else {
            print("i call here next ")
            params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "username": username, "password": password]
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
        
        let url = "\(utililty.urlv3)login"
        
        //utililty.postData(path: url, paramter: parameter, headers: headers)
        
        postData(url: url, parameter: parameter, token: token, headers: headers)
    }
    
    
    //MARK: ******* Profile API Call******///
    func delayToNextPageProfile(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "SessionID": session, "CustomerID": customer_id]
        
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
        
        
        let url = "\(utililty.urlv3)profile"
        
        profileApiCall(url: url, parameter: parameter, token: token, headers: headers)
    }
    
    
    ///////////***********Post Data MEthod*********////////
    func postData(url: String, parameter: [String: String], token: String, headers: HTTPHeaders) {
        
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        loginButton.isHidden = true
        
        
        Alamofire.request(url, method: .post, parameters: parameter, headers: headers).responseJSON {
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
                
                LoginResponse = decriptorJson
                
                print(decriptorJson)
                
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                let session = decriptorJson["response"]["session"].stringValue
                
                
                self.securityQuestion = decriptorJson["response"]["securityQuestion"].stringValue
                
                
                if(status && message == "Security verification required") {
                    self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    self.sessionID = session
                    UserDefaults.standard.set(session, forKey: "SessionID")
                    UserDefaults.standard.synchronize()
                    self.gotoVerification()
                    return
                }
                
                if status == true {
                    
                    /// For  Preference page
                    trnas = LoginResponse["response"]["notifications"]["transaction"].boolValue
                    log = LoginResponse["response"]["notifications"]["login"].boolValue
                    face = LoginResponse["response"]["authentication"]["face_login"].boolValue
                    pinPlusFingerprint = LoginResponse["response"]["authentication"]["transaction_authentication"].boolValue
                    
                    
                    
                    self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    let customer_id = decriptorJson["response"]["accounts"].arrayValue[0]["customer_id"].stringValue
                    
                    invite_url = decriptorJson["response"]["invite_url"].stringValue
                    
                    //*************Store Session Id in Local Storage**************//
                    UserDefaults.standard.set(session, forKey: "SessionID");
                    UserDefaults.standard.set(customer_id, forKey: "CustomerID");
                    UserDefaults.standard.synchronize()
                    
                    
                    Intercom.registerUser(withUserId: session)
                    self.delayToNextPageProfile()
                }
                else {
                    self.loginButton.isHidden = false
                    self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    let alertService = AlertService()
                    let alertVC =  alertService.alert(alertMessage: "\(message)")
                    self.present(alertVC, animated: true)
                    
                }
            }
            else {
                self.loginButton.isHidden = false
                self.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                
                let alertService = AlertService()
                let alertVC =  alertService.alert(alertMessage: "Network Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    
    ///////////***********Post Data MEthod*********////////
    func profileApiCall(url: String, parameter: [String: String], token: String, headers: HTTPHeaders) {
        
        
        Alamofire.request(url, method: .post, parameters: parameter, headers: headers).responseJSON {
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
                //print(decriptorJson)
                
                //*******Parameters for successful response and for data response*******///
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                
                if(status) {
                    Profile = decriptorJson
                    self.passwordTextField.text = ""
                    
                    let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TabBar") as? TabBarViewController
                    self.navigationController?.pushViewController(vc!, animated: true)
                    
                    //*****Perform segue to dashboard**********
                    self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    self.pushNotification_call()
                    
                }
                else {
                    self.loginButton.isHidden = false
                    //*******check if delegate is not nil*********
                    self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    
                    let alertService = AlertService()
                    let alertVC =  alertService.alert(alertMessage: "\(message)")
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.loginButton.isHidden = false
                self.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                
                let alertService = AlertService()
                let alertVC =  alertService.alert(alertMessage: "\(self.message)")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    
    
    //MARK: ******* Push notification API Call******///
    func pushNotification_call(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        var device_id = ""
        
        if let constantName = UserDefaults.standard.string(forKey: "Device_id") {
            //statements using 'constantName'
            device_id = constantName
        } else {
            print("No device_id found")
        }
        
        
        
        //******getting parameter from string
        let params = ["AppID":device.sha512, "key": device_id]
        
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
        
        
        let url = "\(utililty.urlv3)connectpush"
        
        pushNotificationAPIcall(url: url, parameter: parameter, token: token, headers: headers)
    }
    
    
    ///////////***********Post Data MEthod*********////////
    func pushNotificationAPIcall(url: String, parameter: [String: String], token: String, headers: HTTPHeaders) {
        
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        
        
        Alamofire.request(url, method: .post, parameters: parameter, headers: headers).responseJSON {
            response in
            if response.result.isSuccess {
                print("SUCCESSFUL.....", "I try to register token")
                
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
                //print(decriptorJson)
                
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                
                
                
                if(status) {
                    self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    print("COnnected push notification successful")
                    
                }
                else {
                    self.loginButton.isHidden = false
                    
                    self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    let alertService = AlertService()
                    let alertVC =  alertService.alert(alertMessage: "\(message)")
                    self.present(alertVC, animated: true)
                    
                }
            }
            else {
                self.loginButton.isHidden = false
                self.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                
                let alertService = AlertService()
                let alertVC =  alertService.alert(alertMessage: "Network Error")
                self.present(alertVC, animated: true)
            }
        }
    }

    //navigate to security question
    func gotoVerification () {
        
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "newDevice") as? NewDeviceLoginViewController
        vc!.securityQuestion = securityQuestion
        vc!.sessionID = sessionID
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "" {
            let destination = segue.destination as! SecurityQuestionViewController
            destination.from_segue = "forgot password"
            self.loginButton.isHidden = !true
            
        }
    }
}

open class LocalAuth: NSObject {
    
    public static let shared = LocalAuth()
    
    private override init() {}
    
    var laContext = LAContext()
    
    func canAuthenticate() -> Bool {
        var error: NSError?
        let hasTouchId = laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        return hasTouchId
    }
    
    func hasTouchId() -> Bool {
        if canAuthenticate() && laContext.biometryType == .touchID {
            return true
        }
        return false
    }
    
    func hasFaceId() -> Bool {
        if canAuthenticate() && laContext.biometryType == .faceID {
            return true
        }
        return false
    }
    
}










