//
//  PinManagementViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 30/03/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit
import SwiftyJSON

class PinManagementViewController: UIViewController {

    @IBOutlet weak var arrowButton: UIImageView!
    @IBOutlet weak var changePin: UILabel!
    @IBOutlet weak var changePinButton: UIButton!
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var createTransactionPin: UIButton!
    @IBOutlet weak var createPin: UILabel!
    @IBOutlet weak var createPinImage: UIImageView!
    
    
    var pin_created = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if UserDefaults.standard.string(forKey: "userPIN") != nil || LoginResponse["response"]["authentication"]["pin_setup_complete"].boolValue {
           //statements using 'constantName'
            changePin.textColor = .black
            changePinButton.isUserInteractionEnabled = true
            arrowImage.image = UIImage(named: "arrow-right")
            
            createPin.textColor = .lightGray
            createTransactionPin.isUserInteractionEnabled = false
            createPinImage.image = UIImage(named: "arrow-right1")
            
            
        }
        else {
            changePin.textColor = .lightGray
            changePinButton.isUserInteractionEnabled = false
            arrowImage.image = UIImage(named: "arrow-right1")
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true);
    }
    
    @IBAction func createPinButtonPressed(_ sender: Any) {
        
        performSegue(withIdentifier: "goToCreatePin", sender: self)
    }
    
    @IBAction func changePinButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToChangePin", sender: self)
    }
    
}
