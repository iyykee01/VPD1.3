//
//  LogoutAlertClass.swift
//  VPD
//
//  Created by Ikenna Udokporo on 20/02/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import Foundation
import UIKit


class LogoutAlert {
    
    func alert(completion: @escaping () -> Void) -> LogoutAlertViewController {
        
        let storyboard = UIStoryboard(name: "Logout", bundle: .main)
        
        let alertVC = storyboard.instantiateViewController(withIdentifier: "logout") as! LogoutAlertViewController
        
        
        alertVC.buttonAction = completion
        
        return alertVC
    }
}
