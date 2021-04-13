//
//  NewPasswordViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 29/11/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NewPasswordViewController: UIViewController, UITextFieldDelegate, seguePerform {
    
    

    @IBOutlet weak var passwordStrengthLabel: UILabel!
    @IBOutlet weak var colorRedView: UIImageView!
    @IBOutlet weak var colorYellowView: UIImageView!
    @IBOutlet weak var colorGreenView: UIImageView!
    @IBOutlet weak var passwordClickabelVIew: UIView!
    @IBOutlet weak var confirmPasswordCLickableVIew: UIView!
    @IBOutlet weak var confirmButtonImage: UIButton!
    @IBOutlet weak var passwordButtonImage: UIButton!
    
    
    @IBOutlet weak var passwordStrenght: UILabel!
    
    @IBOutlet weak var viewWrapper: UIView!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var buttonWrapper: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var buttonUI: UIButton!
    
    var passwords = ""
    var token_segue = ""
    var username = ""
    var message = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.]
        print(token_segue, username)
        NsInformation()
        
        //print(bvn, longitude, latitude, accountType, mobile, dob, fullname, dob, username)
        self.password.delegate = self
        self.confirmPassword.delegate = self
        
        activityIndicator.isHidden = true
        
        password.setPadding()
        confirmPassword.setPadding()
        
        
    }
    
    
    
    func goNext(next: String) {
        navigationController?.popToViewController(ofClass: LoginViewController.self)
    }
    
    
    var showPassword: Bool = false
    var showConfirm: Bool = false
    
    
    @IBAction func passwordBtnClicked(_ sender: Any) {
        showPassword.toggle()
        
        if showPassword {
            passwordButtonImage.setImage(UIImage(named: "eye_clicked"), for: .normal)
            password.isSecureTextEntry = false
        }
        else {
            passwordButtonImage.setImage(UIImage(named: "eye"), for: .normal)
            password.isSecureTextEntry = true
        }
    }
    
    
    @IBAction func confirmButtonClicked(_ sender: Any) {
        
        showConfirm.toggle()
        
        if showConfirm {
            confirmButtonImage.setImage(UIImage(named: "eye_clicked"), for: .normal)
            confirmPassword.isSecureTextEntry = false
        }
        else {
            confirmButtonImage.setImage(UIImage(named: "eye"), for: .normal)
            confirmPassword.isSecureTextEntry = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            
            let (capitalresult, numberresult, specialresult) = checkTextSufficientComplexity(text: textField.text!)
            
            
            if capitalresult || numberresult || specialresult {
                print(capitalresult, numberresult, specialresult)
                colorRedView.image = UIImage(named: "red")
                passwordStrengthLabel.text = "Weak"
            }
            
            if (capitalresult && numberresult) || (capitalresult && specialresult) || (specialresult && numberresult) {
                colorYellowView.image = UIImage(named: "yellow")
                passwordStrengthLabel.text = "Medium"
            }
            
            if specialresult && capitalresult && numberresult {
                colorGreenView.image = UIImage(named: "green")
                passwordStrengthLabel.text = "Strong"
            }
            
            if !capitalresult || !numberresult || !specialresult {
                colorRedView.backgroundColor = UIColor.white
                passwordStrengthLabel.text = "Password strength"
            }
        }
        
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 1 {
            
            let (capitalresult, numberresult, specialresult) = checkTextSufficientComplexity(text: textField.text!)
            
            print(capitalresult, numberresult, specialresult)
            
            if capitalresult || numberresult || specialresult {
                print(capitalresult, numberresult, specialresult)
                colorRedView.image = UIImage(named: "red")
                passwordStrengthLabel.text = "Weak"
                
                print(capitalresult, numberresult, specialresult)
            }
            
            
            if (capitalresult && numberresult) || (capitalresult && specialresult) || (specialresult && numberresult) {
                colorYellowView.image = UIImage(named: "yellow")
                passwordStrengthLabel.text = "Medium"
                
                
                print(capitalresult, numberresult, specialresult)
            }
            
            if specialresult && capitalresult && numberresult {
                colorGreenView.image = UIImage(named: "green")
                passwordStrengthLabel.text = "Strong"
                
                
                print(capitalresult, numberresult, specialresult)
            }
                
            else  {
                colorRedView.backgroundColor = UIColor.white
                
            }
            
        }
        
        return true
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


    //MARK:- Delay function @if token is true move to next
    func delayToNextPage(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        
        //dob = '02-04-1999'
        //******getting parameter from string
        passwords = password.text!
        let confirmPassordInput = confirmPassword.text
        
        
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "token": token_segue, "username": username, "password": confirmPassordInput]
        
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
        print("\(token) ..............from app storage")
        
        let headers: HTTPHeaders = ["X-Authorization": token, "AppGroup": "IOS"]
        let url = "\(utililty.url)reset_password"
        postData(url: url, parameter: parameter, token: token, header: headers)
        
    }
    
    
    ///////////***********Post Data MEthod*********////////
    func postData(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
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
                
                /******Import  and initialize Util Class*****////
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
                    self.message = message
                    self.stopActiveIndicator()
                    self.performSegue(withIdentifier: "goToSuccess", sender: self)
                }
                else {
                    //**** Animate UI indicator ****/
                    self.stopActiveIndicator()
                    
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
                
            }
            else {
                self.stopActiveIndicator()
                
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Connection Timed Out")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    func stopActiveIndicator() {
        //**** Animate UI indicator ****/
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        self.buttonUI.isHidden = false
    }
    
    
    func NsInformation(){
        //Listen for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name:
            UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    
    
    ////Hide Keboard on Return pressed********///
    let keyboardRect = 10
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        viewWrapper.frame.origin.y = CGFloat(keyboardRect * 2)
        return false
    }
    
    ///Move button up
    @objc func keyboardWillChange(notification: Notification){
        
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification{
            viewWrapper.frame.origin.y = CGFloat(-keyboardRect)
        }
    }
    
    
    //Stop listening for keyboard hide/show events//////
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    
    @IBAction func buttonPressed(_ sender: Any) {
        
        if(password.text == "" || confirmPassword.text == "" ){

            //=========lalert user to enter a valid number======//
            ////From the alert Service
            let alertService = AlertService()
            let alertVC =  alertService.alert(alertMessage: "Invalid input field")
            self.present(alertVC, animated: true)

        }
        if(password.text != confirmPassword.text){
            //=========lalert user to enter a valid number======//
            ////From the alert Service
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "Passwords Do Not Match ")
            self.present(alertVC, animated: true)
        }
        else {
            passwords = password.text!
            delayToNextPage()
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSuccess" {
            let destination = segue.destination as! Success2LaunchViewController
            destination.message_segue = message
            destination.delegate = self
        }
        
        
    }
    
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    func addCornerToTextField() {
        confirmPassword.layer.cornerRadius = 10;
        confirmPassword.layer.masksToBounds = true;
        confirmPassword.layer.borderWidth = 0.7
        confirmPassword.layer.borderColor = UIColor.lightGray.cgColor
        
        password.layer.cornerRadius = 10;
        password.layer.masksToBounds = true;
        password.layer.borderWidth = 0.7
        password.layer.borderColor = UIColor.lightGray.cgColor
        
    }

}
