//
//  subAccountLastPageViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 20/08/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class subAccountLastPageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var messageLabel1: UILabel!
    @IBOutlet weak var messageLabel2: UILabel!
    @IBOutlet weak var messageLabel3: UILabel!
    @IBOutlet weak var buttonLabel: DesignableButton!
    
    
    
    var message = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        print(message)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if message != "Successful" {
            messageLabel1.isHidden = true
            messageLabel3.isHidden = true
            
            imageView.image = UIImage(named: "x-button")
            buttonLabel.titleLabel?.text = "Cancel"
        }
    }

    @IBAction func buttonPressed(_ sender: Any) {
        
        if buttonLabel.titleLabel?.text == "Done" {
            performSegue(withIdentifier: "backToDashboard", sender: self)
        }
        else {
            dismiss(animated: true, completion: nil)
        }
    }
}
