//
//  PayAContactViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 10/09/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire



class PayAContactViewController: UIViewController, UITextFieldDelegate, vpdContactSelect, UITextViewDelegate {
    
    
    
    @IBOutlet var viewWrapper: UIView!
    @IBOutlet weak var zeroViewWrap: UIView!
    @IBOutlet weak var zeroTextField: UITextField!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var walletType: UILabel!
    
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var vpdAcctNumberTextField: UITextField!
    @IBOutlet weak var vapdAccountNumberLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var transferbutton: DesignableButton!
    @IBOutlet weak var stackMultiplier: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Should show when vpd account number is verified
    @IBOutlet weak var vpdAccountName: UILabel!
    @IBOutlet weak var accountNameTextField: DesignableUITextField!
    @IBOutlet weak var textViewArea: UITextView!
    @IBOutlet weak var heightConstraintVpdAccountNameTextField: NSLayoutConstraint!
    @IBOutlet weak var heightConstraintVpdAccountName: NSLayoutConstraint!
    
    @IBOutlet weak var buttonView: DesignableView!
    @IBOutlet weak var select_from_contact_list: UIButton!
    @IBOutlet weak var pinTextField: UITextField!
    
    @IBOutlet weak var buttomTopConstraint: NSLayoutConstraint!
    let walletId = currentWalletSelected["walletId"]
    let walletBalance = currentWalletSelected["balance"]
    let currency = currentWalletSelected["currency"]
    
    
    var from_segue = ""
    var account_number = ""
    var amount = ""
    var amt: Int = 0
    var is_pinText = false
    var vpdPin = ""
    var note = ""
    var transaction_face = face

    
    
    var protocol_delegate = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(from_segue, ".............")
        textViewConfig()
        textViewArea.delegate = self
        
        if walletBalance != "" && currency != "" {
            balanceLabel.text = "\(currency ?? "")\(walletBalance ?? "")"
            walletType.text = "\(currency ?? "") Wallet"
        }
        
        //MARK: Should show when vpd account number is verified
        vpdAccountName.isHidden = true
        accountNameTextField.isHidden = true
        buttomTopConstraint.constant = 351
        
        zeroTextField.delegate = self
        pinTextField.isSecureTextEntry = true
        pinTextField.delegate = self
        vpdAcctNumberTextField.delegate = self;
        accountNameTextField.delegate = self;
        pinTextField.setLeftPaddingPoints(14)
        
        currencyLabel.text = currency
        
        balanceLabel.text = currentWalletSelected["balance"]
        
        zeroTextField.attributedPlaceholder = NSAttributedString(string: updateAmount()!,
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        zeroTextField.startBlink()
        
        
        // Do any additional setup after loading the view.
        vpdAcctNumberTextField.setLeftPaddingPoints(15)
        accountNameTextField.setLeftPaddingPoints(15)
        
        if from_segue == "withdraw" {
            vapdAccountNumberLabel.isHidden = true
            vpdAcctNumberTextField.isHidden = true
            headerLabel.text = "Make cardless withdrawal"
            transferbutton.setTitle("Create withdrawal pin", for: .normal)
        }
        
        if from_segue == "transfer" {
            textViewArea.isHidden = false
            transferbutton.setTitle("Verify VPD Account", for: .normal)
        }
        
        
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
        
        zeroTextField.inputAccessoryView = toolBar;
        pinTextField.inputAccessoryView = toolBar;
        vpdAcctNumberTextField.inputAccessoryView = toolBar;
        
        
    }
    
        override func viewWillAppear(_ animated: Bool) {
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewWasTapped)));
            
            zeroViewWrap.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(textFieldTapped)));

        };
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
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
    
    @objc func keyboardwillChangeTextView(notification: Notification) {
        
        guard   let userInfo = notification.userInfo as? [String: NSObject],
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect  else { return }
        
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification  {
            view.frame.origin.y = -keyboardFrame.height / 2.0
        }
        else {
            view.frame.origin.y = 0
        }
    }
    
    func textViewConfig() {
        textViewArea.font = .systemFont(ofSize: 15, weight: .semibold)
        
        textViewArea.text = "Add Note"
        textViewArea.textColor = .lightGray
        //textViewArea.textAlignment = .center
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Add Note"
            textView.textColor = .lightGray
            textViewArea.centerVertically()
        }
    }
    
     func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count + (text.count - range.length) <= 140
    }

    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
           
           NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillChangeTextView(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
           NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillChangeTextView(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
           NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillChangeTextView(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
           return true
       }
    
    
    //***********Method to handle date format and date dismiss*********//
    @objc func donePicker() {
        view.frame.origin.y = 0
        vpdPin = pinTextField.text!
        view.endEditing(true)
    }
    
    
    func updateAmount() -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        
        let amount = Double(amt/100) + Double(amt%100)/100
        
        return formatter.string(from: NSNumber(value: amount))
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        zeroTextField.stopBlink();
        print(textField.tag)
        if textField.tag == 4 {
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
    
    //MARK: - TEXT SHOULD RETURN
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        accountNameTextField.endEditing(true)
        return true
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        if textField.tag == 0 {
            if let digit = Int(string) {
                amt = amt * 10 + digit
                zeroTextField.text = updateAmount()
            }
            
            if string == "" {
                amt = amt/10
                zeroTextField.text = updateAmount()
            }
            
            return false
        }
            
        else if textField.tag == 4 {
            print("nil")
        }
        
        if vpdAcctNumberTextField.text!.count < 5 {
            transferbutton.setTitle("Verify VPD Account", for: .normal)
        }
        
        return true
    };
    
    
    func selectVPDContact(contact: VPDContacts) {
        
        vpdAccountName.isHidden = false
        accountNameTextField.isHidden = false
        buttomTopConstraint.constant = 351
        
        accountNameTextField.text = contact.name
        vpdAcctNumberTextField.text = contact.phone
        protocol_delegate = "CONTACT"
        
        transferbutton.setTitle("Transfer", for: .normal)
        
        zeroTextField.becomeFirstResponder()
        
    };
    
    
    @objc func textFieldTapped(sender: UIGestureRecognizer) {
        zeroTextField.becomeFirstResponder()
    }
    
    
    @objc func viewWasTapped (sender : UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    
    @IBAction func selectFromContactButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToSelectVPDContact", sender: self)
    }
    
    
    
    @IBAction func payNowButtonPressed(_ sender: Any) {
        note = textViewArea.text
        amount = zeroTextField.text!.split(separator: ",").joined()
        vpdPin = pinTextField.text!
        account_number = vpdAcctNumberTextField.text!
        
        if amount == "" {
            self.showToast(message: "Please enter an amount", font: UIFont(name: "Muli", size: 14)!)
            return
        }
            
        else if vpdAcctNumberTextField.text == "" {
            self.showToast(message: "Please enter account number", font: UIFont(name: "Muli", size: 14)!)
        }
            
        else if amount != "" && Double(amount)! < 100  {
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "Minimum amount for transaction is 100")
            self.present(alertVC, animated: true)
            return
        }
            
        else if vpdPin == "" {
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "Please enter your VPD Pin.")
            self.present(alertVC, animated: true)
        }
            
        else if amount != "" && transferbutton.titleLabel?.text == "Verify VPD Account" {
            makeVerificationAPI()
            return
        }
        else {
            
            if transaction_face && isUserFace == false {
                let alertSV = FaceID()
                let alert = alertSV.showFaceID()
                self.present(alert, animated: true)
            }
            else {
                //perform APiCall
                makeTransferAPI()
                view.endEditing(true)
                zeroTextField.resignFirstResponder()
            }
            
        }
        
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    
    
    //MARK: - ADD Comma to Text
    
    //MARK: This will post the data to Make Payment
    func makeTransferAPI(){
        
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
        
        var params = [String: String]()
        
        
        //******getting parameter from string
        if protocol_delegate == "CONTACT" {
            params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "phone": account_number, "type": "CONTACT", "WalletID": walletId ?? "", "amount": amount, "transaction_pin": vpdPin, "note": note, "auth_key": global_key ]
        }
        
            
        else {
            params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "accountNumber": account_number, "type": "wallet", "WalletID": walletId ?? "", "amount": amount, "transaction_pin": vpdPin, "auth_key": global_key ]
        }
        
        print(params)
        isUserFace = false
        
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
        
        postData(url: url, parameter: parameter, token: token, header: headers)
        
        global_key = ""
        print(global_key, "............keueyyeyeyy")
    }
    
    ///////////***********Post Data MEthod*********////////
    func postData(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        self.activityIndicator.startAnimating()
        self.viewWrapper.isUserInteractionEnabled = false
        self.transferbutton.isHidden = true
        
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
                    self.transferbutton.isHidden = false
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
                    
                else if (message == "Session not valid") {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.activityIndicator.stopAnimating()
                    self.viewWrapper.isUserInteractionEnabled = true
                    self.transferbutton.isHidden = false
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.activityIndicator.stopAnimating()
                self.viewWrapper.isUserInteractionEnabled = true
                self.transferbutton.isHidden = false
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    //MARK: This will post the data to Make Payment
    func makeVerificationAPI(){
        
        /******Import  and initialize Util Class*****////
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
        
        self.activityIndicator.startAnimating()
        self.viewWrapper.isUserInteractionEnabled = false
        self.transferbutton.isHidden = true
        
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
                    self.transferbutton.isHidden = false
                    
                    //MARK: Should show when vpd account number is verified
                    self.vpdAccountName.isHidden = false
                    self.accountNameTextField.isHidden = false
                    self.buttomTopConstraint.constant = 351
                    
                    self.accountNameTextField.text = decriptorJson["response"]["name"].stringValue
                    self.transferbutton.setTitle("Transfer", for: .normal)
                }
                    
                else if (message == "Session has expired") {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.activityIndicator.stopAnimating()
                    self.viewWrapper.isUserInteractionEnabled = true
                    self.transferbutton.isHidden = false
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.activityIndicator.stopAnimating()
                self.viewWrapper.isUserInteractionEnabled = true
                self.transferbutton.isHidden = false
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    
    
    
    // MARK - Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToGeneratePin" {
            let destinationVC = segue.destination as! Success2ViewController
            
            destinationVC.from_segue  = "pin"
            destinationVC.message = "Withdrawal Pin Created"
            destinationVC.linkOrPinAddress = "456334"
        }
        
        if segue.identifier == "goToSelectVPDContact" {
            let destination = segue.destination as! SelectVPDContactsViewController
            destination.from_protocol = self
        }
    }
    
}


