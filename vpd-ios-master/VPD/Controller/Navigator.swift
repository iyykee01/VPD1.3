//
//  Navigator.swift
//  VPD
//
//  Created by Ikenna Udokporo on 17/01/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit

struct Navigator {
    
   
    func getDestination(for url: URL) -> UIViewController? {
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let tabBarController = storyboard.instantiateInitialViewController()
        
        
        
        let destination = Destination(for: url)
        
        switch destination {
            
        case .pay: return tabBarController
            
        case .payDetails(let payId):
            
            let navController = tabBarController?.navigationController
            
            print(tabBarController!)
            
            guard let userDetailsVC = storyboard.instantiateViewController(withIdentifier: "paymenLink") as? PaymentLinkViewController else { return nil }
            
            userDetailsVC.pay_link = payId
            
            navController?.pushViewController(userDetailsVC, animated: false)
            
            return tabBarController
            
        case .safari: return nil
            
        }
    }
    
    enum Destination {
        
        case pay
        
        case payDetails(Int)
        
        case safari
        
        init(for url: URL) {
            
            print(url.lastPathComponent)
            
            if url.lastPathComponent == "pay" {
                
                self = .pay
                
            }
            else if let payId = Int(url.lastPathComponent) {
                
                self = .payDetails(payId)
            }
                
            else {
                self = .safari
            }
        }
    }
}
