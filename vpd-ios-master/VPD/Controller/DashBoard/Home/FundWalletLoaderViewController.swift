//
//  FundWalletLoaderViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 18/07/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FundWalletLoaderViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var backButtonOutlet: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var selecBankTextField: UITextField!
    @IBOutlet weak var activityIndicator2: UIActivityIndicatorView!
    @IBOutlet weak var nextButton: UIButton!
    
    
    var fund_type = ""
    var walletID = ""
    var amount = ""
    var currency = ""
    
    
    var transaction_id = ""
    var ussd_code = ""
    var bank_code = ""
    
    var bankArray = [ListOfBanks]()
    var walletArray = accountArray
    
    let piker1 = UIPickerView()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(fund_type, walletID, amount, currency)
        view.isUserInteractionEnabled = false
        selecBankTextField.setLeftPaddingPoints(15)
        
        piker1.dataSource = self
        piker1.delegate = self
        selecBankTextField.inputView = piker1
        
        
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
        selecBankTextField.inputAccessoryView = toolBar
        
        
        listOfBankAPI()
    }
    
    //***********Method to handle date format and date dismiss*********//
    @objc func donePicker(datePicker: UIDatePicker) {
        listOfBankAPI()
        selecBankTextField.resignFirstResponder()
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
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "amount": amount, "WalletID": walletID, "currency": currency, "fund_type": "ussd", "bank_code": bank_code]
        

        
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
        print("call me next")
         nextButton.isHidden = true
        self.activityIndicator.startAnimating()
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
                    self.nextButton.isHidden = false
                    self.activityIndicator.stopAnimating()
                    self.transaction_id = decriptorJsonResponse["transaction_id"].stringValue
                    self.ussd_code = decriptorJsonResponse["ussd_code"].stringValue
                    self.performSegue(withIdentifier: "goToUSSD", sender: self)
                }
                
                else if (message == "Session has expired") {
                    UserDefaults.standard.removeObject(forKey: "SessionID")
                    UserDefaults.standard.synchronize()
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.nextButton.isHidden = false
                    ////From the alert Service
                    self.activityIndicator.stopAnimating()
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                    self.backButtonOutlet.isHidden = false
                }
            }
            else {
                ////From the alert Service
                self.nextButton.isHidden = false
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Network Error")
                self.present(alertVC, animated: true)
                //self.delayToNextPage()
                self.backButtonOutlet.isHidden = false
            }
        }
    }
    
    
    //MARK: - DashBoard API HERE(Transaction History)************************
       //++++++=========Delay function @if token is true move to next page+++++++===========//
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
           print("call me first")
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
                       self.bankArray = [ListOfBanks]()
                       for i in decriptorJson["response"].arrayValue {

                           let bank_list = ListOfBanks()

                           bank_list.bank_name = i["bank_name"].stringValue
                           bank_list.id = i["id"].stringValue
                           bank_list.bank_code = i["bank_code"].stringValue
                           bank_list.logo = i["logo"].stringValue
                           bank_list.iso3 = i["iso3"].stringValue

                           self.bankArray.append(bank_list)

                       }
                       
                       self.activityIndicator2.stopAnimating()
                   }
                       
                   else if (message == "Session has expired") {
                    UserDefaults.standard.removeObject(forKey: "SessionID")
                    UserDefaults.standard.synchronize()
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
    
    
    
    //MARK: - Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToUSSD" {
            let destinationVC = segue.destination as! USSDViewController
            
            destinationVC.ussdCode =  ussd_code
            destinationVC.transaction_id = transaction_id
        }
    }
    
    
    
    @IBAction func gobackButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dropDownButtonPressed(_ sender: Any) {
        selecBankTextField.becomeFirstResponder()
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        delayToNextPage()
    }
    
    
    
}


extension FundWalletLoaderViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return bankArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return bankArray[row].bank_name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        selecBankTextField.text = bankArray[row].bank_name
        bank_code = bankArray[row].bank_code
    }
    
}






