//
//  WriteAReviewViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 16/03/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class WriteAReviewViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var textOneArea: UITextView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var HeadlineTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var submit_review_button: DesignableButton!
    
    
    var restuarnat_id = ""
    var name = ""
    var headline = ""
    var text = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        nameTextField.setLeftPaddingPoints(14)
        HeadlineTextField.setLeftPaddingPoints(14)
        nameTextField.delegate = self
        HeadlineTextField.delegate = self
        textOneArea.delegate = self
        
        textOneArea.cornerRadius = 8
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .black
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.donePicker))

        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        textOneArea.inputAccessoryView = toolBar
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
         view.frame.origin.y = 0
    }
    
    @objc func keyboardwillChange(notification: Notification) {
        
        guard   let userInfo = notification.userInfo as? [String: NSObject],
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect  else { return }
        
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification  {
            view.frame.origin.y = -keyboardFrame.height
        }
        else {
            view.frame.origin.y = 0
        }
        
    }
    
    @objc func donePicker(datePicker: UIDatePicker) {
        view.endEditing(true)
        view.frame.origin.y = 0
    }

    //    rating5
 
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true);
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    
    //MARK: - Write a review API HERE************************
    //++++++=========Delay function @if token is true move to next page+++++++===========//
    func apiCallToReview(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "SessionID": session, "CustomerID": customer_id, "operation": "writereview", "rid": restuarnat_id, "name": name, "headline": headline, "message": text]
        
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
        
        
        let url = "\(utililty.url)food"
        
        postToReview(url: url, parameter: parameter, token: token, header: headers)
    }
    
    
    // MARK: - NETWORK CALL- Post TO LIST OF BANKs
    func postToReview(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        self.activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        submit_review_button.isHidden = true
        
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
                
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                
                
                if(status) {
                    
                    self.submit_review_button.isHidden = false
                    self.view.isUserInteractionEnabled = true
                    self.activityIndicator.stopAnimating()
                    
                    let successService = SuccessService()
                    let alertVC = successService.popUp(alertMessage: message)
                    self.present(alertVC, animated: true)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.dismiss(animated: true, completion: nil)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.navigationController?.popToViewController(ofClass: RestaurantDetailsViewController.self)
                        }
                    }
                    
                }
                    
                else if (message == "Session has expired") {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.submit_review_button.isHidden = false
                    self.view.isUserInteractionEnabled = true
                    self.activityIndicator.stopAnimating()
                    let alertService = AlertService()
                    let alertVC =  alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.submit_review_button.isHidden = false
                self.view.isUserInteractionEnabled = true
                self.activityIndicator.stopAnimating()
                let alertService = AlertService()
                let alertVC =  alertService.alert(alertMessage: "Network Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitReviewButtonPressed(_ sender: Any) {
        //Will call Api here
        
        if textOneArea.text.isEmpty || nameTextField.text!.isEmpty || HeadlineTextField.text!.isEmpty {
            //ALert Error here
            let alertService = AlertService()
            let alertVC =  alertService.alert(alertMessage: "Please make sure all fields are filled")
            self.present(alertVC, animated: true)
        }
        else {
            name = nameTextField.text!
            text = textOneArea.text
            headline = HeadlineTextField.text!
            apiCallToReview()
            nameTextField.text! = ""
            textOneArea.text = ""
            HeadlineTextField.text! = ""
        }
    }
}
