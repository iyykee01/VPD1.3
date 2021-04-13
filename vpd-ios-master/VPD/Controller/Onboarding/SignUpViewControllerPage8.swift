//
//  SignUpViewControllerPage8.swift
//  VPD
//
//  Created by Ikenna Udokporo on 07/05/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD

class SignUpViewControllerPage8: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    var bvn: String!
    var longitude: String!
    var latitude: String!
    var accountType: String!
    var mobile: String!
    var country: String!
    var fullname: String!
    var dob: String!
    var email: String!
    var username: String!
    var question: String!
    var answer: String!
    var password: String!
    var accountNumber:String = ""
    
    
    //For Business segue
    var business_category = ""
    var business_name = ""
    var business_reg_no = ""
    var photoID = ""
    var businessCert = ""
    var utilityBills = ""


    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var buttonUI: UIButton!
    
    let imagePicker = UIImagePickerController()
    var imageBase64String: String = ""
    
    
    var baseImage64 = ""
    
    
    var alamoFireManager : SessionManager? // this line
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        activityIndicator.isHidden = true;
        imagePicker.delegate = self
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            imageView.image = image
            
            let imageData: Data? = image.jpegData(compressionQuality: 0.4)
            let imageStr = imageData?.base64EncodedString(options: .lineLength64Characters) ?? ""
            
            imageBase64String = imageStr
            
            let pngImage = image.pngData()
            
            //let pngImage = UIImagePNGRepresentation(image)

            UserDefaults.standard.set(pngImage, forKey: "image")
            
            imagePicker.dismiss(animated: true, completion: nil)
            faceDetect(image: imageBase64String)
            
        }else {
            print("No image found")
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
        
        
        //****convert image to base 64****//
        //let photo = baseImage64
        
//        let global_Acct_Type = UserDefaults.standard.string(forKey: "account_type")!
//
//        var params = [[String: String]]()
//
//        if global_Acct_Type == "personal" {
        
            //******getting parameter from string
            let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "mobile": String(mobile), "bvn": bvn, "fullname": fullname, "email": email, "dob": dob, "longitude": longitude, "latitude": latitude, "photo": imageBase64String, "country": country, "security_question": question, "security_question_answer": answer, "accountType": accountType, "password": password, "username": username]
            
//            params.append(paramss as! [String : String])
//        }
        
//        else {
//
//            //******getting parameter from string
//            let paramss = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "mobile": String(mobile), "bvn": bvn, "fullname": fullname, "email": email, "dob": dob, "longitude": longitude, "latitude": latitude, "photo": imageBase64String, "country": country, "security_question": question, "security_question_answer": answer, "accountType": accountType, "password": password, "username": username, "business_name": business_name," business_category": business_category, "business_cac": business_reg_no, "business_certificate": businessCert, "business_utility_bill": utilityBills]
//
//            params.append(paramss as! [String : String])
//        }
//
     
        

        print("***************--------START PARAMS-------***************************************")
        print("***************-------END PARAMS--------\n******************************")
        
        let jsonEncode = JSONEncoder()
        let jsonData = try! jsonEncode.encode(params)
        let json = String(data: jsonData, encoding: .utf8)!
        
        
        ///*********converting shaDeivcepptiies to hexString*********////////
        /////*********converting shaDeivcepptiies to hexString*********////////
        let hexShaDevicePpties = utililty.convertToHexString(json)
        //print(hexShaDevicePpties)
        
        
        let parameter = ["reqData": hexShaDevicePpties]
        
        let token = UserDefaults.standard.string(forKey: "Token")!
        let headers: HTTPHeaders = ["X-Authorization": token, "AppGroup": "IOS"]
        let url = "\(utililty.url)register"
        
        if (baseImage64 != "") {
            postData(url: url, parameter: parameter, token: token, header: headers)
        }
        else {
            //******From the alert Service*************//
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "Please Take a Picture")
            self.present(alertVC, animated: true)
        }
    }
    
    //++++++=========faceDetect function @if token is true move to next page+++++++===========//
    func faceDetect(image: String){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
     
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "data": image]
        
        
        print("***************--------START PARAMS-------***************************************")
        print("***************-------END PARAMS--------\n******************************")
        
        let jsonEncode = JSONEncoder()
        let jsonData = try! jsonEncode.encode(params)
        let json = String(data: jsonData, encoding: .utf8)!
        
        
        ///*********converting shaDeivcepptiies to hexString*********////////
        /////*********converting shaDeivcepptiies to hexString*********////////
        let hexShaDevicePpties = utililty.convertToHexString(json)
        //print(hexShaDevicePpties)
        
        
        let parameter = ["reqData": hexShaDevicePpties]
        
        let token = UserDefaults.standard.string(forKey: "Token")!
        let headers: HTTPHeaders = ["X-Authorization": token, "AppGroup": "IOS"]
        let url = "\(utililty.url)face_detect"
        
        if (imageBase64String != "") {
            faceDetectApi(url: url, parameter: parameter, token: token, header: headers)
        }
        else {
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "Please Take a Picture")
            self.present(alertVC, animated: true)
        }
    }
    
    
    
    
    ///////////***********Post Data MEthod*********////////
    func postData(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        //**** Animate UI indicator ****/
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        buttonUI.isHidden = true
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 100
        configuration.timeoutIntervalForResource = 100
        alamoFireManager = Alamofire.SessionManager(configuration: configuration) // not in this line
        
        Alamofire.request(url, method: .post, parameters: parameter, headers: header).responseJSON {
            response in
            //print(response)
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
                print(decriptor)
                
                //**********Changing Data back to Json format***///
                let jsonData = decriptor.data(using: .utf8)!
                let decriptorJson: JSON = JSON(jsonData)
                
                print(decriptorJson)
                
                
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                
                
                
                if(status) {
                    //**** Animate UI indicator ****/
                    self.accountNumber = decriptorJson["response"]["account_number"].stringValue
                    
                    UserDefaults.standard.set(self.accountNumber, forKey: "AccountNumber")
                    UserDefaults.standard.synchronize()
                    self.performSegue(withIdentifier: "goToSVC9", sender: self)
                }
                else {
                    //**** Animate UI indicator ****/
                    self.stopActiveIndicator()
                    
                    //******From the alert Service*************//
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
                
            }
            else {
                self.stopActiveIndicator()
                
                //******From the alert Service*************//
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Network Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    
    ///////////***********Post Data MEthod*********////////
    func faceDetectApi(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        self.activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        self.activityIndicator.isHidden = false
        buttonUI.isHidden = true
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 100
        configuration.timeoutIntervalForResource = 100
        alamoFireManager = Alamofire.SessionManager(configuration: configuration) // not in this line
        
        Alamofire.request(url, method: .post, parameters: parameter, headers: header).responseJSON {
            response in
            //print(response)
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
                print(decriptor)
                
                //**********Changing Data back to Json format***///
                let jsonData = decriptor.data(using: .utf8)!
                let decriptorJson: JSON = JSON(jsonData)
                
                print(decriptorJson)
                
                
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                
                
                if(status) {
                    //**** Animate UI indicator ****/
                    let successService = SuccessService()
                    let alertVC = successService.popUp(alertMessage: message)
                    self.present(alertVC, animated: true)

                    self.baseImage64 = self.imageBase64String
                    self.view.isUserInteractionEnabled = true
                    self.activityIndicator.isHidden = true
                    self.buttonUI.isHidden = false
                }
                else {
                    //**** Animate UI indicator ****/
               
                    self.view.isUserInteractionEnabled = true
                    self.activityIndicator.isHidden = true
                    self.buttonUI.isHidden = false
                    //******From the alert Service*************//
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
                
            }
            else {
             
                self.view.isUserInteractionEnabled = true
                self.activityIndicator.isHidden = true
                self.buttonUI.isHidden = false
                //******From the alert Service*************//
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Network Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    //**************Prepare for Segue*********//
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSVC9" {
            let SVCE = segue.destination as! SignUpViewControllerPageEnd
            SVCE.accountNumber = accountNumber
            SVCE.username = username
            SVCE.password = password
        }
    }

    
    func stopActiveIndicator() {
        //**** Animate UI indicator ****/
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        buttonUI.isHidden = false
    }
   

    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func takePhotoPressed(_ sender: Any) {
        imagePicker.sourceType = .camera
        imagePicker.cameraDevice = .front
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func nextButtonPressesd(_ sender: Any) {
        
        if baseImage64 == "" {
            //******From the alert Service*************//
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "photo is empty or invalid")
            self.present(alertVC, animated: true)
        }
        else {
            delayToNextPage()
        }
        
    }

    
}
