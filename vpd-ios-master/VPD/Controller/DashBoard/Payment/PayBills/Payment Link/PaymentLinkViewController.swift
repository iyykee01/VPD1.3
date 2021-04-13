//
//  PaymentLinkViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 21/11/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage


class PaymentLinkViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var textViewArea: UITextView!
    @IBOutlet weak var zeroViewWrap: UIView!
    @IBOutlet weak var zeroTextField: UITextField!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var pinTextField: UITextField!
    
    @IBOutlet weak var viewToshow: DesignableView!
    @IBOutlet weak var constraint_to_control_TextView: NSLayoutConstraint!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    /////
    @IBOutlet weak var walletTextField: DesignableUITextField!
    @IBOutlet weak var walletWrapper: DesignableView!
    @IBOutlet weak var vpdPinLabel: UILabel!
    @IBOutlet weak var vpdPINLineView: UIView!
    @IBOutlet weak var convenienceFeeLabel: UILabel!
    
     let piker1 = UIPickerView()

    
    ////////
    @IBOutlet weak var generate_link_button: UIButton!
    
    var walletId = ""
    var from_segue = ""
    var image = ""
    var name = ""
    var number = ""
    var link = ""
    var pay_link: Int?
    var amt: Int = 0
    
    
    
    var segue_bank_code = ""
    var segue_accountNumber =  ""
    var amount = ""
    var walletID = ""
    var save = ""
    var note = ""
    
    var message = ""
    
    var currency = ""
    var code = ""
    var vpdPin = ""
    var isUserFaceID = "";
    
    
    var from_notifications = ""
    var transaction_face = face
    
    var btf_amount_start = LoginResponse["response"]["charges"]["bank_transfer_fee"]["NGN"].arrayValue[0]["amount_start"].stringValue
    
     var btf_amount_end = LoginResponse["response"]["charges"]["bank_transfer_fee"]["NGN"].arrayValue[0]["amount_end"].stringValue
    
     var btf_amount_value = LoginResponse["response"]["charges"]["bank_transfer_fee"]["NGN"].arrayValue[0]["value"].stringValue
    
    var btf_amount_start2 = LoginResponse["response"]["charges"]["bank_transfer_fee"]["NGN"].arrayValue[1]["amount_start"].stringValue
       
        var btf_amount_end2 = LoginResponse["response"]["charges"]["bank_transfer_fee"]["NGN"].arrayValue[1]["amount_end"].stringValue
       
        var btf_amount_value2 = LoginResponse["response"]["charges"]["bank_transfer_fee"]["NGN"].arrayValue[1]["value"].stringValue
    
    var btf_amount_start3 = LoginResponse["response"]["charges"]["bank_transfer_fee"]["NGN"].arrayValue[2]["amount_start"].stringValue
       
        var btf_amount_end3 = LoginResponse["response"]["charges"]["bank_transfer_fee"]["NGN"].arrayValue[2]["amount_end"].stringValue
       
        var btf_amount_value3 = LoginResponse["response"]["charges"]["bank_transfer_fee"]["NGN"].arrayValue[2]["value"].stringValue

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //currencyLabel.text = currency
        
        print(pay_link ?? "none")
        textViewArea.delegate = self
        zeroTextField.delegate = self
        
        zeroTextField.attributedPlaceholder = NSAttributedString(string: updateAmount()!,
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        zeroTextField.startBlink()
        
        walletTextField.setLeftPaddingPoints(15)
        
        
        piker1.dataSource = self
        piker1.delegate = self
        pinTextField.delegate = self
        
        print(from_notifications, from_segue)
     
//        textViewArea.centerVertically()
        textViewConfig()
        
        if from_segue == "contact link" {
            viewToshow.isHidden = false
            
            imageView!.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: ""))
            nameLabel.text = name
            numberLabel.text = number
            //constraint_to_control_TextView.constant =
            pinTextField.isHidden = true
            vpdPinLabel.isHidden = true
            vpdPINLineView.isHidden = true
            return
        }
        if from_segue == "link" {
            //heightConstraint.constant = 0 // 90
            
            //generate_link_button.setTitle("Next", for: .normal)
            viewToshow.isHidden = true
            imageView.image = nil
            nameLabel.text = ""
            numberLabel.text = ""
            constraint_to_control_TextView.constant = 200
            pinTextField.isHidden = true
            vpdPinLabel.isHidden = true
            vpdPINLineView.isHidden = true
            return
        }
        
        if from_segue == "transfer" {
            generate_link_button.setTitle("Make Transfer", for: .normal)
            viewToshow.isHidden = true
            walletWrapper.isHidden = true
            imageView.image = nil
            nameLabel.text = ""
            numberLabel.text = ""
            constraint_to_control_TextView.constant = 200
            convenienceFeeLabel.isHidden = false
            convenienceFeeLabel.text = "You'll be charged NGN\(btf_amount_start) - NGN\(btf_amount_end) NGN(\(btf_amount_value)), NGN\(btf_amount_start2) - NGN\(btf_amount_end2) NGN(\(btf_amount_value2)), NGN\(btf_amount_start3) and above NGN(\(btf_amount_value3)) for this transaction"
            
            return
        }
        
        if from_segue == "notifications" {
            generate_link_button.setTitle("Pay request", for: .normal)
            viewToshow.isHidden = false
            walletWrapper.isHidden = false
            imageView.image = nil
            nameLabel.text = name
            textViewArea.text = note
            numberLabel.text = number
            constraint_to_control_TextView.constant = 275
            zeroTextField.text = amount
            zeroTextField.isUserInteractionEnabled = false
            zeroTextField.stopBlink()
            return
        }
        
        //print(segue_bank_code, segue_accountNumber, walletID, "print me bitch........")
       
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
        pinTextField.inputAccessoryView = toolBar

    }
    
      override func viewDidAppear(_ animated: Bool) {
          walletTextField.inputView = piker1
      }

    override func viewWillAppear(_ animated: Bool) {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewWasTapped)))
        zeroViewWrap.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(textFieldTapped)))
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    @objc func keyboardwillChange(notification: Notification) {
        
        guard   let userInfo = notification.userInfo as? [String: NSObject],
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect  else { return }
        
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification  {
            view.frame.origin.y = -keyboardFrame.height / 2.0
        }
        else {
            view.frame.origin.y = 0
        }
        
    }
    
      
      //***********Method to handle date format and date dismiss*********//
    @objc func donePicker() {
        view.frame.origin.y = 0
        vpdPin = pinTextField.text!
        view.endEditing(true)
    }
    
    
    //MARK - ADD Comma to Text
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        print(textField.tag, ".........Text Field")
        
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
            
        else if textField.tag == 3 {
            print("nil")
        }
        return true
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
        if textField.tag == 3 {
            
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        }
        else {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil);
            view.frame.origin.y = 0
        }
        zeroTextField.stopBlink()
    }
   
    
    @objc func textFieldTapped(sender: UIGestureRecognizer) {
        zeroTextField.becomeFirstResponder()
    }
    
    @objc func viewWasTapped (sender : UITapGestureRecognizer) {
        //let amount_entered = Double(zeroTextField.text!)
        vpdPin = pinTextField.text!
        view.endEditing(true)
        
        if zeroTextField.text == "" {
            zeroTextField.startBlink()
            return
        }
    }
    
     //MARK: - Transfer to  Bank Acount************************ ANd to be moves
     func transferToBankAPI(){
         
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
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "SessionID": session, "CustomerID": customer_id, "bank_code": segue_bank_code, "type": "bank", "accountNumber": segue_accountNumber, "WalletID": walletID, "amount": amount, "save": save, "note":  "", "transaction_pin": vpdPin, "auth_key": global_key]
        
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
         
      
         
         let url = "\(utililty.url)transfer_funds"
         
        postForTransfer(url: url, parameter: parameter, token: token, header: headers);
        global_key = ""
        isUserFace = false
     }

     
     // MARK: - NETWORK CALL- Post TO LIST OF BANKs
     func postForTransfer(url: String, parameter: [String: String], token: String, header: [String: String]) {
         
         self.activityIndicator.startAnimating()
        self.generate_link_button.isHidden = true
         
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
                    self.generate_link_button.isHidden = false
                    self.activityIndicator.stopAnimating()
                    self.message = message
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
                     
                     
                 else if (message == "Session has expired") {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                 }
                     
                 else {
                     self.generate_link_button.isHidden = false
                     self.activityIndicator.stopAnimating()
                     let alertService = AlertService()
                     let alertVC =  alertService.alert(alertMessage: message)
                     self.present(alertVC, animated: true)
                 }
             }
             else {
                self.generate_link_button.isHidden = false
                 self.activityIndicator.stopAnimating()
                 let alertService = AlertService()
                 let alertVC =  alertService.alert(alertMessage: "Network Error")
                 self.present(alertVC, animated: true)
                 
             }
         }
     }
    
    
    //MARK: - request payment link / pay
    func requestPaymentPayAPI(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "SessionID": session, "CustomerID": customer_id, "operation": "pay", "wallet": walletId, "paymentcode": code, "transaction_pin": vpdPin]
        
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
        
     
        
        let url = "\(utililty.url)request_payment"
        
        postForrequestPaymentPay(url: url, parameter: parameter, token: token, header: headers)
    }

    
    // MARK: - NETWORK CALL- Post TO LIST OF BANKs
    func postForrequestPaymentPay(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        self.activityIndicator.startAnimating()
       self.generate_link_button.isHidden = true
        
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
                   self.generate_link_button.isHidden = false
                   self.activityIndicator.stopAnimating()
                   self.message = message
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
                    
                    
                else if (message == "Session has expired") {
                   self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.generate_link_button.isHidden = false
                    self.activityIndicator.stopAnimating()
                    let alertService = AlertService()
                    let alertVC =  alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
               self.generate_link_button.isHidden = false
                self.activityIndicator.stopAnimating()
                let alertService = AlertService()
                let alertVC =  alertService.alert(alertMessage: "Network Error")
                self.present(alertVC, animated: true)
                
            }
        }
    }
    

    func textViewConfig() {
        textViewArea.font = .systemFont(ofSize: 16, weight: .semibold)
        
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

    
    //MARK: - ApI to requestLink************************
        func requestLinkAPI(){
            
            /******Import  and initialize Util Class*****////
            let utililty = UtilClass()
            
            let device = utililty.getPhoneId()
            
            //print("shaDevicePpties")
            let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
            let timeInSecondsToString = String(timeInSeconds)
            
            let session = UserDefaults.standard.string(forKey: "SessionID")!
            let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
           
            //var params_to_post = [String: String]()
            
            //******getting parameter from string
            let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "SessionID": session, "CustomerID": customer_id, "operation": "request", "wallet": walletId, "phone": number, "amount": amount, "note": note]
            
            
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
            
         
            
            let url = "\(utililty.url)request_payment"
            
            requestLinkPost(url: url, parameter: parameter, token: token, header: headers)
        }

        
        // MARK: - NETWORK CALL- Post TO request Linke
        func requestLinkPost(url: String, parameter: [String: String], token: String, header: [String: String]) {
            
            self.activityIndicator.startAnimating()
           self.generate_link_button.isHidden = true
            
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
                        
                        self.activityIndicator.stopAnimating()
                        self.message = message
                        self.link = decriptorJson["response"]["url"].stringValue
                        self.performSegue(withIdentifier: "goToShareLink", sender: self)
                    }
                        
                        
                    else if (message == "Session has expired") {
                        UserDefaults.standard.removeObject(forKey: "SessionID")
                        UserDefaults.standard.synchronize()
                        self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                    }
                        
                    else {
                        self.generate_link_button.isHidden = false
                        self.activityIndicator.stopAnimating()
                        let alertService = AlertService()
                        let alertVC =  alertService.alert(alertMessage: message)
                        self.present(alertVC, animated: true)
                    }
                }
                else {
                   self.generate_link_button.isHidden = false
                    self.activityIndicator.stopAnimating()
                    let alertService = AlertService()
                    let alertVC =  alertService.alert(alertMessage: "Network Error")
                    self.present(alertVC, animated: true)
                    
                }
           
            }
        }


    @IBAction func generateLinkPressed(_ sender: Any) {
        
        amount = zeroTextField.text!.split(separator: ",").joined();
        print(amount, vpdPin, isUserFace, walletId)
        vpdPin = pinTextField.text!
        
        if  generate_link_button.titleLabel?.text == "Make Transfer" {
            if vpdPin == "" || amount == "" {
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Please fill all fields.")
                self.present(alertVC, animated: true)
                return
            }
            
            if generate_link_button.titleLabel?.text == "Make Transfer" && Double(amount)! <= 100 {
                //Alert something
                let alertService = AlertService()
                let alertVC =  alertService.alert(alertMessage: "Minimum amount for transaction is 100")
                self.present(alertVC, animated: true)
                return
            }
            
            
            if generate_link_button.titleLabel?.text == "Make Transfer" {
                
                note = textViewArea.text
                if transaction_face && isUserFace == false {
                    let alertSV = FaceID()
                    let alert = alertSV.showFaceID()
                    self.present(alert, animated: true)
                }
                else {
                    transferToBankAPI()
                }
                return
            }
        }

        

        if generate_link_button.titleLabel?.text == "Pay request"  {
            vpdPin = pinTextField.text!
            requestPaymentPayAPI()
            return
        }


        else {
            //Call Api for request link
            textViewArea.resignFirstResponder()
            requestLinkAPI()
            print("call2")
        }
        
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dropDownButtonPressed (_ sender: Any){
        walletTextField.becomeFirstResponder()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier ==  "goToShareLink" {
            let destination = segue.destination as! Success2ViewController
            
            destination.from_segue = "link"
            destination.linkOrPinAddress = link
            destination.message = message
        }
        
        if segue.identifier ==  "goToSuccess" {
            let destination = segue.destination as! FailedControllerViewController
            destination.from_segue = message
        }
    }
}

extension PaymentLinkViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       
        return accountArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
   
        return accountArray[row].currency
    
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    
        walletTextField.text = "\(accountArray[row].currency) - Wallet"
        walletId = accountArray[row].wallet_uid
        self.view.endEditing(false)

    }
    
}

      
      
    

