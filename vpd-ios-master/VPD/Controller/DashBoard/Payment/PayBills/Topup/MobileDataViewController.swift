//
//  MobileDataViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 09/10/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class MobileDataViewController: UIViewController, UITextFieldDelegate  {

    @IBOutlet var viewWrapper: UIView!
   
    @IBOutlet weak var phoneNumberTextField: DesignableUITextField!
    @IBOutlet weak var serviceTextField: DesignableUITextField!
    @IBOutlet weak var walletTextField: DesignableUITextField!
    @IBOutlet weak var topupTextField: DesignableUITextField!
    @IBOutlet weak var topupButton: DesignableButton!
    @IBOutlet weak var dropDownButton: UIButton!
    @IBOutlet weak var dropDownTextField: UITextField!
    
    @IBOutlet weak var dropDownView: UIView!
    @IBOutlet weak var buttonTitle: DesignableButton!
    
    //for Hideable views
    @IBOutlet weak var serviceProviderLabel: UILabel!
    @IBOutlet weak var servicesProviderLabel: UILabel!
    @IBOutlet weak var walletLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var convenienceFeeLabel: UILabel!
    
    @IBOutlet weak var serviceProviderLableTopConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var serviceProviderTextFieldConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var amountTextFieldHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var walletTextFieldHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    @IBOutlet weak var vpdPinTextLabel: UILabel!
    @IBOutlet weak var vpdPinTextField: UITextField!

    var fee_for_trans = LoginResponse["response"]["charges"]["airtime_convenience_fee"]["NGN"]["value"].stringValue
    
    var banks = ["First Bank", "Access Bank"]
    //*******Initializing array to be populated**********//
    var countryDatas: [DataOBjectClass]?  = []
    
    let piker1 = UIPickerView()
    let piker2 = UIPickerView()
    var from_segue = ""
    var phone_number = ""
    
    //For API
    var plan_id = ""
    var wallet_id = ""
    var message = ""
    var type = ""
    var amount = ""
    
    var user_number = Profile["response"]["phone"].stringValue
    var to_send_number = ""
    var number_with_code = ""
    var vpdPin = ""
    var transaction_face = face
    
    
    var selected_data = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        convenienceFeeLabel.text = "You'll be charged NGN\(fee_for_trans) convenience fee for this."
        // Do any additional setup after loading the view.
        print(from_segue, type)
        
        if type == "airtime" {
            convenienceFeeLabel.isHidden = true
        }
        
        
        serviceTextField.delegate = self;
        phoneNumberTextField.delegate = self;
        walletTextField.delegate = self;
        topupTextField.delegate = self;
        vpdPinTextField.delegate = self;
        
        serviceTextField.setLeftPaddingPoints(15);
        phoneNumberTextField.setLeftPaddingPoints(10);
        walletTextField.setLeftPaddingPoints(15);
        topupTextField.setLeftPaddingPoints(15);
        vpdPinTextField.setLeftPaddingPoints(15)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        viewWrapper.addGestureRecognizer(tap);
        
        
        let dropDown = UITapGestureRecognizer(target: self, action: #selector(self.dropDown(_:)))
        dropDownView.addGestureRecognizer(dropDown)
        
        
         //serviceProviderLabel.isHidden = true
        servicesProviderLabel.isHidden = true
         walletLabel.isHidden = true
        dropDownButton.isHidden = true
         amountLabel.isHidden = true
         serviceProviderLableTopConstraint.constant = 0 // 25
         serviceProviderTextFieldConstraintHeight.constant = 0 // 45
         walletTextFieldHeightConstraint.constant = 0 // 45
         amountTextFieldHeightConstraint.constant = 0  // 45
        
        
        piker1.dataSource = self
        piker1.delegate = self
        
        piker2.delegate = self
        piker2.dataSource = self
        
        walletTextField.inputView = piker1
        dropDownTextField.inputView = piker2
        
        phoneNumberTextField.addTarget(self, action: #selector(removeZero), for: UIControl.Event.editingChanged)
        
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
        
        dropDownTextField.inputAccessoryView = toolBar
        walletTextField.inputAccessoryView = toolBar
        vpdPinTextField.inputAccessoryView = toolBar;
        topupTextField.inputAccessoryView = toolBar;
        
        fetchJsonFromFile()
        
        buttonTitle.setTitle("Recharge\(user_number)", for: .normal);
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
        print(textField.tag, ",,......")
        if textField.tag == 2 || textField.tag == 1  {
           
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
    
    //***********Method to handle date format and date dismiss*********//
    @objc func donePicker(datePicker: UIDatePicker) {
        view.endEditing(true)
        vpdPin = vpdPinTextField.text!
        view.frame.origin.y = 0
        
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        // handling code
        view.frame.origin.y = 0
        phoneNumberTextField.endEditing(true)
        topupTextField.endEditing(true)
        dropDownTextField.endEditing(true)
    }
    
    @objc func dropDown(_ sender: UITapGestureRecognizer? = nil) {
        // handling code
        walletTextField.becomeFirstResponder()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        serviceTextField.endEditing(true)
        phoneNumberTextField.endEditing(true)
        
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 1 {
            topupButton.setTitle("Validate Number", for: .normal)
        }
        
        return true
    }
    
    //**********Remove User Zero **********//
    @objc func removeZero() {
        if (self.phoneNumberTextField.text?.hasPrefix("0"))! {
            self.phoneNumberTextField.text?.remove(at:(self.phoneNumberTextField.text?.startIndex)!)
        }
    }
    
    //MARK: Get country code from countries json file
    func fetchJsonFromFile() {
        
        guard let path = Bundle.main.path(forResource: "country_flag_calling_code", ofType: "json") else {print("NO path found"); return}
        let url = URL(fileURLWithPath: path)
        
        ///////////////Empty article array/////////////////
        self.countryDatas = [DataOBjectClass]()
        
        do {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            
            guard let array = json as? [Any] else { return }
            for country in array {
                
                let dataObject = DataOBjectClass()
                
                guard let countryData = country as? [String: AnyObject] else {return}
                if let country_name = countryData["name"] as? String,
                    let country_isIso = countryData["isoAlpha3"] as? String,
                    let calling_code = countryData["calling_code"] as? String,
                    let currency = countryData["currency"]!["code"] as? String,
                    let currency_name = countryData["currency"]!["name"] as? String,
                    let country_flag = countryData["flag"] as? String {
                    
                    dataObject.labelText = country_name
                    dataObject.imageUrl = country_flag
                    dataObject.isIso = country_isIso
                    dataObject.countryCallCode = calling_code
                    dataObject.currency = currency
                    dataObject.currency_name = currency_name
                }
                
                self.countryDatas?.append(dataObject)
                
            }
        }catch {
            print(error)
        }
    }
    
    
    func callTopAirtimeAPI(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        
        if user_number == phone_number {
            number_with_code = phone_number
            to_send_number = number_with_code
        }
        else {
            number_with_code = "\(dropDownTextField.text ?? "")\(phone_number)"
            to_send_number = number_with_code
        }
        
            
      
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "type": "airtime", "operation": "getprovider", "phone": number_with_code]
        
        
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
        
        
        
        let url = "\(utililty.url)topup_payment"
        
        postData(url: url, parameter: parameter, token: token, header: headers)
    }
    
    ///////////***********Post Data MEthod*********////////
    func postData(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        self.activityIndicator.startAnimating()
        self.topupButton.isHidden = true
        
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
                    self.activityIndicator.stopAnimating()
                    self.topupButton.isHidden = false
                    //********Response from server *******//
                    self.servicesProviderLabel.isHidden = false
                    self.walletLabel.isHidden = false
                    self.amountLabel.isHidden = false
                    self.dropDownButton.isHidden = false
                    self.serviceProviderLableTopConstraint.constant = 25 // 0
                    self.serviceProviderTextFieldConstraintHeight.constant = 45 // 0
                    self.walletTextFieldHeightConstraint.constant = 45 // 0
                    self.amountTextFieldHeightConstraint.constant = 45  // 0
                    self.vpdPinTextLabel.isHidden = false
                    self.vpdPinTextField.isHidden = false
                    
                    //for updating UI
                    self.amountLabel.text = "Enter top-up amount(100 - \(decriptorJson["response"]["plan"][0]["max"].stringValue))"
                    self.serviceTextField.text = decriptorJson["response"]["operator"].stringValue
                    
                    if self.type == "airtime" {
                        self.topupButton.setTitle("Next", for: .normal)
                    }
                        
                    else {
                        self.topupButton.setTitle("Top Up", for: .normal)
                    }
                    
                    self.plan_id = decriptorJson["response"]["plan"][0]["id"].stringValue
                    //add to picker array and reload picker here
                    
                }
                
                else if  message == "Session has expired" {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.activityIndicator.stopAnimating()
                    self.topupButton.isHidden = false
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.activityIndicator.stopAnimating()
                self.topupButton.isHidden = false
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    
    @IBAction func number_button_pressed(_ sender: Any) {
        
        phoneNumberTextField.text! = user_number.toLengthOf(length: 4)
    
        phone_number = phoneNumberTextField.text!

        callTopAirtimeAPI()
        
    }
    
    //MARK: Class IBACTIONS Declearations
    @IBAction func dropDownButtonPressed(_ sender: Any) {
        walletTextField.becomeFirstResponder()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func topupButtonPressed(_ sender: Any) {
         vpdPin = vpdPinTextField.text!
        if topupButton.titleLabel?.text == "Validate Number" &&  phoneNumberTextField.text != "" {
            phoneNumberTextField.endEditing(true)
            phone_number = phoneNumberTextField.text!
            callTopAirtimeAPI()
            return
        }
        
        if type == "airtime" && topupTextField.text != "" && phoneNumberTextField.text != "" && serviceTextField.text != "" && wallet_id != "" && vpdPin != "" {
            
            amount = topupTextField.text!
            
            print(type, phone_number, amount, plan_id, wallet_id, "From page ............air time")
            phone_number = phoneNumberTextField.text!
            performSegue(withIdentifier: "goToRecurring", sender: self)
            return
        }
        
        if topupButton.titleLabel?.text != "Validate Number" && wallet_id == "" {
            let alertService = AlertService()
            let alertVC =  alertService.alert(alertMessage: "Please Select Wallet currency")
            self.present(alertVC, animated: true)
            return
        }
        
        
        if topupTextField.text != "" && phoneNumberTextField.text != "" && serviceTextField.text != "" && walletTextField.text != "" && vpdPin != "" {
            
            if transaction_face && isUserFace == false {
                let alertSV = FaceID()
                let alert = alertSV.showFaceID()
                self.present(alert, animated: true)
            }
            else {
                purchaseAPI()
            }
            
            return
        }
       
        else {
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "Please fill all fields")
             self.present(alertVC, animated: true)
        }
    }
    
    
    @IBAction func dropDownButton2Pressed(_ sender: Any) {
        dropDownTextField.inputView = piker2
    }
    
    
    func purchaseAPI(){
        
        let amount = topupTextField.text
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()

    
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        if UserDefaults.standard.object(forKey: "authKey") != nil && transaction_face  {
            global_key = UserDefaults.standard.string(forKey: "authKey")!
        }
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "type": "airtime", "operation": "purchase", "phone": number_with_code, "wallet": wallet_id, "plan": plan_id, "amount": amount, "transaction_pin": vpdPin, "auth_key": global_key]
        
        
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
        
        
        
        let url = "\(utililty.url)topup_payment"
        
        postData2(url: url, parameter: parameter, token: token, header: headers)
        global_key = ""
        isUserFace = false
    }

    ///////////***********Post Data MEthod*********////////
    func postData2(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        self.activityIndicator.startAnimating()
        self.topupButton.isHidden = true
        
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
                    self.message = message
                    self.activityIndicator.stopAnimating()
                    let alertSV = SuccessAlertTransaction()
                    let alert = alertSV.alert(success_message: message) {
                        guard let VCS = self.navigationController?.viewControllers else {return }
                        for controller in VCS {
                            if controller.isKind(of: TabBarViewController.self) {
                                let tabVC = controller as! TabBarViewController
                                tabVC.selectedIndex = 0
                                self.navigationController?.popToViewController(ofClass: TabBarViewController.self, animated: true)
                                
                            }
                        }
                    }
                    self.present(alert, animated: true)
                    //add to picker array and reload picker here
                    
                }
                
                else if  message == "Session has expired" {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.activityIndicator.stopAnimating()
                    self.topupButton.isHidden = false
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.activityIndicator.stopAnimating()
                self.topupButton.isHidden = false
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    
   //MARK:- Segue declearation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "fromAirTime" {
            let destination = segue.destination as! FailedControllerViewController
            destination.from_segue = message
        }
        
        if segue.identifier == "goToRecurring" {
            let destination = segue.destination as! RecurrenceViewController
            destination.type = type
            destination.phone = "+234\(phone_number)"
            destination.amount = amount
            destination.plan = plan_id
            destination.wallet = wallet_id
            destination.vpdPin = vpdPin
        }
    }

}


extension MobileDataViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == piker1 {
            return accountArray.count
        }
        if pickerView == piker2 {
            return countryDatas!.count
        }
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       
        if pickerView == piker1 {
            return accountArray[row].currency
        }
        if pickerView == piker2  {
            let cellDic = countryDatas![row]
            return cellDic.labelText
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == piker1 {
            walletTextField.text = "\(accountArray[row].currency) - Wallet"
            wallet_id = accountArray[row].wallet_uid
           
        }
        else {
            let cellDic = countryDatas![row]
            print(cellDic.countryCallCode ?? "")
            dropDownTextField.text = "+\(cellDic.countryCallCode ?? "" )"
           
        }
        
       
    }
    
}


extension String {

  func toLengthOf(length:Int) -> String {
            if length <= 0 {
                return self
            } else if let to = self.index(self.startIndex, offsetBy: length, limitedBy: self.endIndex) {
                return self.substring(from: to)

            } else {
                return ""
            }
        }
}



    


    

        

        
        

        

    

    

    
    




