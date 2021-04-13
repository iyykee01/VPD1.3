//
//  LogoutAlertViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 20/02/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit

class LogoutAlertViewController: UIViewController {
    

    @IBOutlet weak var yesButton: DesignableButton!
    
    
    var buttonAction: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func yesButtonPressed(_ sender: Any) {
        buttonAction?()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func noButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
