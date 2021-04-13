//
//  WalletFundingWithCardViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 24/07/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import Stripe
import CreditCardForm

class WalletFundingWithCardViewController: UIViewController, STPPaymentCardTextFieldDelegate, UITextFieldDelegate {
    
    
    var fund_type = "card"
    var walletID = ""
    var amount = ""
    var currency = ""
    
    @IBOutlet weak var viewWrapper: UIView!
    @IBOutlet weak var activitiyIndicator: UIActivityIndicatorView!
    @IBOutlet weak var fundButton: DesignableButton!
    @IBOutlet weak var voguepayLogo: UIImageView!
    
    @IBOutlet weak var creditCardForm: CreditCardFormView!
    
    // Stripe textField
    let paymentTextField = STPPaymentCardTextField()
    
    var cardExpirationMonth = ""
    var cardExpirationYear = ""
    var cardNumber = ""
    var cvc = ""
    
    
    
    //*******From login response********///
    var loginRes = LoginResponse["response"]
    
    
    //********Url From response*******//
    var url = ""
    var transactionID = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()

     
        print(walletID, amount, currency, "..............")
        
        // Do any additional setup after loading the view.
        // Set up stripe textfield
        paymentTextField.frame = CGRect(x: 15, y: 199, width: self.view.frame.size.width - 30, height: 44)
        paymentTextField.translatesAutoresizingMaskIntoConstraints = false
       
        
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: paymentTextField.frame.size.height - width, width:  paymentTextField.frame.size.width, height: paymentTextField.frame.size.height)
        //border.borderWidth = width
        
        paymentTextField.layer.addSublayer(border)
        paymentTextField.layer.masksToBounds = true
        
        view.addSubview(paymentTextField)
        
        NSLayoutConstraint.activate([
            paymentTextField.topAnchor.constraint(equalTo: creditCardForm.bottomAnchor, constant: 20),
            paymentTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            paymentTextField.widthAnchor.constraint(equalToConstant: self.view.frame.size.width - 50),
            paymentTextField.heightAnchor.constraint(equalToConstant: 44)
            ])
        paymentTextField.delegate = self

        
        
//        let fullname = loginRes["lastname"].stringValue + " " + loginRes["firstname"].stringValue
        
//        creditCardForm.cardHolderString = ""
        creditCardForm.chipImage = UIImage(named: "")
        //creditCardForm.cardHolderPlaceholderString =  ""
//        creditCardForm.expireDatePlaceholderText = ""
//        creditCardForm.cardHolderExpireDateColor = .clear
//        creditCardForm.cardHolderExpireDateTextColor = .clear
        
        
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
        self.viewWrapper.addGestureRecognizer(gesture)
        
        
        activitiyIndicator.isHidden = true
    }
    
    
    
    @objc func checkAction(sender : UITapGestureRecognizer) {
        self.paymentTextField.resignFirstResponder()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK - This will check the state of switch Button to eitheer save card or nah
     var saveCardStatus = "0"
    //MARK: - Switch button from UI
    @IBAction func mySwiftPressed(_ sender: UISwitch) {
        if(sender.isOn == true){
            saveCardStatus = "1"
        }
        else {
            saveCardStatus = "0"
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
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        let card_month = paymentTextField.expirationMonth
        var card_moth_to_post = ""
        
        if card_month < 10 {
            card_moth_to_post = "0\(String(paymentTextField.expirationMonth))"
        }
        else {
            card_moth_to_post = String(paymentTextField.expirationMonth)
        }
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "amount": amount, "WalletID": walletID, "currency": currency, "fund_type": "card", "card_pan": paymentTextField.cardNumber!, "card_month": card_moth_to_post, "card_year": String(paymentTextField.expirationYear), "card_cvv": paymentTextField.cvc!, "save_card": saveCardStatus]
        
        
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
        
        
        let url = "\(utililty.url)wallet_funding"
        
        postData(url: url, parameter: parameter, token: token, header: headers)
    }
    
    ///////////***********Post Data MEthod*********////////
    func postData(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        fundButton.isHidden = true
        activitiyIndicator.isHidden = false
        activitiyIndicator.startAnimating()
        
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
                    self.fundButton.isHidden = false
                    self.activitiyIndicator.isHidden = true
                    self.activitiyIndicator.stopAnimating()
                    
                    self.url = decriptorJson["response"]["redirect_url"].stringValue
                    self.transactionID = decriptorJson["response"]["transaction_id"].stringValue
                    self.performSegue(withIdentifier: "goToWebView", sender: self)
                }
                    
                else if (message == "Session has expired") {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.fundButton.isHidden = false
                    self.activitiyIndicator.isHidden = true
                    self.activitiyIndicator.stopAnimating()
                    
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.fundButton.isHidden = false
                self.activitiyIndicator.isHidden = true
                self.activitiyIndicator.stopAnimating()
                
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
                //self.delayToNextPage()
            }
        }
    }
    
    
    //MARK: - fund wallet button pressed
    @IBAction func fundAccountButttonPressed(_ sender: Any) {
        
        print(fund_type, walletID, amount, currency)
        
       //*****THis will call a post method*******//
        if paymentTextField.hasText {
            delayToNextPage()
        }
        else {
            ////From the alert Service
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "Please enter a valid card")
            self.present(alertVC, animated: true)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let WBVC = segue.destination as! WebViewViewController
        if segue.identifier == "goToWebView" {
            WBVC.transactionID = transactionID
            WBVC.url = url
        }
    }
    
    
    
    
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        creditCardForm.paymentCardTextFieldDidChange(cardNumber: textField.cardNumber, expirationYear: textField.expirationYear, expirationMonth: textField.expirationMonth, cvc: textField.cvc)
    }
    func paymentCardTextFieldDidEndEditingExpiration(_ textField: STPPaymentCardTextField) {
        creditCardForm.paymentCardTextFieldDidEndEditingExpiration(expirationYear: textField.expirationYear)
    }
    
    func paymentCardTextFieldDidBeginEditingCVC(_ textField: STPPaymentCardTextField) {
        creditCardForm.paymentCardTextFieldDidBeginEditingCVC()
    }
    
    func paymentCardTextFieldDidEndEditingCVC(_ textField: STPPaymentCardTextField) {
        creditCardForm.paymentCardTextFieldDidEndEditingCVC()
    }

}
