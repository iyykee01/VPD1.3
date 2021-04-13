//
//  NavigationAuthenticationController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 09/04/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class NavigationAuthenticationController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    
    
    let relativeFontConstant: CGFloat = 0.035
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addCornerRadius()
    }
    
    
    ///Remove nav Bar for navigation
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    func goBack() {
        _ = navigationController?.popViewController(animated: true)
    }
    
  //please remove this method dude.
    func addCornerRadius() {
        signUpButton.layer.cornerRadius = 15;
        signUpButton.layer.masksToBounds = true;
        
        //this method adds coner raduis to buttons
        loginButton.layer.cornerRadius = 15;
        loginButton.layer.masksToBounds = true;
        loginButton.layer.borderWidth = 2.0
        loginButton.layer.borderColor = UIColor.white.cgColor
    }
    
}
