//
//  ChooseTransferTypeViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 02/09/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class ChooseTransferTypeViewController: UIViewController {
    
    var from_segue = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        print("transfer type")
    }

    @IBAction func buttonsPressed(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            from_segue = "withdraw"
            performSegue(withIdentifier: "goToPayment", sender: self)
            break
            
        default:
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier  == "goToPayment" {
            let destination = segue.destination as! PayAContactViewController
            
            destination.from_segue = from_segue
        }
    }
}
