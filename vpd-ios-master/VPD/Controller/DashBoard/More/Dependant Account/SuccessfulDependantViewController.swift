//
//  SuccessfulDependantViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 26/08/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class SuccessfulDependantViewController: UIViewController, UITabBarControllerDelegate {
    
    @IBOutlet weak var linkLabel: UILabel!
    
    var link = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(link)
        
        linkLabel.text = link
        
    }
    

    @IBAction func doneButtonPressed(_ sender: Any) {
        self.tabBarController?.selectedIndex = 4
    }
    

}
