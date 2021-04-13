//
//  DependantDOBViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 26/08/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class DependantDOBViewController: UIViewController {
    
    @IBOutlet var containerView: UIView!
    
    var firstname = ""
    var middlename = ""
    var lastname = ""
    
    
    //************   **********///
    var alertService = AlertService()
    
    
    private var datePicker: UIDatePicker?

    @IBOutlet weak var DOBTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        print(firstname, middlename, lastname)
        
        //***********Setting up Date Picker********************//
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        DOBTextField.inputView = datePicker
    }
    
    override func viewWillAppear(_ animated: Bool) {
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeDatePicker)))
    }
    
    
    //***********Method to handle date format and date dismiss*********//
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        DOBTextField.text = dateFormatter.string(from: datePicker.date)
    }
    
    
    //***********Method to handle date format and date dismiss*********//
    @objc func closeDatePicker() {
        DOBTextField.resignFirstResponder()
    }


    @IBAction func nextButtonPressed(_ sender: Any) {
        
        if DOBTextField.text != "" {
            performSegue(withIdentifier: "goToDependantWallet", sender: self)
        }
        else {
            let alertVC =  self.alertService.alert(alertMessage: "Please Enter Date of Birth")
            self.present(alertVC, animated: true)
        }
        
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDependantWallet" {
            let destinationVC = segue.destination as! WhatWalletCurrencyViewController
            destinationVC.firstname = firstname
            destinationVC.middlename = middlename
            destinationVC.lastname = lastname
            destinationVC.dob = DOBTextField.text!
        
        }
    }
}
