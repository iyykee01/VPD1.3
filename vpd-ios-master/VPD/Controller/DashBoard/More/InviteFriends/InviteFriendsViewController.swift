//
//  InviteFriendsViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 22/08/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Contacts


class InviteFriendsViewController: UIViewController, UITextFieldDelegate {
    

    @IBOutlet weak var buttonLink: UIButton!
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    var indexRow: Int!
    
    var contacts = [Contacts]()
    var search_contacts = [Contacts]()
    
    var contact_name =  ""
    var contact_number = ""
    var link = invite_url
    var searching = false
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableview.delegate = self
        tableview.dataSource = self
        searchTextField.delegate = self
        
        tableview.rowHeight = 60
        
        buttonLink.setTitle(link, for: .normal)
        
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
         fetchContacts()
    }
    
    //************Handles search when input text is filled************//
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        let searchText = searchTextField.text
        searching = true
        search_contacts = contacts.filter({ $0.name.lowercased().prefix(searchText!.count) == searchText!.lowercased()})

        tableview.reloadData()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
    
    func share() {
        let activityVC = UIActivityViewController(activityItems: [link], applicationActivities: nil)
        
        activityVC.completionWithItemsHandler = { (nil, completed, _, error)
            in
            if completed {
                print("completed")
            }
            else {
                print("cancel")
            }
        }
        self.present(activityVC, animated: true, completion: nil)
    }
    
    //MARK: Link button Handler
    @IBAction func linkButtonPressed(_ sender: Any) {
        share()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func fetchContacts() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, err) in
            if let err = err {
                print("Failed access request", err)
            }
            if granted {
                print("Access granted")
                
                let keys = [CNContactGivenNameKey, CNContactPhoneNumbersKey, CNContactFamilyNameKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                
                do {
                    var contactsArray = [Contacts]()
                    
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointerIfYouWantToStop) in
                        
                        
                        let name = contact.givenName
                        let phoneNumber = contact.phoneNumbers.first?.value.stringValue ?? "No Phone number found"
                        
                        contactsArray.append(Contacts(name: name, phoneNumber: phoneNumber))
                    })
                    
                    self.contacts = contactsArray
                    
                    DispatchQueue.main.async {
                        self.tableview.reloadData()
                    }
                }
                catch let err {
                    print("Failed to enumerate contact", err)
                }
                
            }
            else {
                print("Access Denied")
            }
        }
        
    }

}



extension InviteFriendsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return search_contacts.count
        }
        
        else {
            return contacts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! InviteFriendsTableViewCell
        
        if searching {
             let contact = search_contacts[indexPath.row]
            
            cell.initialsLabel.text = String(contact.name.prefix(2))
            cell.nameLabel.text = contact.name
            cell.numberLable.text = contact.phoneNumber
        }
        else {
            let contact = contacts[indexPath.row]
            
            cell.initialsLabel.text = String(contact.name.prefix(2))
            cell.nameLabel.text = contact.name
            cell.numberLable.text = contact.phoneNumber
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexRow = indexPath.row
        
        let contact = contacts[indexRow]
        
        contact_name  = contact.name
        contact_number = contact.phoneNumber
        share()
        
    }
    
    
}






