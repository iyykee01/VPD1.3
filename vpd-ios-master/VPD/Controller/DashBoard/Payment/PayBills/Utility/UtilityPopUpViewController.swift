//
//  UtilityPopUpViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 02/10/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

protocol seguePerform {
    func goNext(next: String)
}

class UtilityPopUpViewController: UIViewController {
    

    var delegate: seguePerform?
    
    @IBOutlet weak var electricityBill: DesignableButton!
    @IBOutlet weak var tvSubscriptionBill: DesignableButton!
    @IBOutlet weak var lableOnPopup: UILabel!
    @IBOutlet weak var popConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonTopConstraint: NSLayoutConstraint!
    
    
    var from_segue = ""
    var to_segue = ""
    
    
    var tv_subscription = [TVSubscription]()
    var electricity = [ElectricityBills]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        print(from_segue)
        
        if from_segue == "topup" {
            lableOnPopup.text = "Top UP"
            
            electricityBill.setTitle("Airtime", for: .normal)
            tvSubscriptionBill.setTitle("Data", for: .normal)
            
            return
        }
        
        if from_segue == "recurring" {
            lableOnPopup.text = "Choose a payment"
            
            electricityBill.setTitle("Pay a contact", for: .normal)
            tvSubscriptionBill.setTitle("Pay bill", for: .normal)
            return
        }
   
    }
    
    override func viewWillAppear(_ animated: Bool) {
        check_button_clicked()
    }
    
    
    func check_button_clicked () {
        if from_segue == "transfer" {
            lableOnPopup.isHidden = true
            electricityBill.setTitle("VPD account", for: .normal)
            electricityBill.setTitle("Bank account", for: .normal)
            return
        }
    }
    
    
    @IBAction func electricityBillButtonPressed() {
        
        if electricityBill.titleLabel?.text == "Airtime" {
            
            to_segue = "goToAirTime"
            delegate?.goNext(next: to_segue)
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        if from_segue == "recurring" {
            to_segue = "goToPayContact"
            delegate?.goNext(next: to_segue)
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        if from_segue == "utility bills" {
            to_segue = "goToElectricity"
            delegate?.goNext(next: to_segue)
            self.dismiss(animated: true, completion: nil)
            return
        }
    }
    
    
    @IBAction func tvSubscriptionButtonPressed() {
        
        if tvSubscriptionBill.titleLabel?.text == "Data" {
            to_segue = "goToData"
            delegate?.goNext(next: to_segue)
            self.dismiss(animated: true, completion: nil)
        }
        
        if from_segue == "recurring" {
            to_segue = "goToSelectBill"
            delegate?.goNext(next: to_segue)
            self.dismiss(animated: true, completion: nil)
            return
        }
        if from_segue == "utility bills" {
            to_segue = "goTvSubscription"
            delegate?.goNext(next: to_segue)
            self.dismiss(animated: true, completion: nil)
        }
    
    }
    
    @IBAction func cancelButtonPressed() {
        dismiss(animated: true, completion: nil)
    }


}


extension UIColor {
    convenience init(hexFromString:String, alpha:CGFloat = 1.0) {
        var cString:String = hexFromString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        var rgbValue:UInt32 = 10066329 //color #999999 if string has wrong format
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) == 6) {
            Scanner(string: cString).scanHexInt32(&rgbValue)
        }
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
