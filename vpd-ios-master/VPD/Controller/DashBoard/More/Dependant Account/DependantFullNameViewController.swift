//
//  DependantFullNameViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 26/08/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class DependantFullNameViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var middleNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    
    //************   **********///
    var alertService = AlertService()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        firstnameTextField.delegate = self
        middleNameTextField.delegate = self
        lastNameTextField.delegate = self
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    

    @IBAction func nextButtonPressed(_ sender: Any) {
        
        if (firstnameTextField.text == "") || (lastNameTextField.text == "")  {
            
            let alertVC =  self.alertService.alert(alertMessage: "Please make sure all field are filled")
            self.present(alertVC, animated: true)
        }
        else {
            performSegue(withIdentifier: "goToDependantDOB", sender: self)
        }
        
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDependantDOB" {
            let destinationVC = segue.destination as! DependantDOBViewController
            destinationVC.firstname = firstnameTextField.text!
            destinationVC.middlename = middleNameTextField.text!
            destinationVC.lastname = lastNameTextField.text!
        }
    }

}
