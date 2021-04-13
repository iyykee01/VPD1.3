//
//  AddVpdWalletViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 17/06/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class AddVpdWalletViewController: UIViewController {
    
    @IBOutlet weak var nigerianView: UIView!
    @IBOutlet weak var BritishView: UIView!
    @IBOutlet weak var UsdView: UIView!
    @IBOutlet weak var buttonUi: UIButton!
    
    
    ///Callback that triggers the resendcode button
    var addWallets: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        addCornerRaduis()
    }
    
    
    
    @IBAction func cancelPopup(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    
    func addCornerRaduis() {
        
        nigerianView.layer.masksToBounds = true
        nigerianView.layer.shadowColor = UIColor.lightGray.cgColor
        nigerianView.layer.shadowOffset = .zero
        nigerianView.layer.shadowOpacity = 10
        nigerianView.layer.shadowRadius = 5.0
        nigerianView.layer.masksToBounds = false
        
        BritishView.layer.masksToBounds = true
        BritishView.layer.shadowColor = UIColor.lightGray.cgColor
        BritishView.layer.shadowOffset = .zero
        BritishView.layer.shadowOpacity = 10
        BritishView.layer.shadowRadius = 5
        BritishView.layer.masksToBounds = false
        
        
        UsdView.layer.masksToBounds = true
        UsdView.layer.shadowColor = UIColor.lightGray.cgColor
        UsdView.layer.shadowOffset = .zero
        UsdView.layer.shadowOpacity = 10
        UsdView.layer.shadowRadius = 5
        UsdView.layer.masksToBounds = false
        
        buttonUi.layer.cornerRadius = 10.0
        buttonUi.layer.masksToBounds = true
        buttonUi.layer.shadowColor = UIColor.lightGray.cgColor
        buttonUi.layer.shadowOffset = .zero
        buttonUi.layer.shadowOpacity = 10
        buttonUi.layer.shadowRadius = 5
        buttonUi.layer.masksToBounds = false
    }


}
