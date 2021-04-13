//
//  PayRecurringContactViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 25/11/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Contacts

class PayRecurringContactViewController: UIViewController {
    
    
    var indexRow: Int!
    @IBOutlet weak var tableview: UITableView!
    
    //var contacts = [Contacts]()
    
    var contact_name =  ""
    var contact_number = ""
    var contact_image = ""
    var contact = ""
    var type = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.rowHeight = 60
        
        
    }
    
    
    @IBAction func backButtonPressecd(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addAContactButtonPressed(_ sender: Any) {
        
        contact_name = ""
        contact_number = ""
        contact_image = ""
        contact =  "new_contact"
        performSegue(withIdentifier: "goToAddContact", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! AddContactViewController
        
        destination.name_segue = contact_name
        destination.phone_number_segue = contact_number
        destination.contact_image = contact_image
        destination.new_contact = contact
        destination.type = type
        
    }
}

extension PayRecurringContactViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return vpd_contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactTableViewCell
        cell.selectionStyle = .none
        
        let contact = vpd_contacts[indexPath.row]
        
        //cell.name_abbr.text = String(contact.name.prefix(2))
        
        cell.name.text = contact.name
        cell.phoneNumber.text = contact.phone
        cell.thumnailImage!.sd_setImage(with: URL(string: contact.photo), placeholderImage: UIImage(named: ""))
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexRow = indexPath.row
        
        let contact = vpd_contacts[indexRow]
        
        contact_name  = contact.name
        contact_number = contact.phone
        contact_image = contact.photo
        type = "contact"
        performSegue(withIdentifier: "goToAddContact", sender: self)
        
    }
    
    
}

