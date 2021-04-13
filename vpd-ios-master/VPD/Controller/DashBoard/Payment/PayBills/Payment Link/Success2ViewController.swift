//
//  Success2ViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 21/11/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class Success2ViewController: UIViewController {

    @IBOutlet weak var headerText: UILabel!
    @IBOutlet weak var bodyText1: UILabel!
    @IBOutlet weak var bodyText2: UILabel!
    @IBOutlet weak var bodyText3: UILabel!
    @IBOutlet weak var linkOrPin: UILabel!
    @IBOutlet weak var linkCopiedButton: DesignableButton!
    @IBOutlet weak var copyLinkButton: DesignableButton!
    
    var from_segue = ""
    var message = ""
    var linkOrPinAddress = ""
    var response_link_segue = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(linkOrPinAddress, ".........28 {copy link}")

        // Do any additional setup after loading the view.
        
        linkOrPin.text = linkOrPinAddress
        headerText.text = message
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if from_segue == "link" {
            linkOrPin.font = .systemFont(ofSize: 16, weight: .semibold)
            bodyText1.text = ""
            bodyText2.text = ""
            bodyText3.text = "Share link to recieve payment"
        }
        linkCopiedButton.center.y += view.bounds.height
        //linkCopiedButton.alpha = 0
    }

    
    @IBAction func copyLinkPressed(_ sender: Any) {
        
        UIPasteboard.general.string = linkOrPin.text
        UIView.animate(withDuration: 0.5, delay: 0.1, options: [.curveEaseInOut], animations: { 
            self.copyLinkButton.alpha = 0
            
            self.linkCopiedButton.isHidden = false
            self.linkCopiedButton.alpha = 1
            //self.linkCopiedButton.center.y -= self.view.bounds.height
        })
        
        UIView.animate(withDuration: 0.5, delay: 1.5, animations:  {
            self.linkCopiedButton.alpha = 0
        })
    }
    
    
    @IBAction func donePressed(_ sender: Any) {
        guard let VCS = self.navigationController?.viewControllers else {return }
        for controller in VCS {
            if controller.isKind(of: TabBarViewController.self) {
                let tabVC = controller as! TabBarViewController
                tabVC.selectedIndex = 0
                self.navigationController?.popToViewController(ofClass: TabBarViewController.self, animated: true)
                
            }
        }
    }
}
