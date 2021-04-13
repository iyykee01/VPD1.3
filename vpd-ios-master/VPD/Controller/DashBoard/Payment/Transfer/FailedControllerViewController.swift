//
//  FailedControllerViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 16/09/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class FailedControllerViewController: UIViewController {
    
    var from_segue = ""
    
    @IBOutlet weak var headerLabel1: UILabel!
    @IBOutlet weak var headerLabel2: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        headerLabel1.text = from_segue 
        
    }
    


    @IBAction func Try_againButtonpressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        
        print("Cancel Pressed")
    }
    
    
    
    @IBAction func DoneButtonPressed(_ sender: Any) {
        print("Donte press me ooh")
    }
}
