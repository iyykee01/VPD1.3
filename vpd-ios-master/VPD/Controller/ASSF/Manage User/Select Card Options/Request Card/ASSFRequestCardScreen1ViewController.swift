//
//  ASSFRequestCardScreen1ViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 26/06/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit

class ASSFRequestCardScreen1ViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var userAccountNumberTextField: DesignableUITextField!
    @IBOutlet weak var userNameTextField: DesignableUITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        userAccountNumberTextField.delegate = self;
        userNameTextField.delegate = self
        
        userAccountNumberTextField.setLeftPaddingPoints(14)
        userNameTextField.setLeftPaddingPoints(14)
        
        //userAccountNumberTextField.inputAccessoryView = toolBar

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        if userAccountNumberTextField.text == "" || userNameTextField.text == "" {
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "Please fill all fields")
            self.present(alertVC, animated: true)
            return
        }
        else {
            performSegue(withIdentifier: "goToOTP", sender: self)
        }
        
    }
    
}
