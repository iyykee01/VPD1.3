//
//  AddContactViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 25/11/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class AddContactViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var selectAcctTypeTextField: UITextField!
    @IBOutlet weak var activityIndicator2: UIActivityIndicatorView!
    
    @IBOutlet weak var accountNumberTextField: UITextField!
    @IBOutlet weak var walletTextField: DesignableUITextField!
    
    @IBOutlet weak var bankTextField: UITextField!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var selectBankLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var selectAcctTypeLabel: UILabel!
    

    //MARK: - NSLayout Constraints
    @IBOutlet weak var height_for_phone_number_label: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var selectBankTextfield: DesignableView!
    @IBOutlet weak var nextButton: DesignableButton!
    @IBOutlet weak var walletViewWrapper: DesignableView!
    @IBOutlet weak var selectBankWrapper: DesignableView!
    @IBOutlet weak var selectAcctTypeWrapper: DesignableView!
    @IBOutlet weak var topNameTextField: NSLayoutConstraint!
    @IBOutlet weak var nameTextFieldConstraint: NSLayoutConstraint!
    
    
    
    //Constraint for height//
    @IBOutlet weak var SelectBankTextFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var acctNumberConstraint: NSLayoutConstraint!
    
    var accountType = ["VPD Account", "Bank Account"]
    
    var name_segue = ""
    var phone_number_segue = ""
    var contact_image = ""
    var balance = ""
    var bank_code = ""
    
    var list_of_banks = [ListOfBanks]()
    

    let piker1 = UIPickerView()
    let piker2 = UIPickerView()
    let piker3 = UIPickerView()

    var walletId = ""
    var new_contact = ""
    var type = ""
    var account_number = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        SelectBankTextFieldHeight.constant = 0 // 47
        acctNumberConstraint.constant = 0 // 45
        topNameTextField.constant = -20 // 40
        nameTextFieldConstraint.constant = 50
        
        //Do any additional setup after loading the view.
        nameTextField.setLeftPaddingPoints(15)
        phoneNumberTextField.setLeftPaddingPoints(15)
        selectAcctTypeTextField.setLeftPaddingPoints(15)
        accountNumberTextField.setLeftPaddingPoints(15)
        bankTextField.setLeftPaddingPoints(15)
        walletTextField.setLeftPaddingPoints(15)
        
        nameTextField.delegate = self
        phoneNumberTextField.delegate = self
        selectAcctTypeTextField.delegate = self
        accountNumberTextField.delegate = self
        bankTextField.delegate = self
        
        
        piker1.dataSource = self
        piker1.delegate = self
        
        piker2.dataSource = self
        piker2.delegate = self
        
        piker3.dataSource = self
        piker3.delegate = self
        
        listOfBankAPI()
        
        print(new_contact, name_segue, "..........nonononoe")
        
        if new_contact != "" {
            selectAcctTypeLabel.isHidden = false
            selectAcctTypeWrapper.isHidden = false
            accountLabel.isHidden = false
            accountNumberTextField.isHidden = false
            acctNumberConstraint.constant = 45
            topNameTextField.constant = 0
            nameTextFieldConstraint.constant = 0
            nameLabel.isHidden = true
        }
        
        if name_segue != "" {
            selectAcctTypeLabel.isHidden = true
            selectAcctTypeWrapper.isHidden = true
            accountLabel.isHidden = true
            accountNumberTextField.isHidden = true
            nameLabel.isHidden = false
            nameTextField.isHidden = false
            
            topNameTextField.constant = 40
            nameTextField.text = name_segue
            phoneNumberTextField.text = phone_number_segue
            
        }
        
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
        
        selectAcctTypeTextField.inputView = piker1
        bankTextField.inputView = piker2
        walletTextField.inputView = piker3
        selectAcctTypeTextField.inputAccessoryView = toolBar
        bankTextField.inputAccessoryView = toolBar
        phoneNumberTextField.inputAccessoryView = toolBar
        walletTextField.inputAccessoryView = toolBar
        accountNumberTextField.inputAccessoryView = toolBar
    }
    
    
    //***********Method to handle date format and date dismiss*********//
    @objc func donePicker(datePicker: UIDatePicker) {
        if type == "bankaccount" && bankTextField.text != "" {
            account_number = accountNumberTextField.text!
            validateAPI()
        }
        view.endEditing(true)
    }
    
    
    //MARK: - This will post the data to Make Payment
    func makeVerificationAPI(){
        
        /******Import  and initialize Util Class*****////
        
        account_number = accountNumberTextField.text!
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "validate": account_number, "type": "wallet"]
     
        
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
        
        
        let url = "\(utililty.url)transfer_funds"
        
        postData2(url: url, parameter: parameter, token: token, header: headers)
    }
    
    ///////////***********Post Data MEthod*********////////
    func postData2(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        self.activityIndicator2.startAnimating()
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
                    
                    //MARK: Should show when vpd account number is verified
                    self.nameLabel.isHidden = false
                    self.nameTextField.isHidden = false
                    self.SelectBankTextFieldHeight.constant =  0
                    self.acctNumberConstraint.constant =  45
                    self.nameTextField.isHidden = false
                    self.topNameTextField.constant = 40
                    self.nameTextFieldConstraint.constant = 45
                    
                    self.nameTextField.text = decriptorJson["response"]["name"].stringValue
                }
                
                else if (message == "Session has expired") {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.activityIndicator2.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.activityIndicator2.stopAnimating()
                self.view.isUserInteractionEnabled = true
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    //MARK: - Validate Bank Acount************************
    func validateAPI(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "SessionID": session, "CustomerID": customer_id, "bank_code": bank_code, "account_no": account_number]
        
       // print(params)
        
        
        
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
        
     
        
        let url = "\(utililty.url)account_query"
        
        postForValidate(url: url, parameter: parameter, token: token, header: headers)
    }

    
    // MARK: - NETWORK CALL- Post TO LIST OF BANKs
    func postForValidate(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        self.activityIndicator2.startAnimating()
        
        Alamofire.request(url, method: .post, parameters: parameter, headers: header).responseJSON {
            response in
            if response.result.isSuccess {
                //print("SUCCESSFUL.....")
                
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
                    self.activityIndicator2.stopAnimating()
                    self.nameLabel.isHidden = false
                    self.nameTextFieldConstraint.constant =  45
                    self.SelectBankTextFieldHeight.constant =  47
                    self.acctNumberConstraint.constant =  45
                    self.nameTextField.isHidden = false
                    self.topNameTextField.constant = 40
                    
                    self.nameTextField.text = decriptorJson["response"]["field"].stringValue
                }
                    
                else if (message == "Session has expired") {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.view.isUserInteractionEnabled = true
                    self.activityIndicator2.stopAnimating()
                    let alertService = AlertService()
                    let alertVC =  alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.view.isUserInteractionEnabled = true
                self.activityIndicator2.stopAnimating()
                let alertService = AlertService()
                let alertVC =  alertService.alert(alertMessage: "Network Error")
                self.present(alertVC, animated: true)
              
            }
       
        }
    }
    
    //MARK: - DashBoard API HERE(Transaction History)************************
    //Delay function @if token is true move to next page//
    func listOfBankAPI(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "SessionID": session, "CustomerID": customer_id]
        
       // print(params)
        
        
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
        
     
        
        let url = "\(utililty.url)list_banks"
        
        postToListOfBanks(url: url, parameter: parameter, token: token, header: headers)
    }

    
    // MARK: - NETWORK CALL- Post TO LIST OF BANKs
    func postToListOfBanks(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        self.activityIndicator2.startAnimating()
        
        Alamofire.request(url, method: .post, parameters: parameter, headers: header).responseJSON {
            response in
            if response.result.isSuccess {
                //print("SUCCESSFUL.....")
                
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
                //print(decriptorJson)
                
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                
                
                if(status) {
                    self.view.isUserInteractionEnabled = true
                    self.activityIndicator2.stopAnimating()
                    self.list_of_banks = [ListOfBanks]()
                    for i in decriptorJson["response"].arrayValue {

                        let bank_list = ListOfBanks()

                        bank_list.bank_name = i["bank_name"].stringValue
                        bank_list.id = i["id"].stringValue
                        bank_list.bank_code = i["bank_code"].stringValue
                        bank_list.logo = i["logo"].stringValue
                        bank_list.iso3 = i["iso3"].stringValue

                        self.list_of_banks.append(bank_list)

                    }
                    
                    self.activityIndicator.stopAnimating()
                }
                    
                else if (message == "Session has expired") {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.view.isUserInteractionEnabled = true
                    self.activityIndicator2.stopAnimating()
                    let alertService = AlertService()
                    let alertVC =  alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.view.isUserInteractionEnabled = true
                self.activityIndicator2.stopAnimating()
                let alertService = AlertService()
                let alertVC =  alertService.alert(alertMessage: "Network Error")
                self.present(alertVC, animated: true)
                self.listOfBankAPI()
            }
       
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.endEditing(true)
        accountNumberTextField.endEditing(true)
        account_number = accountNumberTextField.text!
        
        if textField.tag == 1 && type == "vpdaccount" {
            makeVerificationAPI()
        }
        
        return false
    }
    
    @IBAction func dropDownButtonPressed(_ sender: UIButton) {
        
        if sender.tag == 1 {
            print(1)
            selectAcctTypeTextField.becomeFirstResponder()
        }
        else if sender.tag == 2 {
            print(2)
            bankTextField.becomeFirstResponder()
        }
        else {
            print(3)
            walletTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        print(type, new_contact, "........562")
        let wallettext = walletTextField.text?.split(separator: " ")
        
        if walletId == "" {
            let alertService = AlertService()
            let alertVC =  alertService.alert(alertMessage: "Please Select Wallet currency")
            self.present(alertVC, animated: true)
            return
        }
        
        if phoneNumberTextField.text!.isEmpty && selectAcctTypeTextField.text!.isEmpty && wallettext!.count < 3 {
            
             let alertService = AlertService()
             let alertVC =  alertService.alert(alertMessage: "Please fill all fields")
             self.present(alertVC, animated: true)
            
            return
        }
        if new_contact != "" && type == "vpdaccount" {
        
            performSegue(withIdentifier: "goToEnterAmount", sender: self)
            return
        }
        else if new_contact != "" && type == "bankaccount" {
            
            performSegue(withIdentifier: "goToEnterAmount", sender: self)
            return
        }
        
        else {
            performSegue(withIdentifier: "goToEnterAmount", sender: self)
        }
                    
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! RecurringPaymentViewController
        destination.wallet = walletId
        destination.name_segue = name_segue
        destination.phone = phone_number_segue
        destination.contact_image = contact_image
        destination.balance = balance
        destination.account_number = account_number
        destination.bank_code = bank_code
        destination.type = type
    }
}


extension AddContactViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == piker1 {
            return accountType.count
            
        }
            
        else if pickerView == piker2 {
            return list_of_banks.count
        }
        
        else if pickerView == piker3 {
            return accountArray.count
        }
     
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == piker1 {
            return accountType[row]
        }
            
        else if pickerView == piker2 {
            return list_of_banks[row].bank_name
        }
        
        else if pickerView == piker3 {
            return accountArray[row].currency
        }
        
  
        return ""
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == piker1 {
            selectAcctTypeTextField.text = accountType[row]
            
            if accountType[row] == "Bank Account" {
                
                accountLabel.isHidden = false
                accountNumberTextField.isHidden = false
                selectBankLabel.isHidden = false
                selectBankTextfield.isHidden = false
                self.SelectBankTextFieldHeight.constant =  47
                
                type = "bankaccount"
            }
            else if accountType[row] == "VPD Account" {
                accountLabel.isHidden = false
                accountNumberTextField.isHidden = false
                type = "vpdaccount"
                selectBankLabel.isHidden = true
                selectBankTextfield.isHidden = true
            }
        }
            
        if pickerView == piker2 {
            
            bankTextField.text = list_of_banks[row].bank_name
            bank_code = list_of_banks[row].bank_code
            
        }
        
        if pickerView == piker3 {
            walletTextField.text = "\(accountArray[row].currency) - Wallet"
            walletId = accountArray[row].wallet_uid
            balance = accountArray[row].balance
            self.view.endEditing(false)
        }

    }
    
}






    
 
    
    

        
    

    
   
