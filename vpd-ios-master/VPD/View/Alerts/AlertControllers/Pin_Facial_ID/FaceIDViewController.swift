//
//  FaceIDViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 28/05/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit
import LocalAuthentication

var isUserFace = false
var global_key = ""

class FaceIDViewController: UIViewController {
    
    @IBOutlet weak var button: DesignableButton!
    @IBOutlet weak var faceLabel: UILabel!
    
    var buttonAction: (() -> Void)?
    var faceButtonPressed: (() -> Void)?


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
       if LocalAuth.shared.hasTouchId()  {
            faceLabel.text = "Login with TouchID"
            button.setImage(UIImage(named: "fingerprint-24px"), for: .normal);
        }
            
        else if LocalAuth.shared.hasFaceId() {
            faceLabel.text = "Login with FaceID"
            button.setImage(UIImage(named: "face-id_white"), for: .normal);
        }
    }
    
    
    //Validate Facial Biometrics
    //This method will validate face id and change button logo to all good
    func validateFace() {
        let context: LAContext = LAContext()
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil){
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Login to Voguepay Digital") { (success, nil)
                in
                
                if success {
                    isUserFace = true
                    global_key = "jskjskjksjksjksjsjskjs" // Key from userDefaults
                    DispatchQueue.main.async {
                        self.button.setImage(UIImage(named: "circle_check_green"), for: .normal);
                        self.button.isUserInteractionEnabled = false;
                    }
                }
                else {
                    self.button.setImage(UIImage(named: "x-button"), for: .normal);
                }
            }
        }
    };
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        //buttonAction?();
        dismiss(animated: true, completion: nil);
    }

    @IBAction func faceIDButtonPressed(_ sender: Any) {
        // This will show if FaceID from API == True
        validateFace();
    }
}

      
