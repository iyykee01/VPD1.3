//
//  payacontactLoaderViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 16/09/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class payacontactLoaderViewController: UIViewController {
    
    @IBOutlet weak var circle4: UIImageView!
    @IBOutlet weak var circle1: UIImageView!
    @IBOutlet weak var circle2: UIImageView!
    @IBOutlet weak var circle3: UIImageView!
    
    var fund_type = "phone"
    var walletID = ""
    var amount = ""
    var phone = ""
    var note = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        print(fund_type, walletID, amount, phone)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        animateLogo()
        delayToNextPage(fund_type: fund_type)
    }
    

    
    //++++++=========Delay function @if token is true move to next page+++++++===========//
    func delayToNextPage(fund_type: String){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "amount": amount, "WalletID": walletID, "type": fund_type, "note": "", "phone": phone]
        
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
        
        postData(url: url, parameter: parameter, token: token, header: headers)
    }
    
    ///////////***********Post Data MEthod*********////////
    func postData(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        
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
                    self.performSegue(withIdentifier: "goToSuccess", sender: self)
                }
                
                else if  message == "Session is invalid" {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    ////From the alert Service
                    self.performSegue(withIdentifier: "goToFailed", sender: self)
                }
            }
            else {
               
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Network Error")
                self.present(alertVC, animated: true)
                //self.delayToNextPage()
            }
        }
    }
    
    
    

    
    
    // MARK - Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToBankTransfer" {
            //let destinationVC = segue.destination as! BankTransferViewController
            
        }
    }
    
    
    
    /////////Method that animates logo on App
    func animateLogo() {
        UIView.animate(withDuration: 1.5, delay: 0, options: [.repeat], animations: {
            self.circle1.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }) { (finished) in
            UIView.animate(withDuration: 1, animations: {
                self.circle1.transform = CGAffineTransform.identity
            })
        }
        
        UIView.animate(withDuration: 1.5, delay: 1, options: [.repeat],  animations: {
            self.circle2.transform = CGAffineTransform(scaleX: 1.7, y: 1.7)
        }) { (finished) in
            UIView.animate(withDuration: 1, animations: {
                self.circle2.transform = CGAffineTransform.identity
            })
        }
        
        UIView.animate(withDuration: 1.5, delay: 1.2, options: [.repeat],  animations: {
            self.circle3.transform = CGAffineTransform(scaleX: 1.9, y: 1.9)
        }) { (finished) in
            UIView.animate(withDuration: 1, animations: {
                self.circle3.transform = CGAffineTransform.identity
            })
        }
        
        
        UIView.animate(withDuration: 1.5, delay: 1.5, options: [.repeat],  animations: {
            self.circle4.transform = CGAffineTransform(scaleX: 2.1, y: 2.1)
        }) { (finished) in
            UIView.animate(withDuration: 1, animations: {
                self.circle4.transform = CGAffineTransform.identity
            })
        }
    }
    
}

