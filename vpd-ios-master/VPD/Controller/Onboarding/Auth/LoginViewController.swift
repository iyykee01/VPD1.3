//
//  LoginViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 20/04/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//


import UIKit
import Alamofire
import SwiftyJSON
import Intercom


var LoginResponse: JSON!
var Profile: JSON!
var user_name = ""

var account_number_g = ""
var invite_url = ""

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    
    var username: String!
    var password: String!
    var securityQuestion = ""
    var sessionID = ""
    var accountNumber = ""
    
    
    @IBOutlet weak var remember_details_image: UIImageView!
    @IBOutlet weak var remember_details_button: UIButton!
    ////Login page Outlets
    @IBOutlet weak var labelText1: UILabel!
    @IBOutlet weak var labelText2: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var LoginButton: UIButton!
    @IBOutlet weak var labelForEmailOrUsername: UILabel!
    @IBOutlet weak var labelForPasswordField: UILabel!
    @IBOutlet weak var signUpLinkButton: UIButton!
    @IBOutlet weak var show_password: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let yourAttributes : [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15),
        NSAttributedString.Key.foregroundColor : UIColor.white,
        NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]
    
    
    var errorFromLoader = ""
    var message = ""
    var username_details = ""
    var save_login_details = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let attributeString = NSMutableAttributedString(string: "Sign Up Now",
                                                        attributes: yourAttributes);
        signUpLinkButton.setAttributedTitle(attributeString, for: .normal)
        
        
        usernameTextField.delegate  = self
        passwordField.delegate = self
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.tappedMe))
        remember_details_image.addGestureRecognizer(tap)
        remember_details_image.isUserInteractionEnabled = true
    }
    
    @objc func tappedMe(){
        print("Tapped on Image")
        rememberlogin()
    }
    
    
    
    //TextField should return //
    //Text field should return and close keyboard//
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        passwordField.resignFirstResponder()
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        username_details =  UserDefaults.standard.string(forKey: "username") ?? ""
        
        if username_details != "" {
            remember_details_image.backgroundColor = .clear
            remember_details_image.image = UIImage(named: "checked")
            
            usernameTextField.text = username_details
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn], animations: {
                self.labelForEmailOrUsername.transform = CGAffineTransform(translationX: 0, y: -30)
            })
        }
        else {
            remember_details_image.backgroundColor = .lightGray
            remember_details_image.image = UIImage(named: "")
            
        }
    }
    
    ////Animation for text field on logIn/Signup screen
    override func viewWillAppear(_ animated: Bool) {
        
        ////From the alert Service
        let alertService = AlertService()
        
      usernameTextField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleInputAnimation)))
        passwordField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleInputAnimation2)))
        
        
        
        if message != "" {
            let alertVC =  alertService.alert(alertMessage: "\(message)")
            present(alertVC, animated: true)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print(textField.tag)
        if textField.tag == 1 {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        }
        else {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
            view.frame.origin.y = 0
        }
    }
    
    //MARK: - Change segue inside button
    @IBAction func goToForgetPassword(_ sender: Any) {
        performSegue(withIdentifier: "goToForgetPassword", sender: nil)
    }
    
    //method to handle user inputs
    //Use input value eg. show alert
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        ////From the alert Service
        let alertService = AlertService()
        
        if(usernameTextField.text == "" || passwordField.text == ""){
            let alertVC =  alertService.alert(alertMessage: "Please complete each fields ")
            present(alertVC, animated: true)
        }
        else {
            username = usernameTextField.text!
            password = passwordField.text!
            
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
        print(device.sha512, "......from login device")
        
        //dob = '02-04-1999'
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "username": username, "password": password]
        
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
        
        let url = "\(utililty.urlv3)login"
        
        //utililty.postData(path: url, paramter: parameter, headers: headers)
        
        postData(url: url, parameter: parameter, token: token, header: headers)
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
        
        profileApiCall(url: url, parameter: parameter, token: token, header: headers)
    }
    
    
    ///////////***********Post Data MEthod*********////////
    func postData(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        
        
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
                
                LoginResponse = decriptorJson
                
                print(decriptorJson)
                
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                self.securityQuestion = decriptorJson["response"]["securityQuestion"].stringValue
                let session = decriptorJson["response"]["session"].stringValue
                
                
                if(status && message == "Security verification required") {
                    self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    self.sessionID = session
                    UserDefaults.standard.set(session, forKey: "SessionID")
                    UserDefaults.standard.synchronize()
                    self.gotoVerification()
                    
                }
                    
                else if status == true {
                    
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
                    UserDefaults.standard.set(session, forKey: "SessionID")
                    UserDefaults.standard.set(customer_id, forKey: "CustomerID");
                    
                    
                    let userName = self.usernameTextField.text!
                    let last_name = LoginResponse["response"]["lastname"].stringValue
                    let first_name = LoginResponse["response"]["firstname"].stringValue
                    let fullName = "\(last_name) \(first_name)"
                    UserDefaults.standard.set(userName, forKey: "userName");
                    UserDefaults.standard.set(fullName, forKey: "fullName");
                    UserDefaults.standard.synchronize()
                    
                    Intercom.registerUser(withUserId: session)
                    self.delayToNextPageProfile()
                }
                else {
                    
                    self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    let alertService = AlertService()
                    let alertVC =  alertService.alert(alertMessage: "\(message)")
                    self.present(alertVC, animated: true)
                    
                }
            }
            else {
                self.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                
                let alertService = AlertService()
                let alertVC =  alertService.alert(alertMessage: "Network Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    
    ///////////***********Post Data MEthod*********////////
    func profileApiCall(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        
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
                //print(decriptorJson)
                
                //*******Parameters for successful response and for data response*******///
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                
                if(status) {
                    Profile = decriptorJson
                    self.usernameTextField.text = ""
                    self.passwordField.text = ""
                    self.performSegue(withIdentifier: "goToDashboard", sender: self)
                    
                    //*****Perform segue to dashboard**********
                    self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    self.pushNotification_call()
                    
                }
                else {
                    //*******check if delegate is not nil*********
                    self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    
                    let alertService = AlertService()
                    let alertVC =  alertService.alert(alertMessage: "\(message)")
                    self.present(alertVC, animated: true)
                }
            }
            else {
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
        
        print(device_id, ".................from page 395")
        
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
        
        pushNotificationAPIcall(url: url, parameter: parameter, token: token, header: headers)
    }
    
    
    ///////////***********Post Data MEthod*********////////
    func pushNotificationAPIcall(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        
        
        Alamofire.request(url, method: .post, parameters: parameter, headers: header).responseJSON {
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
                    
                    self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    let alertService = AlertService()
                    let alertVC =  alertService.alert(alertMessage: "\(message)")
                    self.present(alertVC, animated: true)
                    
                }
            }
            else {
                self.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                
                let alertService = AlertService()
                let alertVC =  alertService.alert(alertMessage: "Network Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    func gotoVerification () {
        performSegue(withIdentifier: "goToNewDeviceLogin", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToSecurtiyQuestion" {
            let LSVC = segue.destination as! SecurityQuestionViewController
            LSVC.from_segue = "forgot password"
            //LSVC.delegate = self
        }
        
        if segue.identifier == "" {
            let destination = segue.destination as! SecurityQuestionViewController
            destination.from_segue = "forgot password"
            
        }
        
        
        if segue.identifier == "goToNewDeviceLogin" {
            let SQVC = segue.destination as! NewDeviceLoginViewController
            SQVC.securityQuestion = securityQuestion
            SQVC.sessionID = sessionID
        }
    }
    
    @IBAction func rememberLoginDetailsPressed(_ sender: Any) {
        rememberlogin()
    }
    
    func rememberlogin() {
        save_login_details = !save_login_details
        
        if save_login_details {
            let username = usernameTextField.text
            UserDefaults.standard.set(username, forKey: "username")
            UserDefaults.standard.synchronize()
            remember_details_image.backgroundColor = .clear
            remember_details_image.image = UIImage(named: "checked")
            
        }
        else {
            let username = ""
            UserDefaults.standard.set(username, forKey: "username")
            UserDefaults.standard.synchronize()
            remember_details_image.backgroundColor = .lightGray
            remember_details_image.image = UIImage(named: "")
            
        }
    }
    
    
    
    var showPassword: Bool = false
    
    func togglePassword() {
        showPassword.toggle()
        
        if showPassword {
            passwordField.isSecureTextEntry = false
            show_password.setTitle("Hide", for: .normal)
        }
        else {
            show_password.setTitle("Show", for: .normal)
            passwordField.isSecureTextEntry = true
        }
    }
    
    @IBAction func showPasswordButtonPressed(_ sender: Any) {
        togglePassword()
    }
    
    ///////Review for Optimazation
    //-------> Looking out for "DRY" <------//
    @objc func handleInputAnimation () {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn], animations: {
            self.labelForEmailOrUsername.transform = CGAffineTransform(translationX: 0, y: -30)
        }){ (finished)  in
            self.usernameTextField.becomeFirstResponder()
        }
    }
    
    @objc func handleInputAnimation2() {
        //print("Animatteddd")
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn], animations: {
            self.labelForPasswordField.transform = CGAffineTransform(translationX: 0, y: -30)
        }){ (finished)  in
            self.passwordField.becomeFirstResponder()
        }
    }
    
}



