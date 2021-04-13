//
//  PayBillViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 26/09/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class PayBillViewController: UIViewController, seguePerform {
    
    
    
    var toSegue = ""
    
    var tv_subscription = [TVSubscription]()
    var electricity = [ElectricityBills]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
    }
    
    
    func goNext(next: String) {
        print(next)
        performSegue(withIdentifier: next, sender: self)
    }
    
    @IBAction func buttonPressed (_ sender: UIButton) {
        
        switch sender.tag {
        case 1:
            toSegue = "entertainment"
            performSegue(withIdentifier: "goToTransferPopup", sender: self)
            break
        case 2:
            toSegue = "utility bills"
            performSegue(withIdentifier: "goToUtility", sender: self)
            break
        case 3:
            toSegue = "topup"
            performSegue(withIdentifier: "goToUtility", sender: self)
            break
        case 4:
            performSegue(withIdentifier: "goToFood", sender: self)
            break
        default:
           navigationController?.popViewController(animated: true)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToTransferPopup" {
            let destination = segue.destination as! TransferPopupViewController
            
            destination.from_segue = toSegue
            destination.delegate = self
        }
        
        if segue.identifier == "goToUtility" {
            let destination = segue.destination as! UtilityPopUpViewController
            
            destination.from_segue = toSegue
            destination.electricity = electricity
            destination.tv_subscription = tv_subscription
            destination.delegate = self
        }
        
    }
  

}
