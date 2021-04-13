//
//  LinkedExitingAccountViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 21/10/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

protocol CellTapped {
    func cellWasTapped(bool: Bool, acct_number: String)
}


protocol goBack {
    func go_back(bool: Bool)
}

class LinkedExitingAccountViewController: UIViewController, ErrorFromLaunch {
   
    var seletedAccount: LinkedAccountModel?
    /***********Delegate property for Protocol*************/
    var delegate: CellTapped?
    var delegate2: goBack?
    
    var is_true = false
    var what_will_show = ""
    var message = ""
    var linked_account = [LinkedAccountModel]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
 
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        if is_true {
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: message)
            self.present(alertVC, animated: true)
        }
        
    }
    
    //MARK: - Protocol
    func Error(error: String) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
             ////From the alert Service
             let alertService = AlertService()
             let alertVC = alertService.alert(alertMessage: error)
             self.present(alertVC, animated: true)
        }
           
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
//        self.delegate2?.go_back(bool: true)
//        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
         self.delegate2?.go_back(bool: true)
        dismiss(animated: true, completion: nil)
       
    }
    @IBAction func createNewAccountButton(_ sender: Any) {
        performSegue(withIdentifier: "goToCreateNewBankAcct", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToCreateNewBankAcct" {
            let destination = segue.destination as! UpgradeAccountViewController
            
            what_will_show = "goToCreateNewBankAcct"
            destination.from_segue = what_will_show
        }
        
        if segue.identifier == "goToUpgradeBank" {
            let destination = segue.destination as! JustAMoment2ViewController
            
            destination.seletedAccount = seletedAccount
            destination.delegate = self
        }
        
    }
    
}

extension LinkedExitingAccountViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return linked_account.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! LinkedExitingAccountCollectionViewCell
        
        let rows = linked_account[indexPath.row]
        
        cell.accountnumber.text = rows.account_number
        cell.bankImageView.image = UIImage(named: "uk")
        cell.name.text = rows.account_name
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let row_select = linked_account[indexPath.row]
        seletedAccount = row_select
        performSegue(withIdentifier: "goToUpgradeBank", sender: self)
        
    }
    
}
