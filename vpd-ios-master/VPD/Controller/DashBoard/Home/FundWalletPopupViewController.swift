//
//  FundWalletPopupViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 09/07/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class FundWalletPopupViewController: UIViewController {
    
    var delegate: seguePerform?

    var saved_card = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
   
        
        
        //******Remember to change for testing so as not to crash work*******
    }
    
    @IBAction func cardDebit(_ sender: Any) {

        if saved_card != "1" {
            delegate?.goNext(next: "goStraightToCard")
            dismiss(animated: true, completion: nil)
        }
        else {
            delegate?.goNext(next: "goToSavedCards")
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func bankTransfer(_ sender: Any) {
        
        delegate?.goNext(next: "goToBackTransfer")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func ussdPressed(_ sender: Any) {
      
        delegate?.goNext(next: "goToSelectBank")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
