//
//  SelectAccountsViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 31/07/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class SelectAccountsViewController: UIViewController {
    
    
    var indexRow: Int!
    @IBOutlet weak var walletLabel: UILabel!
    
    var accountArray = [Wallet]()
    var subAccountArray = [CurrencyList]()
    
    
    var sortedWalletArray = [Wallet]()
    var sortedSubWalletArray = [CurrencyList]()
    
    var amount = ""
    var currency = ""
    var wallet_uid = ""
    var wallet_type = ""
    var toToCurrency = ""
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.rowHeight = 85
        tableView.delegate = self
        tableView.dataSource = self
        
        
//        if sortedWalletArray.count == 0 {
//            walletLabel.text = ""
//        }

        removeDuplicateCurrency()

    }
    
    func removeDuplicateCurrency () {
        
        if wallet_type == "MAIN" {
            walletLabel.text = "Sub Wallet"
            sortedSubWalletArray = subAccountArray.filter({$0.cu_name_abbr != currency})
        }
        else if wallet_type == "SUB" {
            walletLabel.text = "Wallet"
            sortedWalletArray = [accountArray[0]]
        }
    }
    
//    func removeDuplicateCurrency() {
//
//        if wallet_type == "MAIN"{
//            print("for Main")
//            for (index, i) in accountArray.enumerated().reversed() {
//                if (i.currency == currency || i.balance == "") {
//                    accountArray.remove(at: index)
//                }
//            }
//            sortedWalletArray = accountArray
//            sortedSubWalletArray = subAccountArray
//            if sortedWalletArray.count == 0 {
//                walletLabel.text = "Sub Wallet"
//            }
//        }
    
//        else if wallet_type == "SUB" {
//            print("for sub")
//            for (index, i) in subAccountArray.enumerated().reversed() {
//                if (i.cu_name_abbr == currency){
//                    subAccountArray.remove(at: index)
//                }
//            }
//            sortedSubWalletArray = subAccountArray
//
//            accountArray.remove(at: accountArray.count - 1)
//            sortedWalletArray = accountArray
//        }
//    }

    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToConvertWallet" {
            
            let destinationVC = segue.destination as! ConvertWalletViewController
            destinationVC.amount = amount
            destinationVC.currency = currency
            destinationVC.accountToType = toToCurrency
            
            if selectedRow == "MAIN" {
                destinationVC.selectedRowArray = sortedWalletArray[indexRow]
            }
            else {
                destinationVC.selectRowSubArray = sortedSubWalletArray[indexRow]
            }
            destinationVC.walletType = wallet_type
            destinationVC.wallet_uid = wallet_uid
        }
        
    }
    
     var selectedRow = ""
    
}

extension SelectAccountsViewController:  UITableViewDataSource, UITableViewDelegate  {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    /// directly affect the header and the header text///
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            
            
            if sortedWalletArray.count == 0 {
                
                walletLabel.text = "Sub Wallet"
                
            }
            else {
                headerView.contentView.backgroundColor = .white
                headerView.textLabel?.textColor = .black
                headerView.backgroundColor = .blue
            }
            
            headerView.textLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return ""
        }
            
        else if sortedWalletArray.count > 0  {
            return "" //Sub-Wallet
        }
        else {
            return ""
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return sortedWalletArray.count
        }
        else {
            return sortedSubWalletArray.count
        }
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WalletCell
            
            //******Remove styling from selected cell
            cell.selectionStyle = .none
            
            let cellArray = sortedWalletArray[indexPath.row]
            
            cell.labelForCell.text = "\(cellArray.currency) Wallet"
            
            if cellArray.currency == "NGN" {
                cell.imageForCell.image = UIImage(named: "flag")
            }
            else if cellArray.currency == "GBP" {
                cell.imageForCell.image = UIImage(named: "uk")
            }
            else if cellArray.currency == "USD" {
                cell.imageForCell.image = UIImage(named: "us")
            }
            else {
                cell.imageForCell.image = UIImage(named: "eu")
            }
            
            
            return cell
        }
            
        else {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! WalletCell
            
            
            //******Remove styling from selected cell
            cell1.selectionStyle = .none
            
            let cellArray = sortedSubWalletArray[indexPath.row]
            
            cell1.labelForCell.text = "\(cellArray.cu_name_abbr) Sub-Wallet"
            
            if cellArray.cu_name_abbr == "NGN" {
                cell1.imageForCell.image = UIImage(named: "flag")
            }
            else if cellArray.cu_name_abbr == "GBP" {
                cell1.imageForCell.image = UIImage(named: "uk")
            }
            else if cellArray.cu_name_abbr == "USD" {
                cell1.imageForCell.image = UIImage(named: "us")
            }
            else {
                cell1.imageForCell.image = UIImage(named: "eu")
            }
            
            
            return cell1
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        
        if indexPath.section == 0 {
            wallet_type = "MAIN"
            toToCurrency = "Wallet"
            selectedRow = wallet_type
        }
        else {
            wallet_type = "SUB"
            selectedRow = wallet_type
            toToCurrency = "Sub"
        }
        indexRow = indexPath.row
        performSegue(withIdentifier: "goToConvertWallet", sender: self)
    }
}
