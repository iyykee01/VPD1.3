//
//  UpgradeAccountViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 21/10/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class UpgradeAccountViewController: UIViewController, ErrorFromLaunch {
    

    @IBOutlet weak var header1Label: UILabel!
    @IBOutlet weak var headertwoLabel: UILabel!
    @IBOutlet weak var paragraph1: UILabel!
    @IBOutlet weak var paragraph2: UILabel!
    @IBOutlet weak var errorLable: UILabel!
    
    var from_segue = ""
    
    @IBOutlet var viewwrapper: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        
        viewwrapper.addGestureRecognizer(tap)
        
        if from_segue == "goToCreateNewBankAcct" {
            paragraph1.isHidden = true
            
            header1Label.text = "Your new account will"
            headertwoLabel.text = "now be created"
            paragraph2.text = "This will just take a moment"
        }
        
        errorLable.isHidden = true
    }
   
    //MARK: Protocol from just a minute loader
    func Error(error: String) {
        ////From the alert Service
        
        errorLable.isHidden = false
        errorLable.text = error
        errorLable.startBlink()
    }
    
    

    // function which is triggered when handleTap is called
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func notNowButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! JustAMomentViewController
        
        if from_segue == "goToCreateNewBankAcct" {
            destination.from_segue = "Creating bank account for you"
        }
        else {
            destination.from_segue = "Just a moment"
        }
        destination.delegate = self
    }
}


extension UILabel {

    func startBlink() {
        UIView.animate(withDuration: 0.8,
              delay:0.0,
              options:[.allowUserInteraction, .curveEaseInOut, .autoreverse, .repeat],
              animations: { self.alpha = 0 },
              completion: nil)
    }

    func stopBlink() {
        layer.removeAllAnimations()
        alpha = 1
    }
}
