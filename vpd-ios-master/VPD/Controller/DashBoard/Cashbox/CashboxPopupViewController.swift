//
//  CashboxPopupViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 12/12/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class CashboxPopupViewController: UIViewController {
    
    var to_segue = ""
    
    var wallet_uid = ""
    var message = ""
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var proceed_button: DesignableButton!
    @IBOutlet weak var notNow_button: DesignableButton!
    

    var delegate: seguePerform?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
              let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "SessionID": session, "CustomerID": customer_id, "wallet": wallet_uid, "operation": "release"]
              
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
              
           
              
              let url = "\(utililty.url)cashbox"
              
              postForValidate(url: url, parameter: parameter, token: token, header: headers)
          }

          
          // MARK: - NETWORK CALL- Post TO LIST OF BANKs
          func postForValidate(url: String, parameter: [String: String], token: String, header: [String: String]) {
              
            self.activityIndicator.startAnimating()
            self.proceed_button.isHidden = true
            self.notNow_button.isHidden = true
            
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
                        self.message = message
                        self.activityIndicator.stopAnimating()
                        self.proceed_button.isHidden = false
                        self.notNow_button.isHidden = false
                        
                        self.delegate?.goNext(next: message)
                        self.dismiss(animated: true, completion: nil)
                    }
                    else if (message == "Session has expired") {
                        self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                    }
                        
                    else {
                        
                        self.proceed_button.isHidden = false
                        self.notNow_button.isHidden = false
                        self.activityIndicator.stopAnimating()
                        let alertService = AlertService()
                        let alertVC =  alertService.alert(alertMessage: message)
                        self.present(alertVC, animated: true)
                    }
                  }
                  else {
                    
                      self.proceed_button.isHidden = false
                      self.notNow_button.isHidden = false
                      self.activityIndicator.stopAnimating()
                      let alertService = AlertService()
                      let alertVC =  alertService.alert(alertMessage: "Network Error")
                      self.present(alertVC, animated: true)
                     
                  }
             
              }
          }
    

    @IBAction func proceedButtonPressed(_ sender: Any) {
        validateAPI()
    }
    
    
    
    @IBAction func notNowButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
