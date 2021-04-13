//
//  ViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 06/04/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CommonCrypto

class InitialViewController: UIViewController{
    
    
    @IBOutlet weak var circle4: UIImageView!
    @IBOutlet weak var circle1: UIImageView!
    @IBOutlet weak var circle2: UIImageView!
    @IBOutlet weak var circle3: UIImageView!
    
    
    override func viewDidLoad() {
        
        // Do any additional setup after loading the view.
        animateLogo()

        //Remove and delete function later/////////
       //removeUserDefault()
    }
    
    
    
    //This method is to clear UserDefaults
    func removeUserDefault() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
    }
 
    
    ///Remove nav Bar for navigation
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        verifyReturningUser()
        goToFace()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    func goToFace() {
        let username = UserDefaults.standard.string(forKey: "userName")
        //let face_or_fingerPrint = UserDefaults.standard.string(forKey: "authKey")
        
        if username != nil {
            performSegue(withIdentifier: "goTofaceOrFingerprint", sender: self)
        }
    }
    
    
    func verifyReturningUser() {
        let session = UserDefaults.standard.string(forKey: "CustomerID")
        
   
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

        let brand = UIDevice.current.name
        let device = UIDevice.current.model
        let devices = utililty.getPhoneId()
        
        
        
        let params = ["AppID": devices.sha512, "device": device, "brand": brand];
        print(devices.sha512, "from initial login...." )
    
        
        let jsonEncode = JSONEncoder()
        let jsonData = try! jsonEncode.encode(params)
        let json = String(data: jsonData, encoding: .utf8)!
        
        
        ///*********converting shaDeivcepptiies to hexString*********////////
        /////*********converting shaDeivcepptiies to hexString*********////////
        let hexShaDevicePpties = utililty.convertToHexString(json)
        print(hexShaDevicePpties)

        let parameter =  ["reqData": hexShaDevicePpties]
        
        print(parameter)
        
        let headers: HTTPHeaders = ["AppGroup": "ios"]
        let url = "\(utililty.url)connect"
        
        postData(url: url, parameter: parameter, headers: headers)
    }

    func postData(url: String, parameter: [String: String], headers: HTTPHeaders) {
        
        Alamofire.request(url, method: .post, parameters: parameter, headers: headers).responseJSON {
            response in
            if response.result.isSuccess {
                debugPrint(response)
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
    
    
    func animateLogo() {
        UIView.animate(withDuration: 1.5, delay: 0, options: [.repeat], animations: {
            self.circle1.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        })
        UIView.animate(withDuration: 1.5, delay: 1.5, options: [.repeat],  animations: {
            self.circle2.transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
        })
        
        UIView.animate(withDuration: 1.5, delay: 2, options: [.repeat],  animations: {
            self.circle3.transform = CGAffineTransform(scaleX: 1.45, y: 1.45)
        })
        
        UIView.animate(withDuration: 1.5, delay: 2.5, options: [.repeat],  animations: {
            self.circle4.transform = CGAffineTransform(scaleX: 1.55, y: 1.55)
        })
        
    }
}










