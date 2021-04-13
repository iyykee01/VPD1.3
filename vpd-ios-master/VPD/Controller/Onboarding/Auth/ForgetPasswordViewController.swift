//
//  ForgetPasswordViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 09/09/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class ForgetPasswordViewController: UIViewController, UITextFieldDelegate {
    

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var viewWrapper: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        usernameTextField.setLeftPaddingPoints(15)
        passwordTextField.setLeftPaddingPoints(15)
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        anotherMethod()
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        view.endEditing(true)
        if usernameTextField.text == "" || passwordTextField.text == "" {
            
        }
        else {
            
            //call  api here
        }
    }
    
    
    /*********Make view move up when keyboard shows**********/
    let viewJumpHeight = 10
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        viewWrapper.frame.origin.y = CGFloat(viewJumpHeight * 2)
        return false
    }
    
    // Call activeTextField whenever you need to
    func anotherMethod() {
        // self.activeTextField.text is an optional, we safely unwrap it here
        if let activeTextFieldText = self.passwordTextField.text {
            print("Active text field's text: \(activeTextFieldText)")
            NsInformation()
            return;
        }
        
        
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
