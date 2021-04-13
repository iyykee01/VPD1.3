//
//  InitialViewViewController2.swift
//  VPD
//
//  Created by Ikenna Udokporo on 04/09/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CommonCrypto

class InitialViewController2: UIViewController {

    @IBOutlet weak var circle4: UIImageView!
    @IBOutlet weak var circle1: UIImageView!
    @IBOutlet weak var circle2: UIImageView!
    @IBOutlet weak var circle3: UIImageView!
    
    
    
    
    
    override func viewDidLoad() {
        
        // Do any additional setup after loading the view.
        animateLogo()
        
        ////Remove and delete function later/////////
        removeUserDefault()
    }
    
    
    
    //This method is to clear UserDefaults
    func removeUserDefault() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        verifyReturningUser()
    }
    
    
    func verifyReturningUser() {
        let session = UserDefaults.standard.string(forKey: "SessionID")
        
        if session != nil {
            performSegue(withIdentifier: "goToLogin", sender: self)
        }
        else {
            delayToNextPage()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        print("Memory Warning ooh oga")
    }
    
    
    //++++++=========Delay function @if token is true move to next page+++++++===========//
    func delayToNextPage(){
        //******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let deviceId = utililty.getPhoneId().sha512
        
        /////*********converting shaDeivcepptiies to hexString*********////////
        let hexShaDevicePpties = utililty.convertToHexString(deviceId)
        
        
        
        let parameter =  ["reqData": hexShaDevicePpties]
        
        print(parameter)
        
        let headers: HTTPHeaders = ["AppGroup": "IOS"]
        let url = "\(utililty.url)connect"
        
        postData(url: url, parameter: parameter, header: headers)
    }
    
    func postData(url: String, parameter: [String: String], header: [String: String]) {
        
        
        Alamofire.request(url, method: .post, parameters: parameter).responseJSON {
            response in
            if response.result.isSuccess {
                print("SUCCESSFUL.....")
                
                //******Getting Data******//
                let data: JSON = JSON(response.result.value!)
                
                //****Decode json hear****/
                let hexKey = data["reqResponse"].stringValue
                
                //******Import  and initialize Util Class*****////
                let utililty = UtilClass()
                
                //********decripting Hex key**********//
                let decriptor = utililty.convertHexStringToString(text: hexKey)
                let jsonData = decriptor.data(using: .utf8)!
                let decriptorJson: JSON = JSON(jsonData)
                
                print(decriptorJson)
                
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                let token = decriptorJson["response"]["token"].stringValue
                
                print(token)
                
                
                UserDefaults.standard.set(token, forKey: "Token")
                UserDefaults.standard.synchronize()
                
                
                if(status){
                    self.performSegue(withIdentifier: "goToSlider", sender: self)
                }
                else{
                    let alertService = AlertService();
                    let alertVC =  alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                let alertService = AlertService();
                let alertVC =  alertService.alert(alertMessage: "Network Error")
                self.present(alertVC, animated: true)
                self.delayToNextPage()
            }
        }
    }
    
    
    
    ///Remove nav Bar for navigation
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
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
        
        UIView.animate(withDuration: 1.5, delay: 1.5, options: [.repeat],  animations: {
            self.circle2.transform = CGAffineTransform(scaleX: 1.8, y: 1.8)
        }) { (finished) in
            UIView.animate(withDuration: 1, animations: {
                self.circle2.transform = CGAffineTransform.identity
            })
        }
        
        UIView.animate(withDuration: 1.5, delay: 2, options: [.repeat],  animations: {
            self.circle3.transform = CGAffineTransform(scaleX: 2.1, y: 2.1)
        }) { (finished) in
            UIView.animate(withDuration: 1, animations: {
                self.circle3.transform = CGAffineTransform.identity
            })
        }
        
        
        UIView.animate(withDuration: 1.5, delay: 2.5, options: [.repeat],  animations: {
            self.circle4.transform = CGAffineTransform(scaleX: 2.4, y: 2.4)
        }) { (finished) in
            UIView.animate(withDuration: 1, animations: {
                self.circle4.transform = CGAffineTransform.identity
            })
        }
    }
}
