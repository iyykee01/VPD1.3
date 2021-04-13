//
//  ASSFInitialScreenViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 10/06/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit

class ASSFInitialScreenViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var searchTextField: UITextField!
    var agencyArray = ["Abia"]

    @IBOutlet weak var agencyTableVIew: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        agencyTableVIew.rowHeight = 70;
        agencyTableVIew.delegate = self
        agencyTableVIew.dataSource = self
        
        searchTextField.setLeftPaddingPoints(14);
        
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension ASSFInitialScreenViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return agencyArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GovernmentAgency1TableViewCell;
        cell.selectionStyle = .none
        cell.titleLabel.text = agencyArray[indexPath.row]
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if agencyArray[indexPath.row] != "Abia"{
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "Coming Soon!")
            self.present(alertVC, animated: true)
            return
        }
        else {
            performSegue(withIdentifier: "goToNewUser", sender: self)
        }
        
    }
    
    
}
