//
//  ReadNotificationViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 20/04/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit

class ReadNotificationViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    
    var date = ""
    var message = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(date)
        // Do any additional setup after loading the view.
        let splited_incoming_date = date.split(separator: " ");
        let new_date = Date.dateFromCustom(customString: String(splited_incoming_date[0]))
        let customDate = Date.dateFormaterMonth(date: new_date)
        let split_date = customDate.split(separator: " ")
        
        print(splited_incoming_date[1])
        
        if split_date[0] == "1" {
            dateLabel.text = "Date: \(split_date[0])st \(split_date[1]) \(split_date[2]) @\(dateTime(date: String(splited_incoming_date[1])))"
        }
        else {
            dateLabel.text  = "Date: \(split_date[0])th \(split_date[1]) \(split_date[2]) @\(dateTime(date: String(splited_incoming_date[1])))"
        }
        
        
        messageLabel.text = message
    }
    
    func dateTime(date: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "h:mm a"
        let Date12 = dateFormatter.string(from: date!)
        
        return Date12
    }
    
    
    @IBAction func dimissButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
