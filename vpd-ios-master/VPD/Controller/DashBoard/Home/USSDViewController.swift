//
//  USSDViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 15/07/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class USSDViewController: UIViewController {
    
    @IBOutlet weak var transactionIDLabel: UILabel!
    @IBOutlet weak var ussdCodeLabel: UILabel!
    var ussdCode =  ""
    var transaction_id = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        transactionIDLabel.text = transaction_id
        ussdCodeLabel.text = ussdCode
        
        print(transaction_id, ussdCode)
    }
    

    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func doneButtonPressed(_ sender: Any) {
        navigationController?.popToViewController(ofClass: TabBarViewController.self)
    }
    
    //MARK - SHould call phone number in label
    @IBAction func callButtonPressed(_ sender: Any) {
        print("calll me")
        if transaction_id != "" &&  ussdCode != "" {
            dialNumber(number: ussdCode)
        }
    }
    
    func dialNumber(number : String) {
        
        if let url = URL(string: "tel://\(number)"),
            UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler:nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
            // add error message here
            print("there was an error")
        }
    }
}
