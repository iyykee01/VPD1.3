//
//  AuthenticationViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 10/04/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class SignUpViewControllerPage2: UIViewController, GetCounty, UITextFieldDelegate{
    
    @IBOutlet weak var viewContentWrapper: UIView!
    @IBOutlet weak var tochableView: UIView!
    @IBOutlet weak var flagImage: UIImageView!
    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var buttonUI: UIButton!
    
    @IBOutlet weak var viewConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var buttonWrapper: UIView!
    @IBOutlet weak var phoneNumbertextfield: UITextField!
    @IBOutlet weak var verification_Label: UILabel!
    
    //********Recieve the selected country flag*************//
    var countryImage: UIImage!
    var phone = String()
    var Iso: String = ""
    var calling_code: String = ""
    var longitude: String!
    var latitude: String!
    var accountType: String!
    var url = ""
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addCornerRaduis()
        
        countryCodeLabel.text =  "+234" // +\(calling_code)"
        flagImage.image = UIImage(named: "flag")
//        guard countryImage != nil else {
//            flagImage.image = countryImage
//            return
//        }
         
        
        /*********Hiding Indicator and removing 0 from textField**************/
        activityIndicator.isHidden = true
        phoneNumbertextfield.addTarget(self, action: #selector(removeZero), for: UIControl.Event.editingChanged)
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(tap)
        
        phoneNumbertextfield.delegate = self
        
        verification_Label.text = "We will send you a Verification Code on this mobile number"
        
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
        
        phoneNumbertextfield.inputAccessoryView = toolBar
        
    }
    
    @objc func donePicker() {
        phoneNumbertextfield.resignFirstResponder()
    }
    
    
    //*****************Getting country Via Segue****///
    func getCountryObject(countryFlag: UIImage, countryIso: String, countryCode: String) {
        flagImage.image = countryFlag
        Iso = countryIso
        calling_code = countryCode
        countryCodeLabel.text = "+\(countryCode)"
        
    }
    
    
    @objc func closeKeyboard() {
        view.endEditing(true)
    }
    
 
    
    ///Move button up
    @objc func keyboardWillChange(notification: Notification){

        guard let info = notification.userInfo else { return }
        guard let frameInfo = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = frameInfo.cgRectValue
        
        let keyboardHeight = Int(keyboardFrame.height)
        
        print(keyboardHeight)
        
        
        
        UIView.animate(withDuration: 0.1){
            self.viewConstraints.constant = CGFloat(keyboardHeight + 90)
            self.view.layoutIfNeeded()
        }

    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //NsInformation()
    }
    
    func NsInformation(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardDidShowNotification, object: nil)
    }

    //Stop listening for keyboard hide/show events//////
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    //++++++=========Delay function @if token is true move to next page+++++++===========//
    func delayToNextPage(){
        
        //******Import  and initialize Util Class*****////
        let utililty = UtilClass()

        let device = utililty.getPhoneId()
     

        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        self.phone =  "+234\(phoneNumbertextfield.text!)"
        

        let params = ["phone": phone, "AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString]
        print(params)

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

        let url = "\(utililty.url)phone_verify"
        postData(url: url, parameter: parameter, token: token, header: headers)
 
    }


    func postData(url: String, parameter: [String: String], token: String, header: [String: String]) {

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
                        self.stopActiveIndicator()
                        self.performSegue(withIdentifier: "goToSVC3", sender: self)
                    }
                    else {
                        //**** Animate UI indicator ****/
                        self.stopActiveIndicator()
                        let alertVC =  alertService.alert(alertMessage: message)
                        self.present(alertVC, animated: true)
                    }

                }
                else {
                    self.stopActiveIndicator()
                    let alertVC =  alertService.alert(alertMessage: "Connection Timed Out")
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
    

    //**********Remove User Zero **********//
    @objc func removeZero() {
        if (self.phoneNumbertextfield.text?.hasPrefix("0"))! {
            self.phoneNumbertextfield.text?.remove(at:(self.phoneNumbertextfield.text?.startIndex)!)
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        
        if (self.phoneNumbertextfield.text == "") {
            
            ////From the alert Service
            let alertService = AlertService()
            let message = "Please enter a valid phone number"
            
            //=========lalert user to enter a valid number======//
            let alertVC =  alertService.alert(alertMessage: message)
            self.present(alertVC, animated: true)
            phoneNumbertextfield.resignFirstResponder()
        }
        else{
            phone = "+\(calling_code)\(phoneNumbertextfield.text!)"
            phoneNumbertextfield.resignFirstResponder()
            delayToNextPage()
        }
    }
    
    
    @IBAction func backButtonPresse(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func terms_and_conditionButtonPressed(_ sender: Any) {
        url = "https://voguepaydigital.com/terms"
        performSegue(withIdentifier: "goToWebView", sender: self)
    }
    
    
    @IBAction func privacy_policy_pressed(_ sender: Any) {
        url = "https://voguepaydigital.com/privacy"
        performSegue(withIdentifier: "goToWebView", sender: self)
    }
    
    ///************STIll Awaiting to Test******//////////
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToSelectCountry" {
            let destinationVC = segue.destination as! SelectCountryViewController
            destinationVC.delegate = self
        }
        if segue.identifier == "goToWebView" {
            let destination = segue.destination as! WebViewTermsAndConditionViewController
            destination.url_segue = url
        }
        else {
            let SVC3 = segue.destination as! SignUPViewControllerPage3
                SVC3.accountType = accountType
                SVC3.latitude = latitude
                SVC3.longitude = longitude
                SVC3.country = Iso
                SVC3.mobile = phone
                user_phone_number = phone
        }
     }
    
    override func viewWillAppear(_ animated: Bool) {
//        tochableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewWasTapped)))
        
        viewContentWrapper.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewContentWrapperTapped)))
    }

    
    @objc func viewWasTapped (sender : UITapGestureRecognizer) {
        self.tochableView.becomeFirstResponder()
        performSegue(withIdentifier: "goToSelectCountry", sender: self)
    }
    
    @objc func viewContentWrapperTapped (sender : UITapGestureRecognizer) {
        self.viewContentWrapper.endEditing(true)
    }
    
    
    
    
    //this method adds coner raduis to touchable view Wrapper
    func addCornerRaduis() {
        viewContentWrapper.layer.cornerRadius = 10;
        viewContentWrapper.layer.masksToBounds = true;
        viewContentWrapper.layer.borderWidth = 0.5
        viewContentWrapper.layer.borderColor = UIColor.gray.cgColor
        
        flagImage.layer.cornerRadius = 5
        flagImage.layer.masksToBounds = true
    }
}


extension String {
    var boolValue: Bool {
        return NSString(string: self).boolValue
    }
}
