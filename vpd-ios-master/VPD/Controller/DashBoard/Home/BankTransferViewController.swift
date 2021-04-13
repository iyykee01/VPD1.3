//
//  BankTransferViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 15/07/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit


class BankTransferViewController: UIViewController {
    
    @IBOutlet weak var accountHolderTextField: UITextField!
    @IBOutlet weak var bankNameTextField: UITextField!
    @IBOutlet weak var accountNumberTextField: UITextField!
    @IBOutlet weak var referenceNumberTextField: UITextField!
    
    
    var account_no = ""
    var holder = ""
    var reference = ""
    var bank = ""


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        
        accountHolderTextField.setLeftPaddingPoints(15)
        accountNumberTextField.setLeftPaddingPoints(15)
        bankNameTextField.setLeftPaddingPoints(15)
        referenceNumberTextField.setLeftPaddingPoints(15)
        
        
        
        
        accountHolderTextField.text = holder
        accountNumberTextField.text = account_no
        bankNameTextField.text = bank
        referenceNumberTextField.text = reference
        
        
        
        accountNumberTextField.inputView = UIView()
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        navigationController?.popToViewController(ofClass: TabBarViewController.self)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

