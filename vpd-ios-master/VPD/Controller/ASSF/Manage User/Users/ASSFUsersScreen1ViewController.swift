//
//  ASSFUsersScreen1ViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 26/06/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit

class ASSFUsersScreen1ViewController: UIViewController, UITextFieldDelegate {

    var params_choosen = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
      
    }
    

    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func userAccountNumberButtonPressed(_ sender: Any) {
        params_choosen = "accountNumber"
        performSegue(withIdentifier: "goToSearch", sender: self);
    }
    @IBAction func userPhoneNumberPressed(_ sender: Any) {
        params_choosen = "phone"
        performSegue(withIdentifier: "goToSearch", sender: self);
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSearch" {
            let destination = segue.destination as! ASSFsearchOptionViewController
            
            destination.params_from_segue = params_choosen
        }
        
    }
   
}
