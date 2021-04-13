//
//  SignUpViewControllerPage7.swift
//  VPD
//
//  Created by Ikenna Udokporo on 10/05/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SignUpViewControllerPage7: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var bvn: String!
    var longitude: String!
    var latitude: String!
    var accountType: String!
    var mobile: String!
    var country: String!
    var fullname: String!
    var dob: String!
    var email: String!
    var username: String!
    var question: String!
    var answer: String!
    var password: String!
    
    
    //For Business segue
    var business_category = ""
    var business_name = ""
    var business_reg_no = ""
    var photoID = ""
    var businessCert = ""
    var utilityBills = ""
    
    var message = ""

    
    var fromPhoneVerification = ""
    
    var security_question = [String]()

    
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var answerLable: UILabel!
    @IBOutlet weak var answerTextFieldView: UIView!
    @IBOutlet weak var viewWrapper: UIView!
    @IBOutlet weak var securityQuestionTextField: UITextField!
    
    
    var securityQuestion: String?
    var securtiyAnswer = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.//
        
        self.answerTextField.delegate = self
        self.securityQuestionTextField.delegate = self
        
        self.answerTextField.setLeftPaddingPoints(15)
        self.securityQuestionTextField.setLeftPaddingPoints(15)
        
        securityQuestionTextField.text = "Mother's maiden name?"
        
        creatPicker()
        
        //print(fromPhoneVerification)
        delayToNextPageProfile()
    }
    
    //MARK: ******* Profile API Call******///
    func delayToNextPageProfile(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "latitude": latitude, "longitude": longitude]
        
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
        
        
        let url = "\(utililty.url)geolocation"
        
        postData(url: url, parameter: parameter, token: token, header: headers)
    }
    
    
    ///////////***********Post Data MEthod*********////////
    func postData(url: String, parameter: [String: String], token: String, header: [String: String]) {

        self.activityIndicator.startAnimating()
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
                print(decriptorJson)

                LoginResponse = decriptorJson

                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                
                //let session = decriptorJson["response"]["session"].stringValue
            
                if(status) {
                    self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    let sec_qestion = decriptorJson["response"]["securityQuestions"].arrayValue
                    for i in sec_qestion {
                        print(i)
                        self.security_question.append(i.stringValue)
                    }
                }
                    
                else {
                    //*******check if delegate is not nil*********
                    //**** Animate UI indicator ****/
                    self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    
                    //******From the alert Service*************//
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                    self.message = message
                }
            }
            else {
                self.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                //******From the alert Service*************//
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Network Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissPickerView)))
    }
    
    @objc func dismissPickerView(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
        viewWrapper.frame.origin.y = CGFloat(viewJumpHeight * 2 + 10)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            NsInformation()
        }
    }
    
    ////Hide Keboard on Return pressed********///
    //*********Make view move up when keyboard shows**********//
    let viewJumpHeight = 10
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        viewWrapper.frame.origin.y = CGFloat(viewJumpHeight * 2 + 10)
        return false
    }
    
    ///Move button up
    @objc func keyboardWillChange(notification: Notification){
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification{
            viewWrapper.frame.origin.y = CGFloat(-viewJumpHeight)
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    
    @IBAction func nextButtonPressed(_ sender: Any){
        
        answerTextField.resignFirstResponder()
        
        if(answerTextField.text == ""){
            ///*****************Initializing alert Service Class************////////////
            let alertService = AlertService()
            //=========lalert user to enter a valid number======//
            let alertVC =  alertService.alert(alertMessage: "Invalid input field")
            self.present(alertVC, animated: true)
        }
        else {
            question = securityQuestionTextField.text
            answer = answerTextField.text
            performSegue(withIdentifier: "goToSVC8", sender: self)
        }
        
    }
    
    @IBAction func dropDownButtonPressed(_ sender: Any) {
        securityQuestionTextField.becomeFirstResponder()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let SVC8 = segue.destination as! SignUpViewControllerPage8
        SVC8.accountType = accountType
        SVC8.bvn = bvn
        SVC8.longitude = longitude
        SVC8.latitude = latitude
        SVC8.mobile = mobile
        SVC8.country = country
        SVC8.fullname = fullname
        SVC8.dob = dob
        SVC8.email = email
        SVC8.username = username
        SVC8.question = question
        SVC8.answer = answer
        SVC8.password = password
        
        //For Business segue
        SVC8.business_category = business_category
        SVC8.business_name = business_name
        SVC8.business_reg_no = business_reg_no
        SVC8.photoID = photoID
        SVC8.businessCert = businessCert
        SVC8.utilityBills = utilityBills
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}


extension SignUpViewControllerPage7: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return security_question.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return security_question[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if security_question.count > 1 {
            securityQuestionTextField.text = security_question[row]
            question = securityQuestionTextField.text
        }
        
    }
    
    func creatPicker() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        
        securityQuestionTextField.inputView = pickerView
    }
}

