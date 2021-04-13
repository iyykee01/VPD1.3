//
//  ASSFUserProfileViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 10/08/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage

class ASSFUserProfileViewController: UIViewController {
    
    var from_segue: JSON?
    
    @IBOutlet weak var accountNumber: UILabel!
    @IBOutlet weak var walletBalance: UILabel!
    @IBOutlet weak var accountName: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var biometrics: UILabel!
    @IBOutlet weak var idCard: UILabel!
    @IBOutlet weak var photoImage: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        accountNumber.text = from_segue!["response"]["accountNumber"].stringValue;
        walletBalance.text = "\(from_segue!["response"]["currency"].stringValue)\(from_segue!["response"]["balance"].stringValue)";
        accountName.text = from_segue!["response"]["name"].stringValue;
        phoneNumber.text = from_segue!["response"]["phone"].stringValue;
        
        
        if from_segue?["response"]["email"].stringValue == "" {
           email.text = "Nil";
        }
        else {
            email.text = from_segue!["response"]["email"].stringValue;
        }
        biometrics.text = from_segue!["response"]["biometric_registered"].stringValue;
        
        if from_segue!["response"]["biometric_registered"].stringValue != "Unregistered" {
            biometrics.textColor = UIColor(hexFromString: "#54A9D2")
        }
        
        
        idCard.text = from_segue!["response"]["idcard_registered"].stringValue;
        photoImage!.sd_setImage(with: URL(string: from_segue!["response"]["photo"].stringValue));
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true);
    }

}
