//
//  RecurrenceViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 10/09/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class RecurrenceViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var todayTextField: UITextField!
    @IBOutlet weak var nextButtonLabel: UIButton!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var hide_label_for_days: UILabel!
    @IBOutlet weak var hide_textField_for_days: UITextField!
    
    private var datePicker: UIDatePicker?
    
    var reccurrence_string = "Every Day"
    
    var indexRow:Int = 0
    var vpdPin = ""
    
    //MARK: Cell scale factor
    let cellScale: CGFloat = 0.8
    
    var recurrenceArray = [
        ["index": 0, "text": "Every day", "color": UIColor.black],
        ["index": 1, "text": "Every week", "color": UIColor.black],
        ["index": 2, "text":"Every month", "color": UIColor.black]
    ]
    
    var wallet = ""
    var phone = ""
    var amount = ""
    var startdate = "today"
    var frequency = "daily"
    var account_number = ""
    var bank_code = ""
    var type = "contact"
    var plan = ""
    var number = ""
    var distributor = ""
    var provider = ""
    var planId = ""
    var card_number = ""
    
    var message = ""
    
    var recurring_id = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(wallet, type, number, distributor)
        print(wallet, phone, account_number, bank_code, type, plan, amount, "..........")
        print(wallet, type, card_number, provider, planId, "............for tv sub")
        // Do any additional setup after loading the view.
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let screenSize = UIScreen.main.bounds.size
        let cellWidth = floor(screenSize.width * cellScale)
        let insetX = (view.bounds.width - cellWidth) / 2.0
        
        let layout = collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.itemSize = CGSize(width: cellWidth, height: 270)
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: insetX)
        
        //Setting decelerationRate to fast gives a nice experience
        collectionView.decelerationRate = .fast
        
        
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
        
        
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        todayTextField.inputView = datePicker
        todayTextField.inputAccessoryView = toolBar
        
        
        if recurring_id != "" {
            hide_label_for_days.isHidden = true
            hide_textField_for_days.isHidden = true
        }
        
    }
    
    
    //MARK: -Recurring billing for TV subScription
    func recurringBillingTVSubscriptionAPI(){
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "type": "tvsubscription", "wallet": wallet, "operation": "create", "amount": amount, "startdate": startdate, "frequency": frequency, "number": card_number, "provider": provider, "plan": planId, "transaction_pin": vpdPin]
        
        
        
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
        
        
        let url = "\(utililty.url)recurrent_payment"
        
        
        postRecurringBillingTVSub(url: url, parameter: parameter, token: token, header: headers)
        
    }
    
    //MARK: - POST API for TV subScription
    func postRecurringBillingTVSub(url: String, parameter: [String: String], token: String, header: [String: String]) {
        activityIndicator.startAnimating()
        nextButtonLabel.isHidden = true
        
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
                    //********Response from server *******//
                    self.activityIndicator.stopAnimating()
                    self.nextButtonLabel.isHidden = false
                    self.message = message
                    let alertSV = SuccessAlertTransaction()
                    let alert = alertSV.alert(success_message: message) {
                        self.navigationController?.popToViewController(ofClass: ListOfBeneficiaryViewController.self)
                    }
                    self.present(alert, animated: true)
                }
                    
                else if  message == "Session has expired" {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.nextButtonLabel.isHidden = false
                    self.activityIndicator.stopAnimating()
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.nextButtonLabel.isHidden = false
                self.activityIndicator.stopAnimating()
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    
    func recurringBillingVPDContactAPI(){
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "type": "contact", "wallet": wallet, "operation": "create", "phone": phone, "amount": amount, "startdate": startdate, "frequency": frequency, "transaction_pin": vpdPin]
        
        
        
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
        
        
        let url = "\(utililty.url)recurrent_payment"
        
        
        postVPDRecurring(url: url, parameter: parameter, token: token, header: headers)
        
    }
    
    ///////////***********Post Data MEthod*********////////
    func postVPDRecurring(url: String, parameter: [String: String], token: String, header: [String: String]) {
        activityIndicator.startAnimating()
        nextButtonLabel.isHidden = true
        
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
                    //********Response from server *******//
                    self.activityIndicator.stopAnimating()
                    self.nextButtonLabel.isHidden = false
                    self.message = message
                    let alertSV = SuccessAlertTransaction()
                    let alert = alertSV.alert(success_message: message) {
                        self.navigationController?.popToViewController(ofClass: ListOfBeneficiaryViewController.self)
                    }
                    self.present(alert, animated: true)
                }
                    
                else if  message == "Session has expired" {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.nextButtonLabel.isHidden = false
                    self.activityIndicator.stopAnimating()
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.nextButtonLabel.isHidden = false
                self.activityIndicator.stopAnimating()
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    
    //MARK:- POSTING to VPD account
    func recurringBillingVPDAccountAPI(){
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "type": "vpdaccount", "wallet": wallet, "operation": "create", "accountNumber": account_number, "amount": amount, "startdate": startdate, "frequency": frequency, "transaction_pin": vpdPin]
        
        
        
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
        
        
        let url = "\(utililty.url)recurrent_payment"
        
        
        postVPDAccountRecurring(url: url, parameter: parameter, token: token, header: headers)
        
    }
    
    ///////////***********Post Data MEthod*********////////
    func postVPDAccountRecurring(url: String, parameter: [String: String], token: String, header: [String: String]) {
        activityIndicator.startAnimating()
        nextButtonLabel.isHidden = true
        
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
                    //********Response from server *******//
                    self.activityIndicator.stopAnimating()
                    self.nextButtonLabel.isHidden = false
                    self.message = message
                    let alertSV = SuccessAlertTransaction()
                    let alert = alertSV.alert(success_message: message) {
                        self.navigationController?.popToViewController(ofClass: ListOfBeneficiaryViewController.self)
                    }
                    self.present(alert, animated: true)
                }
                    
                else if  message == "Session has expired" {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.nextButtonLabel.isHidden = false
                    self.activityIndicator.stopAnimating()
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.nextButtonLabel.isHidden = false
                self.activityIndicator.stopAnimating()
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    
    //MARK:- POSTING to Bank account
    func recurringBillingBankAccountAPI(){
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "type": "bankaccount", "wallet": wallet, "operation": "create", "accountNumber": account_number, "amount": amount, "startdate": startdate, "frequency": frequency, "bank_code": bank_code, "transaction_pin": vpdPin]
        
        
        
        
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
        
        
        let url = "\(utililty.url)recurrent_payment"
        
        
        postBankAccountRecurring(url: url, parameter: parameter, token: token, header: headers)
        
    }
    
    ///////////***********Post Data MEthod*********////////
    func postBankAccountRecurring(url: String, parameter: [String: String], token: String, header: [String: String]) {
        activityIndicator.startAnimating()
        nextButtonLabel.isHidden = true
        
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
                    //********Response from server *******//
                    self.activityIndicator.stopAnimating()
                    self.nextButtonLabel.isHidden = false
                    self.message = message
                    let alertSV = SuccessAlertTransaction()
                    let alert = alertSV.alert(success_message: message) {
                        self.navigationController?.popToViewController(ofClass: ListOfBeneficiaryViewController.self)
                    }
                    self.present(alert, animated: true)
                }
                    
                else if  message == "Session has expired" {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.nextButtonLabel.isHidden = false
                    self.activityIndicator.stopAnimating()
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.nextButtonLabel.isHidden = false
                self.activityIndicator.stopAnimating()
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    
    //MARK:- POSTING to recurring bill airtime
    func recurringBillingAirtimeAPI(){
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "type": type, "wallet": wallet, "operation": "create", "phone": phone, "amount": amount, "startdate": startdate, "frequency": frequency, "plan": plan, "transaction_pin": vpdPin]
        
        
        
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
        
        
        let url = "\(utililty.url)recurrent_payment"
        
        
        postAirtimeRecurring(url: url, parameter: parameter, token: token, header: headers)
        
    }
    
    ///////////***********Post Data MEthod*********////////
    func postAirtimeRecurring(url: String, parameter: [String: String], token: String, header: [String: String]) {
        activityIndicator.startAnimating()
        nextButtonLabel.isHidden = true
        
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
                    //********Response from server *******//
                    self.activityIndicator.stopAnimating()
                    self.nextButtonLabel.isHidden = false
                    self.message = message
                    let alertSV = SuccessAlertTransaction()
                    let alert = alertSV.alert(success_message: message) {
                        self.navigationController?.popToViewController(ofClass: ListOfBeneficiaryViewController.self)
                    }
                    self.present(alert, animated: true)
                }
                    
                else if  message == "Session has expired" {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.nextButtonLabel.isHidden = false
                    self.activityIndicator.stopAnimating()
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.nextButtonLabel.isHidden = false
                self.activityIndicator.stopAnimating()
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    
    
    //MARK:- POSTING to recurring bill airtime
    func recurringBillingDataAPI(){
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "type": type, "wallet": wallet, "operation": "create", "phone": phone, "startdate": startdate, "frequency": frequency, "plan": plan, "transaction_pin": vpdPin]
        
        
        
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
        
        
        let url = "\(utililty.url)recurrent_payment"
        
        
        postAirtimeRecurring(url: url, parameter: parameter, token: token, header: headers)
        
    }
    
    ///////////***********Post Data MEthod*********////////
    func postDataRecurring(url: String, parameter: [String: String], token: String, header: [String: String]) {
        activityIndicator.startAnimating()
        nextButtonLabel.isHidden = true
        
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
                    //********Response from server *******//
                    self.activityIndicator.stopAnimating()
                    self.nextButtonLabel.isHidden = false
                    self.message = message
                    let alertSV = SuccessAlertTransaction()
                    let alert = alertSV.alert(success_message: message) {
                        self.navigationController?.popToViewController(ofClass: ListOfBeneficiaryViewController.self)
                    }
                    self.present(alert, animated: true)
                }
                    
                else if  message == "Session has expired" {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.nextButtonLabel.isHidden = false
                    self.activityIndicator.stopAnimating()
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.nextButtonLabel.isHidden = false
                self.activityIndicator.stopAnimating()
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    //MARK:- POSTING to recurring bill airtime
    func recurringBillingElectricityAPI(){
        print("Called me")
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "type": type, "wallet": wallet, "operation": "create", "number": number, "distributor": distributor, "startdate": startdate, "frequency": frequency, "amount": amount, "transaction_pin": vpdPin]
        
        
        
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
        
        
        let url = "\(utililty.url)recurrent_payment"
        
        
        postElectricityRecurring(url: url, parameter: parameter, token: token, header: headers)
        
    }
    
    ///////////***********Post Data MEthod*********////////
    func postElectricityRecurring(url: String, parameter: [String: String], token: String, header: [String: String]) {
        activityIndicator.startAnimating()
        nextButtonLabel.isHidden = true
        
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
                    //********Response from server *******//
                    self.activityIndicator.stopAnimating()
                    self.nextButtonLabel.isHidden = false
                    self.message = message
                    
                    let alertSV = SuccessAlertTransaction()
                    let alert = alertSV.alert(success_message: message) {
                        self.navigationController?.popToViewController(ofClass: ListOfBeneficiaryViewController.self)
                    }
                    self.present(alert, animated: true)
                }
                    
                else if  message == "Session has expired" {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.nextButtonLabel.isHidden = false
                    self.activityIndicator.stopAnimating()
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.nextButtonLabel.isHidden = false
                self.activityIndicator.stopAnimating()
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    
    //MARK: -  Fetch recurring by ID
    func callListOfRecuringID(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "operation": "update", "id": recurring_id, "frequency": frequency, "transaction_pin": vpdPin]
        
        
        
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
        
        
        let url = "\(utililty.url)recurrent_payment"
        
        postToCallRecurring(url: url, parameter: parameter, token: token, header: headers)
    }
    
    //MARK: - VALIDATE
    ///////////***********Post Data MEthod*********////////
    func postToCallRecurring(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        self.view.isUserInteractionEnabled = false
        
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
                    //********Response from server *******//
                    self.activityIndicator.stopAnimating()
                    self.nextButtonLabel.isHidden = false
                    self.message = message
                    
                    let alertSV = SuccessAlertTransaction()
                    let alert = alertSV.alert(success_message: message) {
                        self.navigationController?.popToViewController(ofClass: ListOfBeneficiaryViewController.self)
                    }
                    self.present(alert, animated: true)
                    
                }
                else if (message == "Session has expired") {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.dismiss(animated: true, completion: nil)
                    self.view.isUserInteractionEnabled = true
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)             }
            }
            else {
                self.dismiss(animated: true, completion: nil)
                self.view.isUserInteractionEnabled = true
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
            }
            
        }
    }
    
    //***********Method to handle date format and date dismiss*********//
    @objc func donePicker(datePicker: UIDatePicker) {
        todayTextField.resignFirstResponder()
    }
    
    //***********Method to handle date format and date dismiss*********//
    @objc func dateChanged(datePicker: UIDatePicker) {
        //var date_from_piker = datePicker.date
        //var present_date = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        todayTextField.text = dateFormatter.string(from: datePicker.date)
        
        startdate = todayTextField.text!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewWasTapped)))
    }
    
    
    @objc func viewWasTapped (sender : UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let layout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        
        let cell = layout.itemSize.width + layout.minimumLineSpacing
        
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cell
        let roundIndex = round(index)
        
        indexRow = Int(roundIndex)
        frequency = recurrenceArray[indexRow]["text"] as! String
        
        
        offset = CGPoint(x: roundIndex * cell - scrollView.contentInset.left, y: scrollView.contentInset.top)
        
        targetContentOffset.pointee = offset
        
        collectionView.reloadData()
        
        if frequency == "Every day" {
            print(frequency)
            frequency = "daily"
            return
        }
        else if frequency  == "Every week"{
            print(frequency)
            frequency = "weekly"
            return
        }
        else {
            frequency = "monthly"
        }
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextButtonPresssed(_ sender: Any) {
        
        if recurring_id != "" {
            callListOfRecuringID()
            return
        }
        
        if type == "contact" {
            recurringBillingVPDContactAPI()
            return
        }
        if type == "vpdaccount" {
            recurringBillingVPDAccountAPI()
            return
        }
        if type == "airtime" {
            recurringBillingAirtimeAPI()
            return
        }
        if type == "data" {
            recurringBillingDataAPI()
            return
        }
        if type == "electricity" {
            recurringBillingElectricityAPI()
            return
        }
        if type == "tvsubscription" {
            recurringBillingTVSubscriptionAPI()
            return
        }
        else {
            recurringBillingBankAccountAPI()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let des = segue.destination as! FailedControllerViewController
        des.from_segue = message
    }
}


extension RecurrenceViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recurrenceArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! RecurrenceCollectionViewCell
        
        let cellDict = recurrenceArray[indexPath.row]
        
        
        if cellDict["index"] as? Int == indexRow {
            cell.recurrence.textColor = .black
            cell.recurrence.font = UIFont(name: "Muli-Black", size: 55)
            
        }
        else {
            cell.recurrence.textColor = .lightGray
            cell.recurrence.font = UIFont(name: "Muli-Bold", size: 55)
        }
        
        cell.recurrence.text = cellDict["text"] as? String
        
        return cell
    }
    
}





