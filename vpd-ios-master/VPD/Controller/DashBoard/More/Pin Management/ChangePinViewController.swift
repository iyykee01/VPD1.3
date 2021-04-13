//
//  ChangePinViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 30/03/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit

class ChangePinViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func changePinButtonPressed(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "createPin") as? CreatePinViewController
        vc?.head_text = "Change PIN"
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
