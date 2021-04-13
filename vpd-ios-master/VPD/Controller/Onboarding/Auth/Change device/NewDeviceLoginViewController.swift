//
//  NewDeviceLoginViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 02/04/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NewDeviceLoginViewController: UIViewController {
    
    @IBOutlet weak var viewlLayer: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var securityQuestion = ""
    var sessionID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    //***********//*****************//***************************
    /***********************/
    func delayToNextPage(){
        
        //******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        
        let params = ["AppID": device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "email": "1"]
        
        
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
        
        let url = "\(utililty.url)change_device"
        postData(url: url, parameter: parameter, token: token, header: headers)
        
    }
    
    
    func postData(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        ////From the alert Service
        let alertService = AlertService()
        viewlLayer.isHidden = false
        activityIndicator.startAnimating()
        //******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        
        Alamofire.request(url, method: .post, parameters: parameter, headers: header).responseJSON {
            response in
            //print(response)
            if response.result.isSuccess {
                print("SUCCESSFUL.....")
                
                //******Getting Data******//
                let data: JSON = JSON(response.result.value!)
                
                
                //****Decode json hear****/
                let hexKey = data["reqResponse"].stringValue
                
                
                //print("\(hexKey).............from decodedKey")
                
                //********decripting Hex key**********//
                let decriptor = utililty.convertHexStringToString(text: hexKey)
                print(decriptor)
                
                //**********Changing Data back to Json format***///
                let jsonData = decriptor.data(using: .utf8)!
                
                let decriptorJson: JSON = JSON(jsonData)
                print(decriptorJson)
                
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                
                
                if(status) {
                    //**** Animate UI indicator ****/
                    self.activityIndicator.stopAnimating()
                    self.viewlLayer.isHidden = true
                    self.performSegue(withIdentifier: "goToFourDigitCode", sender: self)
                }
                else {
                    //**** Animate UI indicator ****/
                    self.activityIndicator.stopAnimating()
                    self.viewlLayer.isHidden = true
                    let alertVC =  alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
                
            }
            else {
                //**** Animate UI indicator ****/
                self.activityIndicator.stopAnimating()
                self.viewlLayer.isHidden = true
                let alertVC =  alertService.alert(alertMessage: "Connection Timed Out")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendEmailButtonPressed(_ sender: Any) {
        //Call APi
        delayToNextPage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSecurityAnswer" {
            let destination = segue.destination as! SecurityQuestionViewController
            
            destination.sessionID = sessionID
            destination.securityQuestion = securityQuestion
        }
    }
}
