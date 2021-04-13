//
//  AboutUsViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 04/01/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit

class AboutUsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
