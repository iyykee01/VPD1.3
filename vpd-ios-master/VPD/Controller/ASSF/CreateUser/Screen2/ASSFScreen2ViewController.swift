//
//  ASSFScreen2ViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 26/06/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit

class ASSFScreen2ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("i go here")
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true);
    }
    
}
