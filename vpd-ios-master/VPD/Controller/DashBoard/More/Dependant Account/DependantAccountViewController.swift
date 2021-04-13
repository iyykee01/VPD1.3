//
//  DependantAccountViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 22/08/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class DependantAccountViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func openDependantAccountPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToDependantName", sender: self)
    }

}
