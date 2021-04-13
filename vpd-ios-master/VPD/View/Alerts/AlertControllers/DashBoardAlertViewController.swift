//
//  DashBoardAlertViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 26/08/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class DashBoardAlertViewController: UIViewController {
    
    
    @IBOutlet weak var alertLabel: UILabel!
    
    var alertMessage = String();

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //setupView()
    }
    
    var recallAPI: (() -> Void)?
    
    
    ///Method to set alert usernameField and passwordField respectively
//    func setupView() {
//        alertLabel.text = alertMessage
//    }
    
    
    @IBAction func notNowButtonPressed(_ sender: Any) {
        recallAPI?()
        dismiss(animated: true)
    }

}
