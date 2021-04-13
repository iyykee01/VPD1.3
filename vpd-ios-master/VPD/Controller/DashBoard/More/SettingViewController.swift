//
//  SettingViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 22/08/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {
    
    var delegate: seguePerform?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func buttonsPressed(_ sender: Any) {
        delegate?.goNext(next: "goToSecurity")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changePasscodePressedc(_ sender: Any) {
        delegate?.goNext(next: "goToChangePassCode")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func aboutUsPressed(_ sender: Any) {
        delegate?.goNext(next: "goToAboutus")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func termsUsPressed(_ sender: Any) {
        delegate?.goNext(next: "1")
        self.dismiss(animated: true, completion: nil)
        
    }

    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
   
}
