//
//  SuccessLinkedViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 21/10/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class SuccessLinkedViewController: UIViewController {
    
    var from_segue = ""
    @IBOutlet weak var success_message: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if from_segue == "device changed" {
            success_message.text = "Device Swap."
            // Do any additional setup after loading the view.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { // Change `2.0` to the desired number of seconds.
                // Code you want to be delayed
                self.performSegue(withIdentifier: "goToLogin", sender: self)
            }
            return
        }
        
        if from_segue == "forget password" {
            success_message.text = "password change successful."
            
            // Do any additional setup after loading the view.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { // Change `2.0` to the desired number of seconds.
                // Code you want to be delayed
                self.performSegue(withIdentifier: "goToLogin", sender: self)
            }
            return
        }
        
        else {
            // Do any additional setup after loading the view.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { // Change `2.0` to the desired number of seconds.
                // Code you want to be delayed
                self.performSegue(withIdentifier: "toBackToLoader", sender: self)
            }
        }
        
        
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toBackToLoader" {
            let destination = segue.destination as! JustAMomentViewController
            
            destination.from_segue = "Completeting your upgraded. This may take a few seconds."
        }
    }

}
