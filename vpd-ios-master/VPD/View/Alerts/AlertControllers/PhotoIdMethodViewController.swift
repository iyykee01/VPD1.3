//
//  PhotoIdMethodViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 17/06/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class PhotoIdMethodViewController: UIViewController {

    @IBOutlet weak var driverLicense: UIButton!            
    @IBOutlet weak var passport: UIButton!
    @IBOutlet weak var cancel: UIButton!
    
    
    ///Callback that triggers the photoId button
    var photoIdMethod: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addBorderLine()
    }
    
    @IBAction func driverLicensePressed(_ sender: Any) {
        photoIdMethod?()
    }
    @IBAction func passportPressed(_ sender: Any) {
        photoIdMethod?()
    }
    
    
    @IBAction func cancelPopup(_ sender: Any) {
        dismiss(animated: true)
    }

    func addBorderLine() {
        
        driverLicense.layer.masksToBounds = true;
        driverLicense.layer.borderWidth = 2.0
        driverLicense.layer.borderColor = UIColor.lightGray.cgColor
        driverLicense.layer.masksToBounds = false;
        
        passport.layer.masksToBounds = true;
        passport.layer.borderWidth = 2.0
        passport.layer.borderColor = UIColor.lightGray.cgColor
        passport.layer.masksToBounds = false;
        
        cancel.layer.masksToBounds = true;
        cancel.layer.borderWidth = 2.0
        cancel.layer.borderColor = UIColor.lightGray.cgColor
        cancel.layer.masksToBounds = false;
    }

}
