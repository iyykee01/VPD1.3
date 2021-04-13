//
//  MyCreditCardViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 19/06/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class MyCreditCardViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}


extension MyCreditCardViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "list_card_cell", for: indexPath) as! ListCardCell
        
        let arraydic = currencyList[indexPath.row]
        
        
        if arraydic.cu_name_abbr == "NGN" {
            cell.cardImage.image = UIImage(named: "flag")
        }
        else if arraydic.cu_name_abbr == "GBP" {
            cell.cardImage.image = UIImage(named: "uk")
        }
        else if arraydic.cu_name_abbr == "USD" {
            cell.cardImage.image = UIImage(named: "us")
        }
        else {
            cell.cardImage.image = UIImage(named: "eu")
        }
        cell.cardLabel.text = arraydic.cu_name_abbr
        cell.cardTypeLable.text = arraydic.cu_buying
        
        return cell;
    }
    
    
}
