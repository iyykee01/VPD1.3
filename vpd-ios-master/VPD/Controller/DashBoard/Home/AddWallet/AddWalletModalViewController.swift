//
//  AddWalletModalViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 01/07/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol passSelectedObj {
    func passingData(segue: String, type: String, abbr: String)
}

class AddWalletModalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var uiTableView: UITableView!
    var delegate: passSelectedObj?
    
    var indexRow: Int!
    var accountArray = [Wallet]()
    var wallet_type = ""
    
 
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
        uiTableView.rowHeight = 85
        
        //*****Method to remove duplicate from  accountArray
        removeDuplicateCurrency()
    }
    
    func removeDuplicateCurrency() {
        
        for (index, i) in currencyList.enumerated().reversed() {
            for j in accountArray {
                print(i.cu_name_abbr,  j.currency)
                if  i.cu_name_abbr == j.currency {
                    currencyList.remove(at: index)
                }
            }
        }
        //self.uiTableView.reloadData()
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencyList.count
    }
    
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath) as! WalletCell
    
        //******Remove styling from selected cell
        cell.selectionStyle = .none
    
        let arraydic = currencyList[indexPath.row]
    
        if arraydic.cu_name_abbr == "NGN" {
            cell.imageForCell.image = UIImage(named: "flag")
        }
        else if arraydic.cu_name_abbr == "GBP" {
            cell.imageForCell.image = UIImage(named: "uk")
        }
        else if arraydic.cu_name_abbr == "USD" {
            cell.imageForCell.image = UIImage(named: "us")
        }
        else {
            cell.imageForCell.image = UIImage(named: "eu")
        }
        cell.labelForCell.text = ("\(arraydic.cu_name_abbr) - \(arraydic.cu_name)")
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexRow = indexPath.row
        let selectedCurrencyType = currencyList[indexRow]
        delegate?.passingData(segue: "goToPhotID", type: "MAIN" , abbr: selectedCurrencyType.cu_name_abbr)
        self.dismiss(animated: true, completion: nil)

    }
   
}
