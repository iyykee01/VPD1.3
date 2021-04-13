//
//  SignUpViewControllerPage4.swift
//  VPD
//
//  Created by Ikenna Udokporo on 25/04/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SignUpViewControllerPage4: UIViewController, UITextFieldDelegate {
    
    var bvn: String!
    var mobile: String!
    var country: String!
    var longitude: String!
    var latitude: String!
    var accountType: String!
    
    

    @IBOutlet weak var BvnInputField: UITextField!
    @IBOutlet weak var BvnButton: UIButton!
    @IBOutlet weak var buttonWrapper: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var buttonUI: UIButton!
    @IBOutlet weak var viewConstrainst: NSLayoutConstraint!
    
    
    
    
    //////======for Underlined Button======///////
        let yourAttributes : [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: UIFont.Weight(rawValue: 1.0)),
            NSAttributedString.Key.foregroundColor : UIColor.lightGray,
            NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]
    
    
    var x: CGRect!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addCornerRaduis()
        underlineButton()
        activityIndicator.isHidden = true
        
        BvnInputField.setPadding()
        BvnInputField.delegate = self
        
    }
    
    
    //*************************************************//
    //***********//*****************//***************************
    /***********************/
    func delayToNextPage(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        
        bvn  = BvnInputField.text
        
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "phone": mobile, "validate": bvn]
     
        
        
        
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
        
        let url = "\(utililty.url)bvn_info"
        postData(url: url, parameter: parameter, token: token, header: headers)
        
    }
    
    
    func postData(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        //**** Animate UI indicator ****/
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        buttonUI.isHidden = true
        
//        ///Sucessful alert
//        let successService = SuccessService()
        
        
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
                
                
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                
                
                if(status) {
                    //**** Animate UI indicator ****/
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.buttonUI.isHidden = false
                    self.performSegue(withIdentifier: "goToSVC5", sender: self)
                }
                else {
                    //**** Animate UI indicator ****/
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.buttonUI.isHidden = false
                    
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC =  alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
                
            }
            else {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.buttonUI.isHidden = false
                
                ////From the alert Service
                let alertService = AlertService()
                let alertVC =  alertService.alert(alertMessage: "Connection Timed Out")
                self.present(alertVC, animated: true)
            }
        }
    }

    

    //Stop listening for keyboard hide/show events//////
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    
    func NsInformation(){
        //Listen for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name:
            UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    ///Move button up
    @objc func keyboardWillChange(notification: Notification){
        
        guard let info = notification.userInfo else { return }
        guard let frameInfo = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = frameInfo.cgRectValue
        
        let keyboardHeight = Int(keyboardFrame.height)
        
        print(keyboardHeight)
        
        
        
        UIView.animate(withDuration: 0.1){
            self.viewConstrainst.constant = CGFloat(keyboardHeight + 90)
            self.view.layoutIfNeeded()
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        NsInformation()
    }
    
    
    ///Callback that triggers the resendcode button
    var successCodeAction: (() -> Void)?
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        ////From the alert Servic
        
        viewConstrainst.constant = 90
        BvnInputField.resignFirstResponder()
        
        let alertService = AlertService()
        if(BvnInputField.text == ""){
            let alertVC = alertService.alert(alertMessage: "Please Enter Your BVN")
            self.present(alertVC, animated: true)
        }
        else{
            bvn = BvnInputField.text
            delayToNextPage()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSVC5" {
            let SVC5 = segue.destination as! SignUpViewControllerPage5
            SVC5.accountType = accountType
            SVC5.latitude = latitude
            SVC5.longitude = longitude
            SVC5.country = country
            SVC5.mobile = mobile
            SVC5.bvn = bvn
        }
        
    }
    
    
    //this method adds coner raduis to buttons
    func addCornerRaduis() {
        BvnInputField.layer.cornerRadius = 10;
        BvnInputField.layer.masksToBounds = true;
        BvnInputField.layer.borderWidth = 1.0
        BvnInputField.layer.borderColor = UIColor.lightGray.cgColor
    
    }
    
    
    func underlineButton () {
        BvnButton.setTitleColor(.purple, for: .normal)
        let attributeString = NSMutableAttributedString(string: "Can't remember my BVN", attributes: yourAttributes);
        BvnButton.setAttributedTitle(attributeString, for: .normal)
        
    }
    
}


extension UITextField {
    func setPadding() {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.height))
        
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}



