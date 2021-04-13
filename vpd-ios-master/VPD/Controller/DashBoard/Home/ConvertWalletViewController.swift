//
//  ConvertWalletViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 06/08/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ConvertWalletViewController: UIViewController, UITextFieldDelegate {
    
    //@IBOutlet weak var zeroLabel: UILabel!
    @IBOutlet weak var zeroTextField: UITextField!
    @IBOutlet var viewWrapper: UIView!
    @IBOutlet weak var wallet_type: UILabel!
    @IBOutlet weak var currency_header: UILabel!
    @IBOutlet weak var zeroTextFieldWrapper: UIView!
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var subAccountLabel: UILabel!
    @IBOutlet weak var currencyRateLabel: UILabel!
    @IBOutlet weak var accountTo: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicator2: UIActivityIndicatorView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var convertButton: DesignableButton!
    
    
    var selectedRowArray = Wallet()
    var selectRowSubArray = CurrencyList()
    var currency = ""
    var amount = ""
    var wallet_uid = ""
    var walletType = ""
    
    var accountToType = ""

    
    var converted_amount = ""
    var rate = ""
    var selected_currency = ""
    var amt: Int = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        zeroTextField.delegate = self
        balanceLabel.text = "\(currency) \(amount)"
        
        wallet_type.text = "\(currency) Wallet"
        
        accountTo.text = "\(accountToType) Account"
        currency_header.text = currency
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.myviewTapped))
        self.viewWrapper.addGestureRecognizer(gesture)
        
        if walletType == "MAIN" {
            subAccountLabel.text = "\(selectedRowArray.currency) 0"
            currencyRateLabel.text = " \(currency)1 = \(selectRowSubArray.cu_name_abbr)0.00"
            selected_currency = selectedRowArray.currency
        }
        else {
            subAccountLabel.text = "\(selectRowSubArray.cu_name_abbr) 0"
            currencyRateLabel.text = " \(currency)1 = \(selectRowSubArray.cu_name_abbr)0.00"
            selected_currency = selectRowSubArray.cu_name_abbr
        }
        
    
        
        //Hide button
        convertButton.isHidden = true
                
        
        zeroTextField.attributedPlaceholder = NSAttributedString(string: updateAmount()!,
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    
        
        print(wallet_uid, walletType, amount, currency, selectRowSubArray.cu_name_abbr, selectedRowArray.balance, selectedRowArray.currency)
        
        
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
    
        zeroTextField.inputAccessoryView = toolBar
        
    }
    
    
    
    //MARK - ADD Comma to Text
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let digit = Int(string) {
            amt = amt * 10 + digit
            zeroTextField.text = updateAmount()
            delayToNextPage()
        }
        
        if string == "" {
            amt = amt/10
            zeroTextField.text = updateAmount()
            delayToNextPage()
        }
        return false
    }
    
    func updateAmount() -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        
        let amount = Double(amt/100) + Double(amt%100)/100
        
        return formatter.string(from: NSNumber(value: amount))
    }
    
    
    //***********Method to handle date format and date dismiss*********//
    @objc func donePicker() {
        zeroTextField.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        zeroTextFieldWrapper.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(textFieldTapped)))
    }
    
    @objc func textFieldTapped(sender: UIGestureRecognizer) {
        zeroTextField.becomeFirstResponder()
    }
    

    
    // MARK - APi call to get conversion rates
    //**********************************************//
    
    func delayToNextPage(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        var currency_to = ""
        
        let device = utililty.getPhoneId()
        
        if selectedRowArray.balance == "" {
            currency_to = selectRowSubArray.cu_name_abbr
            print(currency_to)
        }
        else{
            currency_to = selectedRowArray.currency
            print(currency_to)
        }
        
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        let zero_text = zeroTextField.text?.split(separator: ",").joined()
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "SessionID": session, "CustomerID": customer_id, "currency_from": currency, "currency_to": currency_to, "amount": zero_text]
        
        
        print(params)
        
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
        
        let url = "\(utililty.url)currency_converter"
        
        postData(url: url, parameter: parameter, token: token, header: headers)
    }
    
    ///////////***********Post Data MEthod*********////////
    func postData(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        //activityIndicator.startAnimating()
        spinner.startAnimating()
        self.currencyRateLabel.isHidden = true
        self.subAccountLabel.isHidden = true
        
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
                    
                    self.spinner.stopAnimating()
                    var shortRate = ""
                    
                    self.converted_amount =  decriptorJson["response"]["converted_amount"].stringValue
                    self.rate = decriptorJson["response"]["rate"].stringValue
                    
                    if(self.rate.count > 6){
                        shortRate = String(self.rate.dropLast(3))
                    }
                    else {
                        shortRate = self.rate
                    }
                    self.subAccountLabel.isHidden = false
                    self.subAccountLabel.text = "\(self.selected_currency) \(self.converted_amount)"
                    self.currencyRateLabel.text = " \(self.currency)1 = \(self.selected_currency)\(shortRate)"
                    
                    print( "\(self.selected_currency) ....... from line 207")
                    print("\(shortRate)....... from line 208")
                    
                    self.convertButton.isHidden = false
                    //self.activityIndicator.stopAnimating()
                    
                    self.currencyRateLabel.isHidden = false
                }
                    
                else if (message == "Session has expired") {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    
                    ////From the alert Service
                    let alertService = AlertService()
                    //self.activityIndicator.stopAnimating()
                    self.spinner.stopAnimating()
                    self.currencyRateLabel.isHidden = false
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                ////From the alert Service
                let alertService = AlertService()
                self.spinner.stopAnimating()
                //self.activityIndicator.stopAnimating()
                self.currencyRateLabel.isHidden = false
                let alertVC = alertService.alert(alertMessage: "Network Error")
                self.present(alertVC, animated: true)
                
            }
        }
        
    }
    
    
    // MARK - APi call to Convert funds 
    //**********************************************//
    func convertToSubWalletAPI(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        let device = utililty.getPhoneId()
        
        
        var currency_to = ""
        
        if selectedRowArray.balance == "" {
            currency_to = selectRowSubArray.cu_name_abbr
            print(currency_to)
        }
        else{
            currency_to = selectedRowArray.currency
            print(currency_to)
        }
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        let zero_text = zeroTextField.text?.split(separator: ",").joined()
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "SessionID": session, "CustomerID": customer_id, "convertToType": walletType, "convertToCurrency": currency_to, "amount": zero_text, "WalletID": wallet_uid]
        
        
        print(params)
        
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
        
        let url = "\(utililty.url)wallet_fund_transfer"
        
        postData2(url: url, parameter: parameter, token: token, header: headers)
    }
    
    ///////////***********Post Data MEthod*********////////
    func postData2(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        activityIndicator2.startAnimating()
        convertButton.isHidden = true
        
        
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
                    
                    self.convertButton.isHidden = false
                    self.activityIndicator2.stopAnimating()
                    self.subAccountLabel.isHidden = false
                    let alertSV = SuccessAlertTransaction()
                    let alert = alertSV.alert(success_message: message) {
                        self.navigationController?.popToViewController(ofClass: TabBarViewController.self)
                    }
                    self.present(alert, animated: true)
                }
                
                else if (message == "Session has expired") {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    ////From the alert Service
                    let alertService = AlertService()
                    self.activityIndicator2.stopAnimating()
                    self.subAccountLabel.isHidden = false
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
                
            }
            else {
                ////From the alert Service
                let alertService = AlertService()
                self.activityIndicator2.stopAnimating()
                self.subAccountLabel.isHidden = false
                let alertVC = alertService.alert(alertMessage: "Network Error")
                self.present(alertVC, animated: true)
                
            }
        }
        
    }
    
    //******This will make text field disappear
    // Assign the newly active text field to your activeTextField variable
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 0 {
            convertButton.isHidden =  true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        zeroTextField.resignFirstResponder()
        return false
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
//        if zeroTextField.text! != "" {
//            delayToNextPage()
//        }
    }
    
    
    @objc func myviewTapped(_ sender: UITapGestureRecognizer) {
        viewWrapper.becomeFirstResponder()
        zeroTextField.resignFirstResponder()
    }
    
    
    @IBAction func convertButtonPressed(_ sender: Any) {
        
        let textfieldInt: Double? = Double(zeroTextField.text!.split(separator: ",").joined())
        let textfield2Int = Double(amount.replacingOccurrences(of: ",", with: "", options: NSString.CompareOptions.literal, range: nil))
        
        if(zeroTextField.text == ""){
            //showToast(message: "Invalid Amount", font: nil)
            print("Please make sure all field are field")
        }
        
        if textfieldInt! > textfield2Int! {
            
            ////From the alert Service
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "Amount entered is greater than available balance.")
            self.present(alertVC, animated: true)
        }
        else {
            convertToSubWalletAPI()
        }
       
       
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
