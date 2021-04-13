//
//  SuccessAlertFullTransaction.swift
//  VPD
//
//  Created by Ikenna Udokporo on 14/01/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import Foundation
import UIKit


class SuccessAlertTransaction {
    
    func alert(success_message: String, completion: @escaping () -> Void) -> SuccessFullTransactionViewController {
        
        let storyboard = UIStoryboard(name: "SuccessfulTransaction", bundle: .main)
        
        let alertVC = storyboard.instantiateViewController(withIdentifier: "successfulTransaction") as! SuccessFullTransactionViewController
        
        alertVC.message = success_message
        
        alertVC.buttonAction = completion
        
        return alertVC
    }
}
