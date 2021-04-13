//
//  ProvideBusinessInformationViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 17/09/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class ProvideBusinessInformationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var businessNameTextField: UITextField!
    @IBOutlet weak var businessCategoryTextField: DesignableUITextField!
    @IBOutlet weak var businessRegNo: UITextField!
    @IBOutlet var viewWrapper: UIView!
    
    
    
    var accountType = ""
    var bvn = ""
    var longitude = ""
    var latitude = ""
    var mobile = ""
    var country = ""
    var fullname = ""
    var dob = ""
    var email = ""
    var business_name = ""
    var business_category = "ATM"
    var business_reg_no = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        businessCategoryTextField.delegate = self
        businessNameTextField.delegate = self
        businessRegNo.delegate = self
        
        creatPicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissPickerView)))
    }
    
    var viewJumpHeight = 10
    @objc func dismissPickerView(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
        viewWrapper.frame.origin.y = CGFloat(viewJumpHeight)
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            NsInformation()
        }
    }
    

    @IBAction func nextButtonPressed(_ sender: Any) {
        
        viewWrapper.frame.origin.y = CGFloat(viewJumpHeight + 10)
        
        if businessRegNo.text != "" && businessNameTextField.text != "" && businessCategoryTextField.text != "" {
            performSegue(withIdentifier: "goToVerifyYourAccount", sender: self)
        }
        else {
            print("fill in the text field")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let VBAVC = segue.destination as! VerifyBusinessAccountViewController
        
        VBAVC.accountType = accountType
        VBAVC.business_category = business_category
        VBAVC.business_name = businessNameTextField.text!
        VBAVC.business_reg_no = businessRegNo.text!
        VBAVC.bvn = bvn
        VBAVC.longitude = longitude
        VBAVC.latitude = latitude
        VBAVC.mobile = mobile
        VBAVC.country = country
        VBAVC.fullname = fullname
        VBAVC.dob = dob
        VBAVC.email = email
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        businessCategoryTextField.endEditing(true)
        businessNameTextField.endEditing(true)
        businessRegNo.endEditing(true)
        
        
        viewWrapper.frame.origin.y = CGFloat(viewJumpHeight + 10)
        
        return false
    }
    
    ///Move button up
    @objc func keyboardWillChange(notification: Notification){
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification{
            
            viewWrapper.frame.origin.y = CGFloat(-viewJumpHeight)
        }
    }
    
    //Stop listening for keyboard hide/show events//////
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    
    func NsInformation(){
        //Listen for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name:
            UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
}

extension ProvideBusinessInformationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return list_of_business.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return list_of_business[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        businessCategoryTextField.text = list_of_business[row]
        business_category = businessCategoryTextField.text!
        
        print(business_category)
    }
    
    func creatPicker() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        
        businessCategoryTextField.inputView = pickerView
    }
}
