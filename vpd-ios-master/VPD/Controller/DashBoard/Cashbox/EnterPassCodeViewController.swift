//
//  EnterPassCodeViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 03/07/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class EnterPassCodeViewController: UIViewController {
    
    @IBOutlet weak var inputOneView: UIView!
    @IBOutlet weak var inputTwoView: UIView!
    @IBOutlet weak var inputThreeView: UIView!
    @IBOutlet weak var inputFourView: UIView!
    
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var textField3: UITextField!
    @IBOutlet weak var textField4: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        textField1.delegate = self
        textField2.delegate = self
        textField3.delegate = self
        textField4.delegate = self

        // Do any additional setup after loading the view.
        textField1.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        textField2.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        textField3.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        textField4.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        
    }
    
    
    @objc func textChanged(sender: UITextField) {
        if (sender.text?.count)! > 0 {
            let nextField = self.view.viewWithTag(sender.tag + 1) as? UITextField
            nextField?.becomeFirstResponder()
        }
        else {
            sender.resignFirstResponder()
        }
    }
    

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension EnterPassCodeViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1 {
           inputOneView.isHidden = !false
        }
        if textField.tag == 2 {
            inputTwoView.isHidden = !false
        }
        if textField.tag == 3 {
            inputThreeView.isHidden = !false
        }
        if textField.tag == 4 {
            inputFourView.isHidden = !false
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField1.text!.count < 1 {
            inputOneView.isHidden = false
        }
        if textField2.text!.count < 1 {
            inputTwoView.isHidden = false
        }
        if textField3.text!.count < 1 {
            inputThreeView.isHidden = false
        }
        if textField4.text!.count < 1 {
            inputFourView.isHidden = false
        }
    }
}
