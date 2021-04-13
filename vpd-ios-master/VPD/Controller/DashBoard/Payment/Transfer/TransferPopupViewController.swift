//
//  TransferPopupViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 26/09/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class TransferPopupViewController: UIViewController {

    
    @IBOutlet weak var cimemaButtonOutlet: DesignableButton!
    @IBOutlet weak var EventsButtonOutlet: DesignableButton!
    @IBOutlet weak var cancelButtonOutlet: DesignableButton!
    @IBOutlet weak var lableOnPopup: UILabel!
    
    var delegate: seguePerform?
    var from_segue = ""
    var to_segue = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        check_button_clicked()
    }
    
    
    func check_button_clicked () {
        if from_segue == "transfer" {
            lableOnPopup.isHidden = true
            cimemaButtonOutlet.setTitle("VPD account", for: .normal)
            EventsButtonOutlet.setTitle("Bank account", for: .normal)
        }
    }
    
    
    @IBAction func cinemaButtonPressed(_ sender: Any) {
        if from_segue == "transfer" {
            to_segue = "goToTransferToVPD"
            delegate?.goNext(next: to_segue)
            self.dismiss(animated: true, completion: nil)
            return
        }
        else {
            to_segue = "goToCinema"
            delegate?.goNext(next: to_segue)
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func eventButtonPressed() {
        if from_segue == "transfer" {
            to_segue = "goToTransferBank"
            delegate?.goNext(next: to_segue)
            self.dismiss(animated: true, completion: nil)
            return
        }
        else {
            from_segue = "events"
            to_segue = "goToEvents"
            delegate?.goNext(next: to_segue)
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func cancelButtonPressed() {
        dismiss(animated: true, completion: nil)
    }

}
