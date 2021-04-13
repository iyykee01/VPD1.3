//
//  UpgradeWalletViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 03/07/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class UpgradeWalletViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    var upgradeWalletAction: (() -> Void)?
    

    @IBAction func proceedButtonPressed(_ sender: Any) {
        upgradeWalletAction?()
        dismiss(animated: true)
    }
    
    @IBAction func notNowButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    

}
