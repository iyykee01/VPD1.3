//
//  SelectBillForRecurringViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 08/01/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SelectBillForRecurringViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var selectBillTextField: DesignableUITextField!
    @IBOutlet weak var selectCompanyTextField: DesignableUITextField!
    @IBOutlet weak var paymentPlanTextField: DesignableUITextField!
    @IBOutlet weak var meterNumberTextField: UITextField!
    @IBOutlet weak var activityIndicator2: UIActivityIndicatorView!
    @IBOutlet weak var buttonOutlet: DesignableButton!
    @IBOutlet weak var selectWalletTextField: DesignableUITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    //for top constrianst to select distribution
    @IBOutlet weak var top_constraintSelectDisComopany: NSLayoutConstraint!
    @IBOutlet weak var select_distrubtion_company_label: UILabel!
    @IBOutlet weak var selectViewDistributionViewWrapper: DesignableView!
    @IBOutlet weak var heightForDistributionSelect: NSLayoutConstraint!
    
    //
    @IBOutlet weak var top_for_payment_constraint: NSLayoutConstraint!
    @IBOutlet weak var paymentLabel: UILabel!
    @IBOutlet weak var planViewtextFieldWrapper: DesignableView!
    @IBOutlet weak var heightConstraint_for_plan: NSLayoutConstraint!
    
    //
    @IBOutlet weak var top_for_meter: NSLayoutConstraint!
    @IBOutlet weak var meterLabel: UILabel!
    @IBOutlet weak var meterTextField: UITextField!
    @IBOutlet weak var heighForMeter: NSLayoutConstraint!
    
    //
    @IBOutlet weak var topForName: NSLayoutConstraint!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var height_for_name: NSLayoutConstraint!
    
    //
    @IBOutlet weak var topSelectWallet: NSLayoutConstraint!
    @IBOutlet weak var selectWalletLabel: UILabel!
    @IBOutlet weak var selectWalletTextfieldWrapper: DesignableView!
    
    //
    
    
    //For select bill = tv sub
    @IBOutlet weak var smartcardTextField: UITextField!
    @IBOutlet weak var viewToHide: UIView!
    @IBOutlet weak var tvProvider: UILabel!
    @IBOutlet weak var smartcard: UILabel!
    @IBOutlet weak var accountname: UILabel!
    @IBOutlet weak var tvPlan: UILabel!
    @IBOutlet weak var tvplanViewWrapper: DesignableView!
    @IBOutlet weak var selectTVPlanTextField: DesignableUITextField!
    
    
    let piker1 = UIPickerView()
    let piker2 = UIPickerView()
    let piker3 = UIPickerView()
    let piker4 = UIPickerView()
    let piker5 = UIPickerView()
    
    var bills_array = ["Electricity", "Tv subscription", "Airtime", "Data"]
    var discos_array = ["Ikeja", "Eko electric", "Abuja electric"]
    var payment_plan = ["", "Pre-paid", "Post-paid"]
    
    var electricity = [ElectricityBills]()
    var storeProviders = [TVSubscription]()
    var tv_sub_plan = [DataPlan]()
    var meterNumber = ""
    var distributor_id = ""
    var selected_picker = ""
    var wallet_id = ""
    var balance = ""
    var card_number = ""
    var type = ""
    var provider_id = ""
    var product_List = false
    var planId = ""
    var price = ""
    
    
    @IBOutlet weak var scrollToScroll: UIScrollView!
    //For heightConstraint
    @IBOutlet weak var viewToHideConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectWalletHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameHeightConstraint: NSLayoutConstraint!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollToScroll.isScrollEnabled = false
        viewToHideConstraint.constant = 0 // 180
        nameHeightConstraint.constant = 0 //45
        selectWalletHeightConstraint.constant = 0 // 47
        
        // Do any additional setup after loading the view.
        selectBillTextField.delegate = self
        selectBillTextField.setLeftPaddingPoints(15)
        selectCompanyTextField.setLeftPaddingPoints(15)
        paymentPlanTextField.setLeftPaddingPoints(15)
        meterTextField.setLeftPaddingPoints(15)
        selectWalletTextField.setLeftPaddingPoints(15)
        nameTextField.setLeftPaddingPoints(15)
        smartcardTextField.setLeftPaddingPoints(15)
        selectTVPlanTextField.setLeftPaddingPoints(15)
        
        meterTextField.delegate = self
        smartcardTextField.delegate = self
        
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
        
        
        piker1.delegate = self
        piker1.dataSource = self
        
        piker2.delegate = self
        piker2.dataSource = self
        
        piker3.delegate = self
        piker3.dataSource = self
        
        piker4.delegate = self
        piker4.dataSource = self
        
        piker5.delegate = self
        piker5.dataSource = self
        
        selectBillTextField.inputView =  piker1
        selectBillTextField.inputAccessoryView = toolBar
        
        selectCompanyTextField.inputView = piker2
        selectCompanyTextField.inputAccessoryView = toolBar
        
        paymentPlanTextField.inputView = piker3
        paymentPlanTextField.inputAccessoryView = toolBar
        
        selectWalletTextField.inputView = piker4
        selectWalletTextField.inputAccessoryView = toolBar
        
        selectTVPlanTextField.inputView = piker5
        selectTVPlanTextField.inputAccessoryView = toolBar
        //Hide views here
        viewIsHidden()
    }
    
    func viewIsHidden() {
        top_constraintSelectDisComopany.constant = 0 // 20
        select_distrubtion_company_label.isHidden = true
        selectViewDistributionViewWrapper.isHidden = true
        heightForDistributionSelect.constant = 0 // 45
        
        //
        top_for_payment_constraint.constant = 0 // 20
        paymentLabel.isHidden = true
        planViewtextFieldWrapper.isHidden = true
        heightConstraint_for_plan.constant = 0 // 45
        
        //
        top_for_meter.constant = 0 // 20
        meterLabel.isHidden = true
        meterTextField.isHidden = true
        heighForMeter.constant = 0 // 45
        
        //
        topForName.constant = 0 // 20
        nameLabel.isHidden = true
        nameTextField.isHidden = true
        height_for_name.constant = 0 // 45
        
        //
        topSelectWallet.constant = 0 // 20
        selectWalletLabel.isHidden = true
        selectWalletTextfieldWrapper.isHidden = true
    }
    
    //***********Method to handle date format and date dismiss*********//
    @objc func donePicker(datePicker: UIDatePicker) {
        selectBillTextField.resignFirstResponder()
        selectCompanyTextField.resignFirstResponder()
        paymentPlanTextField.resignFirstResponder()
        selectWalletTextField.resignFirstResponder()
        
        selectTVPlanTextField.resignFirstResponder()
        
        
        print(selectBillTextField.text!, selected_picker)
        
        if selectBillTextField.text == "Electricity" && selected_picker == "1" {
            top_constraintSelectDisComopany.constant = 20
            select_distrubtion_company_label.isHidden = false
            selectViewDistributionViewWrapper.isHidden = false
            heightForDistributionSelect.constant = 45
            
            //
            top_for_payment_constraint.constant = 20
            paymentLabel.isHidden = false
            planViewtextFieldWrapper.isHidden = false
            heightConstraint_for_plan.constant = 45
            
            //
            top_for_meter.constant = 20
            meterLabel.isHidden = false
            meterTextField.isHidden = false
            heighForMeter.constant = 45
            
            //hide properties
            smartcardTextField.isHidden = true
            
            //selectCompanyTextField.text = ""
            
            
            //
            self.topSelectWallet.constant = 0
            self.selectWalletLabel.isHidden = true
            self.selectWalletTextfieldWrapper.isHidden = true
            viewToHide.isHidden = true
            
            //
            self.paymentLabel.text = "Payment plan"
            self.select_distrubtion_company_label.text = "Select distribution company"
            self.meterLabel.text = "Meter number"
            self.top_for_meter.constant = 20
            self.tvplanViewWrapper.isHidden = true
            //
            type = "electricity"
            
            
            delayToNextPage2()
            return
        }
        
        if selectBillTextField.text == "Tv subscription"  && selected_picker == "2" {
            
            select_distrubtion_company_label.text = "TV provider"
            select_distrubtion_company_label.isHidden = false
            top_constraintSelectDisComopany.constant = 20
            selectViewDistributionViewWrapper.isHidden = false
            heightForDistributionSelect.constant = 45
            
            //
            paymentLabel.text = "Smartcard number"
            top_for_payment_constraint.constant = 20
            paymentLabel.isHidden = false
            smartcardTextField.isHidden = false
            
            //
            top_for_meter.constant = 0
            meterLabel.isHidden = true
            meterTextField.isHidden = true
            heighForMeter.constant = 0
            
            //For meter
            self.topForName.constant = 0
            self.nameLabel.isHidden = true
            self.nameTextField.isHidden = true
            self.height_for_name.constant = 0
            
            self.topSelectWallet.constant = 0
            self.selectWalletLabel.isHidden = true
            self.selectWalletTextfieldWrapper.isHidden = true
            
            self.tvplanViewWrapper.isHidden = true
            
            //selectCompanyTextField.text = ""
            buttonOutlet.setTitle("Validate", for: .normal)
            
            
            
            getProvidersAPI()
            
            //to hide
            planViewtextFieldWrapper.isHidden = true
            heightConstraint_for_plan.constant = 0 //45
            
            type = "tvsubscription"
            
            return
        }
        
        if selectBillTextField.text == "Airtime" {
            type = "airtime"
            performSegue(withIdentifier: "goToAirTime", sender: self)
            return
        }
        
        if selectBillTextField.text == "Data" {
            type = "data"
            performSegue(withIdentifier: "goToData", sender: self)
            return
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        meterNumber = meterTextField.text!
        card_number = smartcardTextField.text!
        
        smartcardTextField.resignFirstResponder()
        meterTextField.resignFirstResponder()
        
        if textField.tag == 1 && smartcardTextField.text! != "" {
            callValidateTvAPI()
        }
        return false
    }
    
    //MARK:- //MARK: Get Electricity Providers API Call
    //Delay function @if token is true move to next page//
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
        
        meterNumber = meterTextField.text!
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
        
        self.activityIndicator2.startAnimating()
        self.view.isUserInteractionEnabled = false
        buttonOutlet.isHidden = true
        
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
                    self.activityIndicator2.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    self.buttonOutlet.setTitle("Next", for: .normal)
                    self.buttonOutlet.isHidden = false
                    
                    let response = decriptorJson["response"]["name"].stringValue
                    self.nameTextField.text = response
                    
                    
                    self.topForName.constant = 20
                    self.nameLabel.isHidden = false
                    self.nameTextField.isHidden = false
                    self.height_for_name.constant = 45
                    
                    self.topSelectWallet.constant = 20
                    self.selectWalletLabel.isHidden = false
                    self.selectWalletTextfieldWrapper.isHidden = false
                    self.viewToHideConstraint.constant = 50
                    self.selectWalletHeightConstraint.constant = 47
                    
                }
                    
                else if  message == "Session has expired" {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.activityIndicator2.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    self.buttonOutlet.isHidden = false
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.activityIndicator2.stopAnimating()
                self.view.isUserInteractionEnabled = true
                self.buttonOutlet.isHidden = false
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    
    //MARK:- Get Provider for TV SUB
    func getProvidersAPI(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "type": "tvsubscription", "operation": "getproviders"]
        
        
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
        
        tvSubAPI(url: url, parameter: parameter, token: token, header: headers)
    }
    
    //7029624737
    
    
    ///////////***********Post Data MEthod*********////////
    func tvSubAPI(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        activityIndicator.startAnimating()
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
                    
                    self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    //********Response from server *******//
                    self.storeProviders = [TVSubscription]()
                    for i in decriptorJson["response"].arrayValue {
                        let tv_subscription = TVSubscription()
                        
                        tv_subscription.none = ""
                        tv_subscription.currency = i["currency"].stringValue
                        tv_subscription.id = i["id"].stringValue
                        tv_subscription.name = i["name"].stringValue
                        tv_subscription.productList = i["productList"].boolValue
                        tv_subscription.validation = i["validation"].boolValue
                        
                        self.storeProviders.append(tv_subscription)
                    }
                    
                }
                    
                else if (message == "Session has expired") {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    
                    ////From the alert Service
                    self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                    
                }
            }
            else {
                self.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
                
            }
        }
    }
    
    
    //MARK: -  getPlan
    func callValidateTvAPI(){
        
        card_number = smartcardTextField.text!
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "type": "tvsubscription", "operation": "validate", "provider": provider_id, "number": card_number ]
        
        
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
        
        postValidateTvCard(url: url, parameter: parameter, token: token, header: headers)
    }
    
    //MARK - VALIDATE
    ///////////***********Post Data MEthod*********////////
    func postValidateTvCard(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        self.activityIndicator2.startAnimating()
        self.view.isUserInteractionEnabled = false
        buttonOutlet.isHidden = true
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
                    self.activityIndicator2.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    self.buttonOutlet.setTitle("Next", for: .normal)
                    self.buttonOutlet.isHidden = false
                    self.scrollToScroll.isScrollEnabled = !false
                    self.viewToHideConstraint.constant = 150
                    self.nameHeightConstraint.constant = 0
                    self.selectWalletHeightConstraint.constant = 47
                    
                    let user_name = decriptorJson["response"]["name"].stringValue
                    let split_username = user_name.split(separator: "-")
                    self.accountname.text = String(split_username[0])
                    
                    
                    self.meterLabel.text = "Tv Plan"
                    self.top_for_meter.constant = 60
                    self.meterLabel.isHidden = false
                    self.tvplanViewWrapper.isHidden = false
                    
                    
                    self.getPlan()
                    
                }
                else if (message == "Session has expired") {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.activityIndicator2.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    self.buttonOutlet.setTitle("Next", for: .normal)
                    self.buttonOutlet.isHidden = false
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.activityIndicator2.stopAnimating()
                self.view.isUserInteractionEnabled = true
                self.buttonOutlet.setTitle("Next", for: .normal)
                self.buttonOutlet.isHidden = false
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    //MARK: -  getPlan
    func getPlan() {
        
        card_number = smartcardTextField.text!
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "type": "tvsubscription", "operation": "getplans", "provider": provider_id]
        
        
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
        
        postGetPlan(url: url, parameter: parameter, token: token, header: headers)
    }
    
    ///////////***********Post Data MEthod*********////////
    func postGetPlan(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        self.activityIndicator.startAnimating()
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
                    self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    self.topSelectWallet.constant = 40
                    self.selectWalletLabel.isHidden = false
                    self.selectWalletTextfieldWrapper.isHidden = false
                    self.buttonOutlet.setTitle("Next", for: .normal)
                    self.buttonOutlet.isHidden = false
                    self.selected_picker = "3"
                    
                    let dataFromServer = decriptorJson["response"].arrayValue
                    
                    for i in dataFromServer {
                        let new_data_plan = DataPlan()
                        
                        new_data_plan.id = i["id"].stringValue
                        new_data_plan.name = i["name"].stringValue
                        new_data_plan.price = i["price"].stringValue
                        
                        self.tv_sub_plan.append(new_data_plan)
                    }
                    
                }
                    
                else if  message == "Session has expired" {                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    @IBAction func goBackButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dropDownButtonPressed(_ sender: UIButton) {
        if sender.tag == 1 {
            selected_picker = "1"
            selectBillTextField.becomeFirstResponder()
        }
        
        if sender.tag == 2 {
            selectCompanyTextField.becomeFirstResponder()
        }
        
        if sender.tag == 3 {
            paymentPlanTextField.becomeFirstResponder()
        }
        
        if sender.tag == 4 {
            selectTVPlanTextField.becomeFirstResponder()
        }
        
        if sender.tag == 5 {
            selectWalletTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        if buttonOutlet.titleLabel?.text == "Validate" && selectBillTextField.text  == "Electricity" {
            //run code
            callTvSubAPI()
            return
        }
        
        if buttonOutlet.titleLabel?.text == "Validate" && selectBillTextField.text ==  "Tv subscription" {
            //run code
            callValidateTvAPI()
            return
        }
        if buttonOutlet.titleLabel?.text == "Next" && wallet_id == "" {
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "Please Select Wallet currency")
            self.present(alertVC, animated: true)
            return
        }
        else {
            //perform segue
            performSegue(withIdentifier: "goToAmount", sender: self)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToAmount" {
            let des = segue.destination as! RecurringPaymentViewController
            des.balance = balance
            des.wallet = wallet_id
            des.type = type
            des.number = meterNumber
            des.distributor = distributor_id
            des.provider = provider_id
            des.planId = planId
            des.card_number = card_number
            des.amount = price
        }
        
        if segue.identifier == "goToAirTime" {
            let destination = segue.destination as!  MobileDataViewController
            destination.type = type
        }
        
        if segue.identifier == "goToData" {
            let destination = segue.destination as!  AirTimeViewController
            destination.type = type
        }
    }
}


extension SelectBillForRecurringViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == piker1 {
            return bills_array.count
            
        }
        
        if pickerView == piker2 {
            if selectBillTextField.text  == "Electricity" {
                return electricity.count
            }
            else if selectBillTextField.text ==  "Tv subscription" {
                return storeProviders.count
            }
            
        }
        
        if pickerView == piker3 {
            return payment_plan.count
        }
        if pickerView == piker4 {
            return accountArray.count
        }
        
        if pickerView == piker5 {
            return tv_sub_plan.count
        }
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == piker1 {
            return bills_array[row]
        }
        
        if pickerView == piker2 {
            if selectBillTextField.text  == "Electricity" {
                
                return electricity[row].name
            }
            else if selectBillTextField.text ==  "Tv subscription" {
                return storeProviders[row].name
            }
            
        }
        if pickerView == piker3 {
            
            return payment_plan[row]
        }
        
        if pickerView == piker4 {
            return accountArray[row].currency
        }
        
        if pickerView == piker5 {
            return tv_sub_plan[row].name
        }
        
        
        return ""
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == piker1 {
            
            selectBillTextField.text = bills_array[row]
            buttonOutlet.setTitle("Validate", for: .normal)
            
            if selectBillTextField.text  == "Electricity" {
                selected_picker = "1"
                self.scrollToScroll.isScrollEnabled = !false
            }
            else if selectBillTextField.text ==  "Tv subscription" {
                selected_picker = "2"
            }
        }
        
        if pickerView == piker2 {
            buttonOutlet.setTitle("Validate", for: .normal)
            selected_picker = "2"
            if selectBillTextField.text  == "Electricity" {
                selectCompanyTextField.text = electricity[row].name
                distributor_id = electricity[row].id
            }
            else if selectBillTextField.text ==  "Tv subscription" {
                selectCompanyTextField.text = storeProviders[row].name
                provider_id = storeProviders[row].id
                tvProvider.text = storeProviders[row].name
            }
            
        }
        
        if pickerView == piker3 {
            
            paymentPlanTextField.text = payment_plan[row]
        }
        
        if pickerView == piker4 {
            selectWalletTextField.text = "\(accountArray[row].currency) - Wallet"
            wallet_id = accountArray[row].wallet_uid
            balance = accountArray[row].balance
            
            if selectTVPlanTextField.text != "" {
                viewToHide.isHidden = false
                smartcard.text = smartcardTextField.text
            }
        }
        
        if pickerView == piker5 {
            type = "tvsubscription"
            selectTVPlanTextField.text = tv_sub_plan[row].name
            planId = tv_sub_plan[row].id
            tvPlan.text = tv_sub_plan[row].name
            price = tv_sub_plan[row].price
        }
    }
    
}




