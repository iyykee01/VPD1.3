//
//  BecomeAnAgentViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 03/08/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit
import SwiftyJSON

class BecomeAnAgentViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var AssfNumber: DesignableUITextField!
    @IBOutlet weak var phoneNumber: DesignableUITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var buttonUI: DesignableButton!
    
    
    var assf_number = ""
    var phone_number = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        AssfNumber.delegate = self
        phoneNumber.delegate = self
        AssfNumber.setLeftPaddingPoints(14)
        //phoneNumber.setLeftPaddingPoints(14)
        
        phoneNumber.addTarget(self, action: #selector(removeZero), for: UIControl.Event.editingChanged)
        
        configToolBar()
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
        
        AssfNumber.inputAccessoryView = toolBar;
        phoneNumber.inputAccessoryView = toolBar;
    }
    
    //MARK: functionality for done
    @objc func donePicker() {

        phone_number = "+234\(phoneNumber.text!)"
        assf_number = AssfNumber.text!
        
        view.endEditing(true)
        
    }
    
    //**********Remove User Zero **********//
    @objc func removeZero() {
        if (self.phoneNumber.text?.hasPrefix("0"))! {
            self.phoneNumber.text?.remove(at:(self.phoneNumber.text?.startIndex)!)
        }
    }
    
    //MARK: KeyBoard handler
    @objc func keyboardwillChange(notification: Notification) {
        
        guard   let userInfo = notification.userInfo as? [String: NSObject],
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect  else { return }
        
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification  {
            view.frame.origin.y = -keyboardFrame.height / 3
        }
        else {
            view.frame.origin.y = 0
        }
        
    }
    
    //MARK: Deinitializing Notification from keyboard
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil);
    }
       
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
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
          
          
          //******getting parameter from string
          let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "phone": phone_number, "agentcode": assf_number]
          
          
          print(params)
          
          
          utililty.delayToNextPage(params: params, path: "register_agent") { result in
              switch result {
              case .failure(let error):
                  self.activityIndicator.stopAnimating()
                  
                  print(error)
                  print("Please check that you have internet connection")
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
                    self.performSegue(withIdentifier: "goToOTP", sender: self)
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
    
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        
        if AssfNumber.text == "" || phoneNumber.text == "" {
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "Please fill all fields")
            self.present(alertVC, animated: true)
            return
        }
        
        if AssfNumber.text!.count < 10 {
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "Invalid ASSF number")
            self.present(alertVC, animated: true)
            return
        }
            
        else {
            networkCall()
        }
    }
    
    //MARK: Back Button Handler
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToOTP" {
             let des = segue.destination as! BecomeAnAgentOTPViewController
            
            des.assf_number = assf_number
            des.phone_number = phone_number
            
            AssfNumber.text = ""
            phoneNumber.text = ""
        }
    }
    
}
