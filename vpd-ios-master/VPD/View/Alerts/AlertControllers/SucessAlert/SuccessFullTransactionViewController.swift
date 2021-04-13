//
//  SuccessFullTransactionViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 14/01/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit

class SuccessFullTransactionViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var doneButton: UIButton!
       
       var message = ""
       var buttonAction: (() -> Void)?

       override func viewDidLoad() {
           super.viewDidLoad()

           // Do any additional setup after loading the view.
           label.text = message
       }

       @IBAction func doneButtonPressed(_ sender: Any) {
           buttonAction?()
           dismiss(animated: true, completion: nil)

       }
       
   

}
