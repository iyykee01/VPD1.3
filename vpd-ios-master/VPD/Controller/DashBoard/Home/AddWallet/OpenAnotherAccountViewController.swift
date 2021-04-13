//
//  OpenAnotherAccountViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 17/06/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class OpenAnotherAccountViewController: UIViewController, CameraImageDelegate {
    
    @IBOutlet weak var photoIDButton: UIButton!
    @IBOutlet weak var utillyBillsButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var photoId: String!
    var utilityBill: String!
    
    var photoIdExpected = ""
    var currencySelected = ""
    var wallet_type = ""
    
   
    
   

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
         print(currencySelected, wallet_type)
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
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "currency": currencySelected, "wallet_type": wallet_type, "photoID": photoId , "utilityBill": utilityBill]


        //photoId

        let jsonEncode = JSONEncoder()
        let jsonData = try! jsonEncode.encode(params)
        let json = String(data: jsonData, encoding: .utf8)!


        ///*********converting shaDeivcepptiies to hexString*********////////
        /////*********converting shaDeivcepptiies to hexString*********////////
        let hexShaDevicePpties = utililty.convertToHexString(json)
        //print(hexShaDevicePpties)


        let parameter = ["reqData": hexShaDevicePpties]
        let token = UserDefaults.standard.string(forKey: "Token")!
        
        //remove interval params if post doesn't work
        let headers: HTTPHeaders = ["X-Authorization": token, "AppGroup": "IOS", "timeoutInterval": "90"]
        
        

        let url = "\(utililty.url)create_wallet"

        postData(url: url, parameter: parameter, token: token, header: headers)
    }

    ///////////***********Post Data MEthod*********////////
    func postData(url: String, parameter: [String: String], token: String, header: [String: String]) {

        confirmButton.isHidden = true
        activityIndicator.startAnimating()

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
                //print(decriptorJson)


                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue




                if(status) {
                    //********Response from server *******//
                    self.confirmButton.isHidden = false
                    self.activityIndicator.stopAnimating()
                    
                    let alertSV = SuccessAlertTransaction()
                    let alert = alertSV.alert(success_message: message) {
                        self.navigationController?.popToViewController(ofClass: TabBarViewController.self)
                        
                    }
                    self.present(alert, animated: true)
                    self.dismiss(animated: true, completion: nil)
                }
                    
                else if (message == "Session has expired") {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    ////From the alert Service
                    let alertService = AlertService()
                    self.confirmButton.isHidden = false
                    self.activityIndicator.stopAnimating()
                    let alertVC =  alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.confirmButton.isHidden = false
                self.activityIndicator.stopAnimating()
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    
    
    func imageTakenFromCamera(image: UIImage, expectedPhoto: String) {
        navigationController?.popViewController(animated: true)
        
        print("coming from openVC    \(image), \(expectedPhoto)")

        if expectedPhoto == "photo_id" {
            photoId =  makeBase64Image(imageToConvert: image)
            photoIdExpected = expectedPhoto
            photoIDButton.setImage(UIImage(named: "Icon.png"), for: UIControl.State.normal)
        }
        else {
            utilityBill = makeBase64Image(imageToConvert: image)
            photoIdExpected = expectedPhoto
            utillyBillsButton.setImage(UIImage(named: "Icon.png"), for: UIControl.State.normal)
        }
    }
    
    //Conver UIImage to Base64 String//
    func makeBase64Image(imageToConvert: UIImage) -> String {
        
        //Made changes from 0.4 to 0.2
        let imageData: Data? = imageToConvert.jpegData(compressionQuality: 0.2)
        let imageStr = imageData?.base64EncodedString(options: .lineLength64Characters) ?? ""
        
        return imageStr
    }

    
    
    @IBAction func photoIdButtonPressed(_ sender: UIButton) {
        ////From the alert Service
        self.photoIdExpected = "photo_id"
        self.performSegue(withIdentifier: "goToCamera", sender: self)
        
    }
    
    
    @IBAction func utilityBillsButtonPressed(_ sender: Any) {
        photoIdExpected = "utilityBill"
        performSegue(withIdentifier: "goToCamera", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "goToCamera" {
            let CamVC = segue.destination as! TakePhotoViewController
            
            if photoIdExpected != "" && photoIdExpected == "photo_id" {
                CamVC.expectedSnapShot = photoIdExpected
                photoIdExpected = ""
            }
            if photoIdExpected != "" && photoIdExpected == "utilityBill" {
                CamVC.expectedSnapShot = photoIdExpected
                photoIdExpected = ""
            }
            CamVC.delegate = self
        }
        
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func goBacktoDashBoard(_ sender: Any) {
        //print(photoId, utililty)
        if (photoId == nil) || (utilityBill == nil) {
            //some button should be disable and user should be prompted
            self.showToast(message: "Make sure both Photo ID and Utility Bills are present", font: UIFont(name: "Muli", size: 12)!)
        }
        else {
            //call a certain function to perform api call
            activityIndicator.startAnimating()
            delayToNextPage()
        }
        
    }
}



