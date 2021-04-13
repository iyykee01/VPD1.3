//
//  SignUpViewControllerPage5.swift
//  VPD
//
//  Created by Ikenna Udokporo on 25/04/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

//**************IF BVN IS PRESENT GO TO RECORD VIDEO**************//

class SignUpViewControllerPage5: UIViewController, UITextFieldDelegate {
    
    var bvn: String!
    var longitude: String!
    var latitude: String!
    var accountType: String!
    var mobile: String!
    var country: String!
    var fullname: String!
    var dob: String!
    var email: String!
    var scanId: String!
    
    
    
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var DOBTextFeild: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var ViewWrapper: UIView!
    @IBOutlet weak var confirmButtonTextField: UIButton!
    @IBOutlet weak var confirmDetailsWrappere: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var buttonUI: UIButton!
    
    
    private var datePicker: UIDatePicker?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addCornerToTextField()
        
        //print(bvn, longitude, latitude, accountType, mobile)
        
        self.fullNameTextField.delegate = self
        self.DOBTextFeild.delegate = self
        self.emailTextField.delegate = self
        
        fullNameTextField.setPadding()
        DOBTextFeild.setPadding()
        emailTextField.setPadding()
        
        anotherMethod()
        activityIndicator.isHidden = true
        
        
        //***********Setting up Date Picker********************//
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        
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
        toolBar.isUserInteractionEnabled = true
        DOBTextFeild.inputAccessoryView = toolBar
        DOBTextFeild.inputView = datePicker
        
        
        print(scanId ?? "No ID CARD STRING FOUND..... line 73")
    }
     
     
    //***********Method to handle date format and date dismiss*********//
    @objc func donePicker(datePicker: UIDatePicker) {
        DOBTextFeild.resignFirstResponder()
        ViewWrapper.frame.origin.y = CGFloat(viewJumpHeight * 2)
    }
    
    
    
    //***********Redirect User to either foreign or local*********/**/
    func bvnPresent() {
        
        if(bvn != nil && accountType == "personal") {
            performSegue(withIdentifier: "UserVC", sender: nil)
        }
        else if (bvn != nil && accountType == "business") {
            performSegue(withIdentifier: "goToBusinessInfo", sender: nil)
        }
        else {
            performSegue(withIdentifier: "goToVideoRecording", sender: nil)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        viewContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewWasTapped)))
    }
    
    
    @objc func viewWasTapped (sender : UITapGestureRecognizer) {
        ViewWrapper.frame.origin.y = CGFloat(viewJumpHeight * 2)
        view.endEditing(true)
    }
    
    
    //***********Method to handle date format and date dismiss*********//
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        DOBTextFeild.text = dateFormatter.string(from: datePicker.date)
        
    }
    
   // Call activeTextField whenever you need to
    func anotherMethod() {
        // self.activeTextField.text is an optional, we safely unwrap it here
        if let activeTextFieldText = self.emailTextField.text {
            print("Active text field's text: \(activeTextFieldText)")
            NsInformation()
            return;
        }
        
        
    }


    @IBAction func confirmButtonPressed(_ sender: Any) {
        
        /*The only time this alert pops up============================*/
        if(fullNameTextField.text != "" || DOBTextFeild.text != "" || emailTextField.text != "") {
            fullname = fullNameTextField.text
            dob = DOBTextFeild.text
            email = emailTextField.text
            delayToNextPage()
        }
        else {
            ////From the alert Service
            let alertService = AlertService()
            //=========lalert user to enter a valid number======//
            let alertVC =  alertService.alert(alertMessage: "Invalid input ")
            self.present(alertVC, animated: true)
        }
        
       
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToVideoRecording" {
            let RecVC = segue.destination as! RecordVideoViewController
            RecVC.accountType = accountType
            RecVC.country = country
            RecVC.longitude = longitude
            RecVC.latitude = latitude
            RecVC.mobile = mobile
            RecVC.fullname = fullNameTextField.text
            RecVC.dob = DOBTextFeild.text
            RecVC.email = emailTextField.text
            
            
        }
            
        else if segue.identifier == "UserVC" {
            let UserVC = segue.destination as! UsernameViewController
            UserVC.accountType = accountType
            UserVC.bvn = bvn
            UserVC.longitude = longitude
            UserVC.latitude = latitude
            UserVC.mobile = mobile
            UserVC.country = country
            UserVC.fullname = fullNameTextField.text
            UserVC.dob = DOBTextFeild.text
            UserVC.email = emailTextField.text
        }
            
        else if segue.identifier == "goToBusinessInfo" {
            let UserVC = segue.destination as! ProvideBusinessInformationViewController
            
            UserVC.accountType = accountType
            UserVC.bvn = bvn
            UserVC.longitude = longitude
            UserVC.latitude = latitude
            UserVC.mobile = mobile
            UserVC.country = country
            UserVC.fullname = fullNameTextField.text!
            UserVC.dob = DOBTextFeild.text!
            UserVC.email = emailTextField.text!
        }
        
    }
    
    
    //++++++=========Delay function @if token is true move to next page+++++++===========//
    func delayToNextPage(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        
        //dob = '02-04-1999'
        //******getting parameter from string
        let fullname = fullNameTextField.text
        let email = emailTextField.text
        let dob = DOBTextFeild.text

        
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "bvn": bvn, "fullname": fullname, "email": email, "dob": dob]
        
        let jsonEncode = JSONEncoder()
        let jsonData = try! jsonEncode.encode(params)
        let json = String(data: jsonData, encoding: .utf8)!
        
        
        //*********converting shaDeivcepptiies to hexString*********//
        //*********converting shaDeivcepptiies to hexString*********//
        let hexShaDevicePpties = utililty.convertToHexString(json)
        //print(hexShaDevicePpties)
        
        
        let parameter = ["reqData": hexShaDevicePpties]
        
        let token = UserDefaults.standard.string(forKey: "Token")!
        
        let headers: HTTPHeaders = ["X-Authorization": token, "AppGroup": "IOS"]
        
        //*******Url String defined************//
        let url = "\(utililty.url)bvn_info"
        postData(url: url, parameter: parameter, token: token, header: headers)
        
    }
    
    
    func postData(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
//        ////From the alert Service
//        let successPopUp = SuccessService()
        
        ////From the alert Service
        let alertService = AlertService()
        
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
                /******Import  and initialize Util Class*****////
                let utililty = UtilClass()
                let decriptor = utililty.convertHexStringToString(text: hexKey)
                
                //**********Changing Data back to Json format***///
                let jsonData = decriptor.data(using: .utf8)!
                let decriptorJson: JSON = JSON(jsonData)
                
                
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                let score = decriptorJson["response"]["score"].intValue
                
                
                if(status && message == "Details validated" && score > 60) {
                    //**** Animate UI indicator ****/
                    self.stopActiveIndicator()
                    //**********Pop Success Alert here***********//
                    //**********On close of alert perform segue to next scene***********//
                    self.bvnPresent()
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

    

    //*********Make view move up when keyboard shows**********//
    let viewJumpHeight = 10
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        ViewWrapper.frame.origin.y = CGFloat(viewJumpHeight * 2)
        return false
    }

    ///Move button up
    @objc func keyboardWillChange(notification: Notification){
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification{
            ViewWrapper.frame.origin.y = CGFloat(-viewJumpHeight)
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
    
    
    func addCornerToTextField() {
        fullNameTextField.layer.cornerRadius = 10;
        fullNameTextField.layer.masksToBounds = true;
        fullNameTextField.layer.borderWidth = 0.7
        fullNameTextField.layer.borderColor = UIColor.lightGray.cgColor
        
        DOBTextFeild.layer.cornerRadius = 10;
        DOBTextFeild.layer.masksToBounds = true;
        DOBTextFeild.layer.borderWidth = 0.7
        DOBTextFeild.layer.borderColor = UIColor.lightGray.cgColor
        
        emailTextField.layer.cornerRadius = 10;
        emailTextField.layer.masksToBounds = true;
        emailTextField.layer.borderWidth = 0.7
        emailTextField.layer.borderColor = UIColor.lightGray.cgColor

        confirmButtonTextField.layer.cornerRadius = 5;
        confirmButtonTextField.layer.masksToBounds = true;
    }
    
}



