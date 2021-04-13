//
//  Success2LaunchViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 22/10/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class Success2LaunchViewController: UIViewController {

    @IBOutlet weak var success_message: UILabel!
    var message_segue = ""
    
    var delegate: seguePerform?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        success_message.text = message_segue
        // Do any additional setup after loading the view.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { // Change `2.0` to the desired number of seconds.
            // Code you want to be delayed
            
            self.delegate?.goNext(next: "")
            self.dismiss(animated: true, completion: nil)
        }
    }
    

}
