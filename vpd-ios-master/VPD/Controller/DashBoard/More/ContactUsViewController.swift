//
//  ContactUsViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 03/02/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit
import Intercom

class ContactUsViewController: UIViewController {
    
    let company = ICMCompany()
    
    
    var contactinfo =  [
        "phone": "+2348036314018",
        "email": "support@voguepaydigital.com",
        "facebook": "https://web.facebook.com/Voguepaydigital-104006334287597/",
        "twitter": "https://twitter.com/voguepaydigital",
        "instagram": "https://instagram.com/voguepaydigital"
    ]
    
    var username = UserDefaults.standard.string(forKey: "userName")!
    
    var url = ""
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        phoneNumberLabel.text = contactinfo["phone"]
        Intercom.registerUser(withUserId: username)
        //Intercom.updateUser(username);
        company.companyId = username
        let userAttributes = ICMUserAttributes()
        userAttributes.companies = [company]
        Intercom.updateUser(userAttributes)
        
       
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func all_button(sender: UIButton) {
        switch sender.tag {
        case 1:
            Intercom.presentMessenger();
        case 2:
            dialNumber(number: contactinfo["phone"] ?? "")
        case 3:
            print("support")
        case 4:
            url = contactinfo["facebook"] ?? ""
            performSegue(withIdentifier: "goToWebView", sender: self)
        case 5:
            url = contactinfo["twitter"] ?? ""
            performSegue(withIdentifier: "goToWebView", sender: self)
        case 6:
            url = contactinfo["instagram"] ?? ""
            performSegue(withIdentifier: "goToWebView", sender: self)
        
        default:
            print("none")
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToWebView" {
            let destination = segue.destination as! WebViewForContactsViewController
            destination.url_segue = url
        }
        
    }
    
    func dialNumber(number : String) {
        
        if let url = URL(string: "tel://\(number)"),
            UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler:nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
            // add error message here
            print("there was an error")
        }
    }
    
}

