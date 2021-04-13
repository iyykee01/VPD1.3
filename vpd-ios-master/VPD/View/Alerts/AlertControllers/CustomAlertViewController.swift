//
//  CustomAlertViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 24/04/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class CustomAlertViewController: UIViewController {
    
    
    @IBOutlet var OverallViewContainer: UIView!
    @IBOutlet weak var alertContainer: UIView!
    @IBOutlet weak var alertLabel: UILabel!
    
    var alertMessage = String();
   

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addCornerRaduis()
        setupView()
    }
    
    ///Method to set alert usernameField and passwordField respectively
    func setupView() {
        alertLabel.text = alertMessage
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        OverallViewContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewWasTapped)))
    }
    
    @objc func viewWasTapped (sender : UITapGestureRecognizer) {
        self.OverallViewContainer.becomeFirstResponder()
        dismiss(animated: true)
    }
    
    
    func addCornerRaduis() {
        alertContainer.layer.cornerRadius = 10;
        alertContainer.layer.masksToBounds = true;
        alertContainer.layer.shadowColor = UIColor.lightGray.cgColor
        alertContainer.layer.shadowOffset = .zero
        alertContainer.layer.shadowOpacity = 1.0
        alertContainer.layer.shadowRadius = 10.0
        self.alertContainer.layer.shadowPath = UIBezierPath(rect: self.alertContainer.bounds).cgPath
        alertContainer.layer.masksToBounds = false

    }
    
    
}
