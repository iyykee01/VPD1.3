//
//  SucessfulPinManagementViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 30/03/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit

protocol goBackToTop {
    func goBack()
}

class SucessfulPinManagementViewController: UIViewController {
    
    var delegate: goBackToTop!
    @IBOutlet weak var message: UILabel!
    var message1 = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
        
    @IBAction func doneButtonPressed(_ sender: Any) {
        delegate.goBack()
       dismiss(animated: true, completion: nil)
    }
    
}
