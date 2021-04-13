
//  FundWalletViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 09/07/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FundWalletViewController: UIViewController, UITextFieldDelegate, seguePerform {
    
    
    
    @IBOutlet var viewWrapper: UIView!
    @IBOutlet weak var zeroViewWrap: UIView!
    @IBOutlet weak var zeroTextField: UITextField!
    @IBOutlet weak var dropDownButton: UIButton!
    @IBOutlet weak var selectPayementVIew: DesignableView!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var currencyBalanceLabel: UILabel!
    @IBOutlet weak var currencyWallet: UILabel!
    
    @IBOutlet weak var stackMultiplier: NSLayoutConstraint!
    
    var walletID = ""
    var currency = ""
    var balance = ""
    var userInputAmount = ""
    
    var account_no = ""
    var holder = ""
    var reference = ""
    var bank = ""
    var amt: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        zeroTextField.delegate = self
        
        
        zeroTextField.attributedPlaceholder = NSAttributedString(string: updateAmount()!,
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
//        zeroTextField.placeholder = updateAmount()
        
        print(currency, walletID)
        
        zeroTextField.startBlink()
        
        currencyLabel.text = currency
        currencyWallet.text = "\(currency) Wallet"
        currencyBalanceLabel.text = "\(currency) \(balance)"
        
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
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        viewWrapper.addGestureRecognizer(tap)
        
    }
    
    //***********Method to handle date format and date dismiss*********//
    @objc func donePicker() {
        zeroTextField.resignFirstResponder()
    }

    
    func updateAmount() -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        
        let amount = Double(amt/100) + Double(amt%100)/100
        
        return formatter.string(from: NSNumber(value: amount))
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
       
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        zeroTextField.stopBlink()
    }
  
    //MARK: - Textfield delegate method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let splited_text = zeroTextField.text!.split(separator: ",")
        userInputAmount = String(splited_text[0])
        
        zeroTextField.resignFirstResponder()
        
        if zeroTextField.text == "" {
            zeroTextField.startBlink()
        }
        view.endEditing(true)
        return false
    }
    
    //MARK: -Delay function @if token is true move to next//
    func delayToNextPage() {
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "amount": userInputAmount, "WalletID": walletID, "currency": currency, "fund_type": "bank"]
        
        
        
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Change `2.0` to the desired number of seconds.
            // Code you want to be delayed
            let loader = LoaderPopup()
            let loaderVC = loader.Loader()
            self.present(loaderVC, animated: true)
        }
        
        
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
                
                let decriptorJsonResponse = decriptorJson["response"]
                
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                
                
                if status {
                    //********Response from server *******//
                    self.dismiss(animated: true, completion: nil)
                    self.account_no = decriptorJsonResponse["account_no"].stringValue
                    self.holder = decriptorJsonResponse["holder"].stringValue
                    self.reference = decriptorJsonResponse["reference"].stringValue
                    self.bank = decriptorJsonResponse["bank"].stringValue
                    
                    self.performSegue(withIdentifier: "goToBackTransfer", sender: self)
                }
                    
                else if (message == "Session has expired") {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.dismiss(animated: true, completion: nil)
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                    
                }
            }
            else {
                self.dismiss(animated: true, completion: nil)
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Network Error")
                self.present(alertVC, animated: true)
                
            }
        }
    }
    
    
    
    func goNext(next: String) {
        if next == "goToBackTransfer" {
            //Call api
            delayToNextPage()
            return
        }
        else {
            performSegue(withIdentifier: next, sender: self)
        }
        
    }
    
    func validate() {
        userInputAmount = zeroTextField.text!.split(separator: ",").joined()
        
        if (zeroTextField.text != "") && Double(userInputAmount)! < 100 {
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "Minimum amount for transaction is 100")
            self.present(alertVC, animated: true)
        }
        
        if(zeroTextField.text == ""){
            self.showToast(message: "Please enter an amount", font: UIFont(name: "Muli", size: 14)!)
        }
            
        else {
            view.endEditing(true)
            zeroTextField.resignFirstResponder()
            performSegue(withIdentifier: "goToFundWalletPopUp", sender: self)
        }
    }
    
    
    //MARK - ADD Comma to Text
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        selectPayementVIew.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewWasTapped)))
        zeroViewWrap.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(textFieldTapped)))
        
    }
    
    @objc func textFieldTapped(sender: UIGestureRecognizer) {
        zeroTextField.becomeFirstResponder()
    }
    
    
    @objc func viewWasTapped (sender : UITapGestureRecognizer) {
        self.validate()
    }
    
    
    //MARK: - DropDown Button
    @IBAction func dropDownButtonPressed(_ sender: Any) {
        self.validate()
    }
    
    // MARK - Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCard" {
            let destinationVC = segue.destination as! DebitCreditCardViewController
            
            destinationVC.walletID = walletID
            destinationVC.amount = userInputAmount
            destinationVC.currency = currency
            
        }
        if segue.identifier == "goStraightToCard" {
            let destinationVC = segue.destination as! WalletFundingWithCardViewController
            
            destinationVC.walletID = walletID
            destinationVC.amount = userInputAmount
            destinationVC.currency = currency
            
        }
        
        
        if segue.identifier == "goToFundWalletPopUp" {
            let destinationVC = segue.destination as! FundWalletPopupViewController
            destinationVC.delegate = self
            
        }
        
        if segue.identifier == "goToBackTransfer" {
            let destination = segue.destination as! BankTransferViewController
            destination.account_no = account_no
            destination.holder = holder
            destination.reference = reference
            destination.bank = bank
        }
        
        if segue.identifier == "goToSelectBank" {
            let destination = segue.destination as! FundWalletLoaderViewController
            
            destination.walletID = walletID
            destination.amount = userInputAmount
            destination.currency = currency
            
        }
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}



