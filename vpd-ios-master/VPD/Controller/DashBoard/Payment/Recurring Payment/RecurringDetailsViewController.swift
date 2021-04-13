//
//  RecurringDetailsViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 22/01/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RecurringDetailsViewController: UIViewController {
    
    @IBOutlet weak var switchOutlet: UISwitch!
    @IBOutlet weak var title_recurring: UILabel!
    @IBOutlet weak var header_for_phone_number: UILabel!
    @IBOutlet weak var header_for_network: UILabel!
    @IBOutlet weak var phone_number: UILabel!
    @IBOutlet weak var network: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var nextPayment: UILabel!
    @IBOutlet weak var deactivate_button: DesignableButton!
    
    var selected_recurring: ListRecurringModel!
    
    var switch_state = "0"
    var is_active = "0"
    var operation = "fetch"
    var recurring_id = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        amount.text = "\(selected_recurring.currency) \(selected_recurring.amount)"
        type.text = selected_recurring.frequency
        
        is_active = selected_recurring.active
        
        if is_active == "1" {
            switchOutlet.isOn = true
            deactivate_button.setTitle("Active", for: .normal)
        }
        else {
            switchOutlet.isOn = false
            deactivate_button.setTitle("Deactivated", for: .normal)
            deactivate_button.borderColor = .red
            deactivate_button.borderWidth = 0.5
            deactivate_button.setTitleColor(.red, for: .normal)
        }
        
        callListOfRecuringID()
        
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
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "operation": operation, "id": selected_recurring.id]
        
        
        
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
        
        
        let url = "\(utililty.url)recurrent_payment"
        
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
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                       self.dismiss(animated: true, completion: nil)
                    }
                    
                    if self.operation == "fetch" {
                        self.nextPayment.text = decriptorJson["response"]["next_run"].stringValue
                        
                        self.phone_number.text = decriptorJson["response"]["account"].stringValue
                        
                        self.title_recurring.text =  decriptorJson["response"]["title"].stringValue
                        
                    }
                    
                    if self.operation == "cancel" {
                        self.dismiss(animated: true, completion: nil)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            let alertSV = SuccessAlertTransaction()
                            let alert = alertSV.alert(success_message: message) {
                                self.navigationController?.popToViewController(ofClass: ListOfBeneficiaryViewController.self)
                            }
                            self.present(alert, animated: true)
                            
                        }
                        
                    }
                    
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
                    self.present(alertVC, animated: true)             }
            }
            else {
                self.dismiss(animated: true, completion: nil)
                self.view.isUserInteractionEnabled = true
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
            }
            
        }
    }

    
    @IBAction func swithchButtonActivated(_ sender: UISwitch) {
        //Toggle switch
        //Change button text color and background color
    
        if sender.isOn {
            switch_state = "1"
            deactivate_button.borderColor = UIColor(hexFromString: "#34B5CE")
            deactivate_button.borderWidth = 0.5
            deactivate_button.setTitleColor(UIColor(hexFromString: "#34B5CE"), for: .normal)
             operation =  "activate"
            deactivate_button.setTitle("Active", for: .normal)
            
            callListOfRecuringID()
            
        }
        else {
            switch_state = "0"
            deactivate_button.borderColor = .red
            deactivate_button.borderWidth = 0.5
            deactivate_button.setTitleColor(.red, for: .normal)
            operation =  "deactivate"
            deactivate_button.setTitle("Deactivated", for: .normal)
            
            callListOfRecuringID()
        }
        
        
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        recurring_id = selected_recurring.id
        performSegue(withIdentifier: "goToRecurring", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToRecurring" {
            let des = segue.destination as! RecurrenceViewController
            des.recurring_id = recurring_id
        }
    }
    
    
    @IBAction func back(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelPaymentButtonPressed(_ sender: Any) {
        operation = "cancel"
        callListOfRecuringID()

    }
    
}
