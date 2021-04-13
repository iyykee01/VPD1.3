//
//  ASSFRequestCardScreen2ViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 26/06/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit

class ASSFRequestCardScreen2ViewController: UIViewController, UITextFieldDelegate {
    
    var message = ""
    
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var textField3: UITextField!
    @IBOutlet weak var textField4: UITextField!
    @IBOutlet weak var textField5: UITextField!
    @IBOutlet weak var textField6: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        textField1.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        textField2.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        textField3.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        textField4.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        textField5.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        textField6.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        
        
        textField1.delegate = self
        textField2.delegate = self
        textField3.delegate = self
        textField4.delegate = self
        textField5.delegate = self
        textField6.delegate = self
        
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.donePicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        
        textField1.inputAccessoryView = toolBar
        textField2.inputAccessoryView = toolBar
        textField3.inputAccessoryView = toolBar
        textField4.inputAccessoryView = toolBar
        textField5.inputAccessoryView = toolBar
        textField6.inputAccessoryView = toolBar
    }
    
    @objc func donePicker() {
        view.endEditing(true)
        view.frame.origin.y = 0
    }
    
    @objc func textChanged(sender: UITextField) {
        if (sender.text?.count)! > 0 {
            let nextField = self.view.viewWithTag(sender.tag + 1) as? UITextField
            nextField?.becomeFirstResponder()
        }
        if sender.text!.count <= 0 {
            let nextField = self.view.viewWithTag(sender.tag - 1) as? UITextField
            nextField?.becomeFirstResponder()
        }
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
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func authenticateButonPressed(_ sender: Any) {
        let alertSV = SuccessAlertTransaction();
        let alert = alertSV.alert(success_message: message) {
            self.navigationController?.popToViewController(ofClass: ASSFRequestCardHomwViewController.self);
        }
        self.present(alert, animated: true);
    }
}







