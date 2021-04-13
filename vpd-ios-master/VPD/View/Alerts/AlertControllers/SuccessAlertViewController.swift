//
//  SuccessAlertViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 25/04/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class SuccessAlertViewController: UIViewController {

    @IBOutlet var OverallViewContainer: UIView!
    
    @IBOutlet weak var successPopup: UIView!
    @IBOutlet weak var alertContainer: UIView!
    @IBOutlet weak var alertLabel: UILabel!
    
    var alertMessage = String();
    
//    ///Callback that triggers the resendcode button
//    var successfulPost: (() -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    ///Method to set alert usernameField and passwordField respectively
    func setupView() {
        alertLabel.text = alertMessage
    }


    @IBAction func successButtonPressed(_ sender: Any) {
        //successfulPost?()
        dismiss(animated: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        OverallViewContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewWasTapped)))
    }
    
    @objc func viewWasTapped (sender : UITapGestureRecognizer) {
        self.OverallViewContainer.becomeFirstResponder()
        //successfulPost?()
        dismiss(animated: true)
    }
    
   
    
   

}


