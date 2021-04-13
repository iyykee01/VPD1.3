//
//  HideSubAccountViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 07/02/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class HideSubAccountViewController: UIViewController {

    @IBOutlet weak var inviewButton: DesignableButton!
    @IBOutlet weak var hiddenButton: DesignableButton!
    @IBOutlet weak var tableView: UITableView!
    
    
    var subWalletArray = [Wallet]()
    var for_is_hidden = [Wallet]()

    var selected_subWallet: Wallet!
    var operation = ""
    var wallet_id = ""
       

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 90
        
        filter_sub_array()
    }
    

    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func filter_sub_array() {
        for_is_hidden = subWalletArray.filter({$0.hide == "NO"})
    
        tableView.reloadData()
        self.view.reloadInputViews()
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
         
         //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "operation": operation, "wallet": wallet_id]
         
         
         
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
         
         
         let url = "\(utililty.url)wallet"
         
         postToCallRecurring(url: url, parameter: parameter, token: token, header: headers)
     }
     
     //MARK: - VALIDATE
     ///////////***********Post Data MEthod*********////////
     func postToCallRecurring(url: String, parameter: [String: String], token: String, header: [String: String]) {
         
         let loader = LoaderPopup()
         let loaderVC = loader.Loader()
         self.present(loaderVC, animated: true)
         
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
                    self.dismiss(animated: true, completion: nil)
                    //showToast(message: message, font: 14.0)
                }
                else if (message == "Session has expired") {
                    self.dismiss(animated: true, completion: nil)
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.dismiss(animated: true, completion: nil)
                    self.view.isUserInteractionEnabled = true
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                    
                }
             }
             else {
                self.dismiss(animated: true, completion: nil)
                self.view.isUserInteractionEnabled = true
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
            }
            self.filter_sub_array()
         }
     }
    
    @IBAction func inviewButtonPressed(_ sender: Any) {
        inviewButton.setTitleColor(.black, for: .normal)
        inviewButton.backgroundColor = .white
        
        hiddenButton.setTitleColor(.darkGray, for: .normal)
        hiddenButton.backgroundColor = .clear
        for_is_hidden = subWalletArray.filter({$0.hide == "NO"})
        tableView.reloadData()
    }
    
    @IBAction func hiddenButtonPressed(_ sender: Any) {
       hiddenButton.setTitleColor(.black, for: .normal)
       hiddenButton.backgroundColor = .white
        
        inviewButton.setTitleColor(.darkGray, for: .normal)
        inviewButton.backgroundColor = .clear
        for_is_hidden = subWalletArray.filter({$0.hide == "YES"})
        tableView.reloadData()
    }
}

extension HideSubAccountViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return for_is_hidden.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HideSubAccountTableViewCell
            
        let dic = for_is_hidden[indexPath.row]
        
        if dic.currency == "NGN" {
            cell.imageThumbnail.image = UIImage(named: "flag")
            cell.name_of_currency.text = "Nigeria Naira"
        }
        else if dic.currency == "GBP" {
            cell.imageThumbnail.image = UIImage(named: "uk")
            cell.name_of_currency.text = "British Pounds"
        }
        else if dic.currency == "USD" {
            cell.imageThumbnail.image = UIImage(named: "us")
            cell.name_of_currency.text = "American Dollar"
        }
        else {
            cell.imageThumbnail.image = UIImage(named: "eu")
            cell.name_of_currency.text = "Euro"
        }

        
        if dic.hide == "YES" {
            cell.currency.text = dic.currency
            cell.hide_sub_acct.text = "Unhide account"
            cell.hidden_image.image = UIImage(named: "hidden")
        }
        else {
            cell.currency.text = dic.currency
            cell.hide_sub_acct.text = "Hide account"
            cell.hidden_image.image = UIImage(named: "eye1")
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected_subWallet = for_is_hidden[indexPath.row]
        wallet_id = selected_subWallet.wallet_uid
        
        if selected_subWallet.hide == "YES" {
            selected_subWallet.hide = "NO"
            
            operation = "show"
            callListOfRecuringID()
            inviewButton.setTitleColor(.black, for: .normal)
            inviewButton.backgroundColor = .white
            
            hiddenButton.setTitleColor(.darkGray, for: .normal)
            hiddenButton.backgroundColor = .clear
        }
        else {
            selected_subWallet.hide = "YES"
            operation = "hide"
            callListOfRecuringID()
            
            
        }
        
    }
    
}
