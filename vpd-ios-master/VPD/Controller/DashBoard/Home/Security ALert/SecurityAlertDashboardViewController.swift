//
//  SecurityAlertDashboardViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 20/04/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit

class SecurityAlertDashboardViewController: UIViewController {

    var delegate: passSelectedObj?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
   
    @IBAction func setUpVPDPINButtonPressed(_ sender: Any) {
        delegate?.passingData(segue: "goToSecurityAlert", type: "security" , abbr: "")
        self.dismiss(animated: true, completion: nil)

    }
    
}
