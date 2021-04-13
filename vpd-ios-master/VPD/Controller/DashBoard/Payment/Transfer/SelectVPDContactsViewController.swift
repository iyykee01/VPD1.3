//
//  SelectVPDContactsViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 06/02/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit
protocol vpdContactSelect {
    func selectVPDContact (contact: VPDContacts)
}

class SelectVPDContactsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var search_contact: DesignableUITextField!
    
    var recent_contact = vpd_contacts
    
    var search_data = [VPDContacts]()
    var searching = false
    
    var from_protocol: vpdContactSelect?
    
    var selected_contact: VPDContacts!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
        search_contact.setLeftPaddingPoints(14)
        
        
        search_contact.delegate = self
        
        tableView.rowHeight = 70
        
        search_contact.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    
    //************Handles search when input text is filled************//
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        let searchText = search_contact.text
        searching = true
        search_data = recent_contact.filter({$0.name.lowercased().prefix(searchText!.count) == searchText!.lowercased()})
    
        tableView.reloadData()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }

     
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}

extension SelectVPDContactsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 85)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recent_contact.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! RecentVPDContactCollectionViewCell
        
        let dic = recent_contact[indexPath.row]
        
        let splited_name = dic.name.split(separator: " ")
        cell.vpd_name.text = String(splited_name.first ?? "")

        cell.thumbnail_image!.sd_setImage(with: URL(string: dic.photo), placeholderImage: UIImage(named: ""))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selected_contact = recent_contact[indexPath.row]
        from_protocol?.selectVPDContact(contact: selected_contact)
        dismiss(animated: true, completion: nil)
    }
}

extension SelectVPDContactsViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return  search_data.count
        }
        else {
            return recent_contact.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SelectVPDContactTableViewCell
        
        if searching {
            let contact = recent_contact[indexPath.row]
            cell.selectionStyle = .none
            
            let splited_name = contact.name.split(separator: " ")
            cell.vpd_name.text = String(splited_name.first ?? "")
            cell.thumbnail_image!.sd_setImage(with: URL(string: contact.photo), placeholderImage: UIImage(named: ""))
        
        }
        
        else {
             let contact = recent_contact[indexPath.row]
             cell.selectionStyle = .none
             
             let splited_name = contact.name.split(separator: " ")
             cell.vpd_name.text = String(splited_name.first ?? "")
             cell.thumbnail_image!.sd_setImage(with: URL(string: contact.photo), placeholderImage: UIImage(named: ""))
        }
        
         return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected_contact = recent_contact[indexPath.row]
        from_protocol?.selectVPDContact(contact: selected_contact)
        dismiss(animated: true, completion: nil)
    }
    
}
