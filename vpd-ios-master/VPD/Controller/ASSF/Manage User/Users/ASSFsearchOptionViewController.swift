//
//  ASSFsearchOptionViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 10/08/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit
import SwiftyJSON

class ASSFsearchOptionViewController: UIViewController, UITextFieldDelegate {

    var params_from_segue = ""
    var textFieldText = ""
    
    @IBOutlet weak var textfieldParams: DesignableUITextField!
    @IBOutlet weak var lebelForTextField: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var buttonUI: DesignableButton!

    @IBOutlet weak var viewNumberWrap: UIView!

    var response: JSON?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textfieldParams.setLeftPaddingPoints(14);
        print(params_from_segue, ">>>>>>>")
        
        if params_from_segue == "accountNumber" {
            lebelForTextField.text = "User Account Number"
            viewNumberWrap.isHidden = true
            
        }
        else {
            lebelForTextField.text = "User Phone Number"
            textfieldParams.addTarget(self, action: #selector(removeZero), for: UIControl.Event.editingChanged)
        }
        
        configToolBar()
    }
     
     //**********Remove User Zero **********//
     @objc func removeZero() {
         if (self.textfieldParams.text?.hasPrefix("0"))! {
             self.textfieldParams.text?.remove(at:(self.textfieldParams.text?.startIndex)!)
         }
     }
    
    //MARK: - Set up tool bar
    func configToolBar() {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.donePicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false);
        
        textfieldParams.inputAccessoryView = toolBar;
    }
    
    //MARK: functionality for done
    @objc func donePicker() {
        view.endEditing(true)
    }
    
    
    //MARK: Make network request
    func networkCall() {
        
        activityIndicator.startAnimating()
        buttonUI.isHidden = true
        
        let utililty = UtilClass()
        let device = utililty.getPhoneId()
        
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
 
        var params = [String: String]()
        
        
        if params_from_segue == "accountNumber" {
            params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "AgentID": agentIDFromReg, "accountNumber": textFieldText]
        }
            
        else {
            params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "phone": textFieldText, "AgentID": agentIDFromReg]
        }
        
         
        
        print(params)
        
        utililty.delayToNextPage(params: params, path: "agent_user") { result in
            switch result {
            case .failure(let error):
                self.activityIndicator.stopAnimating()
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Please check that you have internet connection")
                self.present(alertVC, animated: true)
                print(error)
                break
                
            case .success:
                
                let data: JSON = JSON(result.value!)
                
                //****Decode json hear****/
                let hexKey = data["reqResponse"].stringValue
                //******Import  and initialize Util Class*****////
                
                //********decripting Hex key**********//
                let decriptor = utililty.convertHexStringToString(text: hexKey)
                
                //**********Changing Data back to Json format***///
                let jsonData = decriptor.data(using: .utf8)!
                
                
                let decriptorJson: JSON = JSON(jsonData)
                print(decriptorJson)
                
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                
                if(status) {
                    self.activityIndicator.stopAnimating()
                    self.buttonUI.isHidden = false
                    //MARK: - to come back to
                    self.response = decriptorJson
                    self.performSegue(withIdentifier: "goToProfile", sender: self);
                    self.textfieldParams.text = ""
                }
                 
                else if (message == "Session has expired") {
                    self.buttonUI.isHidden = false
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                
                else {
                    self.activityIndicator.stopAnimating()
                    self.buttonUI.isHidden = false
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
                break
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true);
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        //Proceed to searchApi
        
        if textfieldParams.text == "" {
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "Please enter a phone number or an account number")
            self.present(alertVC, animated: true)
        }
        else {
            if params_from_segue == "accountNumber" {
                textFieldText = textfieldParams.text!
            }
            else {
                textFieldText = "+234\(textfieldParams.text!)"
            }
            networkCall()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let des = segue.destination as! ASSFUserProfileViewController
        des.from_segue = response
    }

}
