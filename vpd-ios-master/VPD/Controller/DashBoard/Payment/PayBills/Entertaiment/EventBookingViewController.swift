//
//  EventBookingViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 22/11/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class EventBookingViewController: UIViewController, UITextFieldDelegate {
    
    var from_segue: Tickets!
    
    @IBOutlet weak var numberLabel: DesignableLabel!
    @IBOutlet weak var walletTextField: DesignableUITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pay_for_ticket: DesignableButton!
    @IBOutlet weak var cancelButton: DesignableButton!
    @IBOutlet weak var priceLable: UILabel!
    
    var count = 1
    var message = ""
    var walletId = ""
    var quantity = ""
    var test: String!
    
    let piker = UIPickerView()
    
    @IBOutlet weak var vpdPinTextLabel: UILabel!
    @IBOutlet weak var vpdPinTextField: UITextField!

    @IBOutlet weak var convenienceFeeLabel: UILabel!
    
    
    var fee_for_trans = LoginResponse["response"]["charges"]["event_convenience_fee"]["NGN"]["value"].stringValue
    
    var vpdPin = ""
    var transaction_face = face
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        convenienceFeeLabel.text = "You'll be charged NGN\(fee_for_trans) convenience fee for this."
        // Do any additional setup after loading the view.
        
        
        walletTextField.setLeftPaddingPoints(15)
        vpdPinTextField.setLeftPaddingPoints(15)
        
        
        piker.dataSource = self
        piker.delegate = self
        vpdPinTextField.delegate = self
        
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
        
        walletTextField.inputView = piker
        
        walletTextField.inputAccessoryView = toolBar
        vpdPinTextField.inputAccessoryView = toolBar;
        
        priceLable.text = from_segue.price
        numberLabel.text = "1"
        quantity = "1"
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        walletTextField.inputView = piker
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
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    
    //***********Method to handle date format and date dismiss*********//
    @objc func donePicker(datePicker: UIDatePicker) {
        view.endEditing(true)
        vpdPin = vpdPinTextField.text!
        view.frame.origin.y = 0
        
    }
    
    
    //MARK: page+++++++===========//
    func makeServerCall(){
        
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
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "SessionID": session, "CustomerID": customer_id, "operation": "purchase", "wallet": walletId, "quantity": quantity, "TicketID": from_segue.id, "transaction_pin": vpdPin,
                      "auth_key": global_key]
       
        
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
        
        print(token)
        
        let url = "\(utililty.url)events"
        
        apiCall(url: url, parameter: parameter, token: token, header: headers)
        global_key = ""
        isUserFace = false
    }
    
    
    ///////////***********Post Data MEthod*********////////
    func apiCall(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        self.activityIndicator.startAnimating()
        self.pay_for_ticket.isHidden = true
        self.cancelButton.isHidden = true
        
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
                
                //*******Parameters for successful response and for data response*******///
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                
                if(status) {
                    self.activityIndicator.stopAnimating()
                    self.pay_for_ticket.isHidden = false
                    self.cancelButton.isHidden = false
                    self.message = message
                    let alertSV = SuccessAlertTransaction()
                    let alert = alertSV.alert(success_message: message) {
                        self.navigationController?.popToViewController(ofClass: ServicesViewController.self)
                    }
                    self.present(alert, animated: true)
                    
                }
                    
                else if  message == "Session has expired" {
                    self.pay_for_ticket.isHidden = false
                    self.cancelButton.isHidden = false
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    //*******check if delegate is not nil*********
                    self.pay_for_ticket.isHidden = false
                    self.cancelButton.isHidden = false
                    self.activityIndicator.stopAnimating()
                    self.message = message
                    
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
                
            }
            else {
                self.pay_for_ticket.isHidden = false
                self.cancelButton.isHidden = false
                self.activityIndicator.stopAnimating()
                self.message = "Nework Error"
                
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: self.message)
                self.present(alertVC, animated: true)
                
            }
            
        }
    }
    
    
    @IBAction func payForTicketButtonPressed(_ sender: Any) {
        let wallet = walletTextField.text!.split(separator: " ")
        vpdPin = vpdPinTextField.text!
        
        if vpdPin == "" {
            let alertService = AlertService()
            let alertVC =  alertService.alert(alertMessage: "Please enter your pin")
            self.present(alertVC, animated: true)
            return
        }
        
        if wallet.count != 3 {
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "Please Select Wallet currency")
            self.present(alertVC, animated: true)
            
             return
        }
        else {
            if transaction_face && isUserFace == false {
                let alertSV = FaceID()
                let alert = alertSV.showFaceID()
                self.present(alert, animated: true)
            }
            else {
                makeServerCall()
            }
            
        }
    }
    
    @IBAction func numberOfTicketsPressed(_ sender: UIButton) {
        let price = Int(from_segue.price) ?? 0

        switch sender.tag {
        case 1:
            count += 1
            let add = price * count
            priceLable.text = "\(add)"
            numberLabel.text = "\(count)"
            quantity = "\(count)"
            
        break
        default:
            if count != 1 {
                count -= 1
                let add = price / count
                priceLable.text = String(add)
                numberLabel.text = "\(count)"
                quantity = "\(count)"
            }
            
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let des = segue.destination as! FailedControllerViewController
        des.from_segue = message
    }
    
}



extension EventBookingViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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
        
    }
    
}




