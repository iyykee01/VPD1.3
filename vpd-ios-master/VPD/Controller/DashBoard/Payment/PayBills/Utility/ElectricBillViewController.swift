//
//  ElectricBillViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 02/10/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ElectricBillViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollviewToScroll: UIScrollView!
    @IBOutlet weak var meterNameLabel: UILabel!
    
    @IBOutlet weak var meterNameOutlet: UILabel!
    @IBOutlet weak var selectCompanyTextField: UITextField!
    @IBOutlet weak var paymentPlanTextField: UITextField!
    @IBOutlet weak var meterNumberTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var makePayment: UIButton!
    @IBOutlet weak var viewWrapper: UIView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var walletLabel: UILabel!
    @IBOutlet weak var walletTextField: DesignableUITextField!
    @IBOutlet weak var textFieldView: DesignableView!
    @IBOutlet weak var topContraintForMeterNameLabel: NSLayoutConstraint!
    
    @IBOutlet weak var vpdPinTextLabel: UILabel!
    @IBOutlet weak var vpdPinTextField: UITextField!
  
    @IBOutlet weak var convenienceFeeLabel: UILabel!
    
    
    //Height for textFields
    
    @IBOutlet weak var heightForVPDPin: NSLayoutConstraint! // 30
    @IBOutlet weak var heightForWallet: NSLayoutConstraint! // 47
    @IBOutlet weak var heightForAmount: NSLayoutConstraint! // 45
    @IBOutlet weak var heightForLabelConvinience: NSLayoutConstraint!
    ///********///
    var payment_plan = ["", "Pre-paid", "Post-paid"]
    var meter_name = ""
    var electricity = [ElectricityBills]()
    
    var select_company = false
    
    
    var fee_for_trans = LoginResponse["response"]["charges"]["electricity_convenience_fee"]["NGN"]["value"].stringValue
    
    var meterNumber = ""
    var amountNumber = ""
    var distributor_id = ""
    var paymentPlan = ""
    var caller = 0
    
    let piker1 = UIPickerView()
    let piker2 = UIPickerView()
    let piker3 = UIPickerView()
    
    var walletId = ""
    var vpdPin = ""
    var transaction_face = face
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        convenienceFeeLabel.text = "You'll be charged NGN\(fee_for_trans) convenience fee for this."
        
        self.scrollviewToScroll.isScrollEnabled = false;
        print(electricity, walletId)
        view.isUserInteractionEnabled = false
        // Do any additional setup after loading the view.
        amountLabel.isHidden = true
        amountTextField.isHidden = true
        walletLabel.isHidden = true
        textFieldView.isHidden = true
        walletTextField.isHidden = true
        meterNameLabel.isHidden = true
        meterNameOutlet.isHidden = true
        topContraintForMeterNameLabel.constant = -30 // 30
        
        
        heightForVPDPin.constant = 0 // 30
        heightForWallet.constant = 0// 47
        heightForAmount.constant = 0 // 45
        heightForLabelConvinience.constant = 0 // 100
        
        
        
        selectCompanyTextField.setLeftPaddingPoints(15);
        paymentPlanTextField.setLeftPaddingPoints(15);
        meterNumberTextField.setLeftPaddingPoints(15);
        amountTextField.setLeftPaddingPoints(15);
        walletTextField.setLeftPaddingPoints(15);
        vpdPinTextField.setLeftPaddingPoints(15);
        
        
        selectCompanyTextField.delegate = self
        paymentPlanTextField.delegate = self
        meterNumberTextField.delegate = self
        amountTextField.delegate = self
        vpdPinTextField.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        viewWrapper.addGestureRecognizer(tap)
        
        
        piker1.dataSource = self
        piker1.delegate = self
        
        piker2.dataSource = self
        piker2.delegate = self
        
        piker3.dataSource = self
        piker3.delegate = self
        
        
        selectCompanyTextField.inputView = piker1
        paymentPlanTextField.inputView = piker2
        walletTextField.inputView = piker3
        
        makePayment.isEnabled = false
        
        delayToNextPage2()
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.donePicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false);
        
        meterNumberTextField.inputAccessoryView = toolBar;
        vpdPinTextField.inputAccessoryView = toolBar;
    }
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        // handling code
        viewWrapper.becomeFirstResponder()
        view.endEditing(true)
        meterNumber =  meterNumberTextField.text!
        
        if meterNumber != "" && caller == 0 {
            //Post Data for verification
            caller = 1
            callTvSubAPI()
        }
        if meterNumberTextField.text == "" {
            caller = 0
        }
    }
    
    @objc func donePicker() {
        view.endEditing(true)
        vpdPin = vpdPinTextField.text!
        view.frame.origin.y = 0
        
    }
    
    @objc func keyboardwillChange(notification: Notification) {
        
        guard   let userInfo = notification.userInfo as? [String: NSObject],
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect  else { return }
        
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification  {
            view.frame.origin.y = -keyboardFrame.height
        }
        else {
            view.frame.origin.y = 0
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 4 {
            print(textField.tag)
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
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if (textField.tag == 1 || textField.tag == 2 || textField.tag == 3) && (!meterNumberTextField.text!.isEmpty && !selectCompanyTextField.text!.isEmpty && !paymentPlanTextField.text!.isEmpty) {
            callTvSubAPI();
        }
        
        if !selectCompanyTextField.text!.isEmpty && !paymentPlanTextField.text!.isEmpty && !meterNumberTextField.text!.isEmpty && !amountTextField.text!.isEmpty {
            makePayment.backgroundColor = UIColor(hexFromString: "#34B5CE")
            makePayment.setTitleColor(.white, for: .normal)
            makePayment.isEnabled = true
        }
        else {
            print("nanna")
            makePayment.backgroundColor = .lightGray
            makePayment.titleLabel?.textColor = .darkGray
            makePayment.isEnabled = false
        }
    }
    
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    
    
    //MARK: //MARK: Get Electricity Providers API Call
    //++++++=========Delay function @if token is true move to next page+++++++===========//
    func delayToNextPage2(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "type": "electricity", "operation": "getdistributors"]
        
        
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
        
        
        
        let url = "\(utililty.url)bill_payment"
        
        postData3(url: url, parameter: parameter, token: token, header: headers)
    }
    
    //MARK: Get Electricity Providers
    ///////////***********Post Data MEthod*********////////
    func postData3(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        activityIndicator.startAnimating()
        
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
                    self.view.isUserInteractionEnabled = true
                    self.activityIndicator.stopAnimating()
                    //********Response from server *******//
                    self.electricity = [ElectricityBills]()
                    for i in decriptorJson["response"].arrayValue {
                        let electricity_distributors = ElectricityBills()
                        
                        electricity_distributors.none = ""
                        electricity_distributors.currency = i["currency"].stringValue
                        electricity_distributors.id = i["id"].stringValue
                        electricity_distributors.maxAmount = i["maxAmount"].stringValue
                        electricity_distributors.minAmount = i["minAmount"].stringValue
                        electricity_distributors.name = i["name"].stringValue
                        electricity_distributors.step = i["step"].stringValue
                        electricity_distributors.validation = i["validation"].boolValue
                        
                        self.electricity.append(electricity_distributors)
                    }
                }
                    
                else if (message == "Session has expired") {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.view.isUserInteractionEnabled = true
                    ////From the alert Service
                    self.activityIndicator.stopAnimating()
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                    
                }
            }
            else {
                self.view.isUserInteractionEnabled = true
                self.activityIndicator.stopAnimating()
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    //MARK: - Make call  verify meter number sub
    func callTvSubAPI(){
        
        meterNumber = meterNumberTextField.text!
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "type": "electricity", "operation": "validate", "distributor": distributor_id,
                      "number": meterNumber]
        
        
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
        
        
        let url = "\(utililty.url)bill_payment"
        
        postData(url: url, parameter: parameter, token: token, header: headers)
    }
    
    ///////////***********Post Data MEthod*********////////
    func postData(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        self.activityIndicator.startAnimating()
        self.viewWrapper.isUserInteractionEnabled = false
        
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
                    self.viewWrapper.isUserInteractionEnabled = true
                    self.scrollviewToScroll.isScrollEnabled = true
                    self.amountLabel.isHidden = false
                    self.amountTextField.isHidden = false
                    self.walletLabel.isHidden = false
                    self.walletTextField.isHidden = false
                    self.textFieldView.isHidden = false
                    self.meterNameOutlet.isHidden = false
                    self.meterNameLabel.isHidden = false
                    self.vpdPinTextLabel.isHidden = false
                    self.vpdPinTextField.isHidden = false
                    
                    self.topContraintForMeterNameLabel.constant = 30
                    self.heightForVPDPin.constant = 30
                    self.heightForWallet.constant = 47
                    self.heightForAmount.constant = 45
                    self.heightForLabelConvinience.constant = 100
                    
                    let response = decriptorJson["response"]["name"].stringValue
                    self.meterNameOutlet.text = response
                }
                    
                else if  message == "Session has expired" {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.activityIndicator.stopAnimating()
                    self.viewWrapper.isUserInteractionEnabled = true
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.activityIndicator.stopAnimating()
                self.viewWrapper.isUserInteractionEnabled = true
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    //MARK: This will post the data to Make Payment
    func makePaymentAPI(){
        
        meterNumber = meterNumberTextField.text!
        amountNumber =  amountTextField.text!
        
        paymentPlan = (paymentPlanTextField.text == "Pre-paid") ? "1" : "0"
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
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "type": "electricity", "operation": "purchase", "distributor": distributor_id, "number": meterNumber, "wallet": walletId, "prepaid": paymentPlan, "amount": amountNumber, "transaction_pin": vpdPin, "auth_key": global_key]
        
        
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
        
        
        let url = "\(utililty.url)bill_payment"
        
        postData2(url: url, parameter: parameter, token: token, header: headers)
        global_key = ""
        isUserFace = false
    }
    
    ///////////***********Post Data MEthod*********////////
    func postData2(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        self.activityIndicator.startAnimating()
        self.viewWrapper.isUserInteractionEnabled = false
        
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
                    self.viewWrapper.isUserInteractionEnabled = true
                    self.amountLabel.isHidden = false
                    self.amountTextField.isHidden = false
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
                }
                    
                else if  message == "Session has expired" {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.activityIndicator.stopAnimating()
                    self.viewWrapper.isUserInteractionEnabled = true
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.activityIndicator.stopAnimating()
                self.viewWrapper.isUserInteractionEnabled = true
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    
    
    @IBAction func makePaymentButtonPressed(_ sender: Any) {
        
        let amountInNumber = Int(amountTextField.text ?? "")
        vpdPin = vpdPinTextField.text!
        
        if  amountInNumber! < 500 {
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "Insufficent amount")
            self.present(alertVC, animated: true)
        }
        else if walletId == "" {
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "Please Select Wallet currency")
            self.present(alertVC, animated: true)
             return
        }
            
        else if !selectCompanyTextField.text!.isEmpty && !paymentPlanTextField.text!.isEmpty && !meterNumberTextField.text!.isEmpty && !amountTextField.text!.isEmpty && walletTextField.text!.isEmpty {
            
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "Make sure all fields are filled")
            self.present(alertVC, animated: true)
        }
            
        else {
            if transaction_face && isUserFace == false {
                let alertSV = FaceID()
                let alert = alertSV.showFaceID()
                self.present(alert, animated: true)
            }
            else {
                makePaymentAPI()
            }
        }
        
    }
    
    //MARK: IBACTIONs
    @IBAction func buttonPressed(_ sender: UIButton){
        if sender.tag == 1 {
            selectCompanyTextField.becomeFirstResponder()
        }
        else if sender.tag == 2 {
            paymentPlanTextField.becomeFirstResponder()
        }
        else {
            walletTextField.becomeFirstResponder()
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! FailedControllerViewController
        
        destination.from_segue = "TV Subscription"
    }
}

extension ElectricBillViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == piker1 {
            return electricity.count
            
        }
        else if pickerView == piker2 {
            return payment_plan.count
        }
            
        else if pickerView == piker3 {
            return accountArray.count
        }
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == piker1 {
            return electricity[row].name
            
        }
            
        else if pickerView == piker2 {
            return payment_plan[row]
        }
            
        else if pickerView == piker3 {
            return accountArray[row].currency
        }
        return ""
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == piker1 {
            selectCompanyTextField.text = electricity[row].name
            distributor_id = electricity[row].id
            
            self.view.endEditing(false)
        }
        
        if pickerView == piker2 {
            paymentPlanTextField.text = payment_plan[row]
            self.view.endEditing(false)
        }
        
        if pickerView == piker3 {
            walletTextField.text = "\(accountArray[row].currency) - Wallet"
            walletId = accountArray[row].wallet_uid
            self.view.endEditing(false)
        }
    }
    
}

