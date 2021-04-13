//
//  DebitCreditCardViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 15/07/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class DebitCreditCardViewController: UIViewController {
    
    var fund_type = ""
    var amount = ""
    var walletID = ""
    var currency = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print( fund_type, amount, walletID, currency)
    }
    

    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addCardButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "goTozFundWithCard", sender: self)
    }
    @IBAction func useAnotherMethodButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cardButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "goTozFundWithCard", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goTozFundWithCard"  {
            let FTVC = segue.destination as! WalletFundingWithCardViewController
            FTVC.fund_type = fund_type
            FTVC.amount = amount
            FTVC.walletID = walletID
            FTVC.currency = currency
        }
    }
}
