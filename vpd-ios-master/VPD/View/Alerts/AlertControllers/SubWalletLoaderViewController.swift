//
//  SubWalletLoaderViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 19/08/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SubWalletLoaderViewController: UIViewController {
    
    
    @IBOutlet weak var circle4: UIImageView!
    @IBOutlet weak var circle1: UIImageView!
    @IBOutlet weak var circle2: UIImageView!
    @IBOutlet weak var circle3: UIImageView!
    
    
    
    var accountNumber = ""
    var currencySelected = ""
    var wallet_type = ""
    var message = ""
    
    
    ////From the alert Service
    let alertService = AlertService()
    /******Import  and initialize Util Class*****////
    var utililty = UtilClass()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(currencySelected, wallet_type)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        animateLogo()
        
    }

    
    
    
    
    
    // MARK - Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDecider" {
            let destinationVC = segue.destination as! subAccountLastPageViewController
                destinationVC.message = message
        }
    }

    
    
    /////////Method that animates logo on App
    func animateLogo() {
        UIView.animate(withDuration: 1.5, delay: 0, options: [.repeat], animations: {
            self.circle1.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }) { (finished) in
            UIView.animate(withDuration: 1, animations: {
                self.circle1.transform = CGAffineTransform.identity
            })
        }
        
        UIView.animate(withDuration: 1.5, delay: 1, options: [.repeat],  animations: {
            self.circle2.transform = CGAffineTransform(scaleX: 1.7, y: 1.7)
        }) { (finished) in
            UIView.animate(withDuration: 1, animations: {
                self.circle2.transform = CGAffineTransform.identity
            })
        }
        
        UIView.animate(withDuration: 1.5, delay: 1.2, options: [.repeat],  animations: {
            self.circle3.transform = CGAffineTransform(scaleX: 1.9, y: 1.9)
        }) { (finished) in
            UIView.animate(withDuration: 1, animations: {
                self.circle3.transform = CGAffineTransform.identity
            })
        }
        
        
        UIView.animate(withDuration: 1.5, delay: 1.5, options: [.repeat],  animations: {
            self.circle4.transform = CGAffineTransform(scaleX: 2.1, y: 2.1)
        }) { (finished) in
            UIView.animate(withDuration: 1, animations: {
                self.circle4.transform = CGAffineTransform.identity
            })
        }
    }


}
