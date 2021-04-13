//
//  ResendCodePopUpViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 29/04/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class ResendCodePopUpViewController: UIViewController {
    

    @IBOutlet var overAllContainer: UIView!
    @IBOutlet weak var popupContentView: UIView!
    @IBOutlet weak var phoneNumerLabel: UILabel!
    @IBOutlet weak var resendCodeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    ///Callback that triggers the resendcode button
    var resendCodeAction: (() -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addCornerRaduis()
        animateView()
        phoneNumerLabel.text = "to \(user_phone_number)"
    }
    
    func animateView() {
        let top = CGAffineTransform(translationX: 0, y: -300)
        UIView.animate(withDuration: 2.0, delay: 1.0, options: [], animations: {
            self.overAllContainer.transform = top
        }, completion: nil)
    }
    
    
    @IBAction func ResendCodePressed(_ sender: Any) {
        resendCodeAction?()
        dismiss(animated: true)
    }
    
    @IBAction func cancelPopup(_ sender: Any) {
        dismiss(animated: true)
    }
    

    override func viewWillAppear(_ animated: Bool) {
        overAllContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewWasTapped)))
    }
    
    @objc func viewWasTapped (sender : UITapGestureRecognizer) {
        self.overAllContainer.becomeFirstResponder()
        dismiss(animated: true)
    }
    
    
    //this method adds coner raduis to buttons
    func addCornerRaduis() {
        
        cancelButton.layer.cornerRadius = 10;
        cancelButton.layer.masksToBounds = true
        cancelButton.layer.shadowColor = UIColor.lightGray.cgColor
        cancelButton.layer.shadowOffset = .zero
        cancelButton.layer.shadowOpacity = 10
        cancelButton.layer.shadowRadius = 5.0
        cancelButton.layer.masksToBounds = false
        
        resendCodeButton.layer.cornerRadius = 10;
        resendCodeButton.layer.masksToBounds = true
        resendCodeButton.layer.shadowColor = UIColor.lightGray.cgColor
        resendCodeButton.layer.shadowOffset = .zero
        resendCodeButton.layer.shadowOpacity = 10
        resendCodeButton.layer.shadowRadius = 5
        resendCodeButton.layer.masksToBounds = false
    }


}
