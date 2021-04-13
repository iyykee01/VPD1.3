//
//  AddSubWalletPopupViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 20/08/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire


class AddSubWalletPopupViewController: UIViewController {

    @IBOutlet weak var uiTableView: UITableView!
    @IBOutlet weak var no_wallet_label: UILabel!
    
    var subWalletArray = [Wallet]()
    var wallet_type = ""
    var message = ""
    
    let utililty = UtilClass()
    
    var delegate: passSelectedObj?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view
        uiTableView.rowHeight = 85
        
        //*****Method to remove duplicate from  accountArray
        subCurrencyList = subCurrencyList.filter({$0.cu_name_abbr != "NGN"})
        removeDuplicateCurrency()
        
        subCurrencyList.count == 0 ? (no_wallet_label.isHidden = false) : (no_wallet_label.isHidden = true)
        
    }
    
    func removeDuplicateCurrency() {

        for (index, i) in subCurrencyList.enumerated().reversed() {
            for j in subWalletArray {
                print(i.cu_name_abbr,  j.currency)
                if  i.cu_name_abbr == j.currency {
                    subCurrencyList.remove(at: index)
                }
            }
        }
        //self.uiTableView.reloadData()
    }
    

    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}


extension AddSubWalletPopupViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subCurrencyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath) as! WalletCell
        
        //******Remove styling from selected cell
        cell.selectionStyle = .none
        
        let arraydic = subCurrencyList[indexPath.row]
        
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
        
        let selectedCurrencyType = subCurrencyList[indexPath.row]
        delegate?.passingData(segue: "", type: "SUB" , abbr: selectedCurrencyType.cu_name_abbr)
        self.dismiss(animated: true, completion: nil)
    }
    
}
