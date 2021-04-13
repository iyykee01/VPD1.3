//
//  TabBarViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 10/06/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

var currentWalletSelected = ["walletId": "", "currency": "", "balance": "", "wallet_type": ""]

var currentWalletSelected2 = ""

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    var tabBarIteam = UITabBarItem()
    @IBOutlet weak var UitabBar: UITabBar!
    
    
    let kBarHeight: CGFloat = 60;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let color = UIColor(red: 0x34, green: 0xB5, blue: 0xCE)
    UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        
    UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: color], for: .selected)
        setUpTabarImage()
        self.delegate = self
        
        
        self.definesPresentationContext = true
        
        UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -5)
        
        
        //checkCurrentWallet()
    
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        tabBar.frame.size.height = kBarHeight
        tabBar.frame.origin.y = view.frame.height - kBarHeight
    }

    
    func checkCurrentWallet() {
        let currentWalletBalance = currentWalletSelected["balance"]
        
        if currentWalletBalance == "" {
            if let tabBarItemsArray = tabBarController?.tabBar.items {
                tabBarItemsArray[2].isEnabled = false
            }
        }
    }
    
    func setUpTabarImage () {
        
        
//        let global_Acct_Type = UserDefaults.standard.string(forKey: "account_type")!
//
//        if global_Acct_Type == "personal"  {
        
            let selectedImage = UIImage(named: "wallet")?.withRenderingMode(.alwaysOriginal)
            let deselectedImage = UIImage(named: "wallet1")?.withRenderingMode(.alwaysOriginal)
            tabBarIteam = self.tabBar.items![0]
            tabBarIteam.image = deselectedImage
            tabBarIteam.image = selectedImage
            
            
            let selectedImage2 = UIImage(named: "gift")?.withRenderingMode(.alwaysOriginal)
            let deselectedImage2 = UIImage(named: "gift1")?.withRenderingMode(.alwaysOriginal)
            tabBarIteam = self.tabBar.items![1]
            tabBarIteam.image = deselectedImage2
            tabBarIteam.image = selectedImage2
            
            
            let selectedImage3 = UIImage(named: "Actionbutton")?.withRenderingMode(.alwaysOriginal)
            let deselectedImage3 = UIImage(named: "Actionbutton")?.withRenderingMode(.alwaysOriginal)
            tabBarIteam = self.tabBar.items![2]
            tabBarIteam.image = deselectedImage3
            tabBarIteam.image = selectedImage3
            
            
            
            let selectedImage4 = UIImage(named: "bars1")?.withRenderingMode(.alwaysOriginal)
            let deselectedImage4 = UIImage(named: "bars")?.withRenderingMode(.alwaysOriginal)
            tabBarIteam = self.tabBar.items![3]
            tabBarIteam.image = deselectedImage4
            tabBarIteam.image = selectedImage4
            
            
            let selectedImage5 = UIImage(named: "more1")?.withRenderingMode(.alwaysOriginal)
            let deselectedImage5 = UIImage(named: "more")?.withRenderingMode(.alwaysOriginal)
            tabBarIteam = self.tabBar.items![4]
            tabBarIteam.image = deselectedImage5
            tabBarIteam.image = selectedImage5
        //}
        
//        else {
//            print("BUSINESS BABY..................")
//            let selectedImage = UIImage(named: "wallet1")?.withRenderingMode(.alwaysOriginal)
//            let deselectedImage = UIImage(named: "wallet")?.withRenderingMode(.alwaysOriginal)
//            tabBarIteam = self.tabBar.items![0]
//            tabBarIteam.image = deselectedImage
//            tabBarIteam.image = selectedImage
//
//
//            let selectedImage2 = UIImage(named: "stores1")?.withRenderingMode(.alwaysOriginal)
//            let deselectedImage2 = UIImage(named: "stores")?.withRenderingMode(.alwaysOriginal)
//            tabBarIteam = self.tabBar.items![1]
//            tabBarIteam.image = deselectedImage2
//            tabBarIteam.image = selectedImage2
//
//
//            let selectedImage3 = UIImage(named: "square")?.withRenderingMode(.alwaysOriginal)
//            let deselectedImage3 = UIImage(named: "square")?.withRenderingMode(.alwaysOriginal)
//            tabBarIteam = self.tabBar.items![2]
//            tabBarIteam.image = deselectedImage3
//            tabBarIteam.image = selectedImage3
//
//
//
//            let selectedImage4 = UIImage(named: "analytics1")?.withRenderingMode(.alwaysOriginal)
//            let deselectedImage4 = UIImage(named: "analytics")?.withRenderingMode(.alwaysOriginal)
//            tabBarIteam = self.tabBar.items![3]
//            tabBarIteam.image = deselectedImage4
//            tabBarIteam.image = selectedImage4
//
//
//            let selectedImage5 = UIImage(named: "more1")?.withRenderingMode(.alwaysOriginal)
//            let deselectedImage5 = UIImage(named: "more")?.withRenderingMode(.alwaysOriginal)
//            tabBarIteam = self.tabBar.items![4]
//            tabBarIteam.image = deselectedImage5
//            tabBarIteam.image = selectedImage5
//
//            self.selectedIndex = 0
//        }
    
        
    }
    
//    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//        let currentWalletBalance = currentWalletSelected["balance"]
//        if(currentWalletBalance == ""){
//            return true
//        }
//        else {
//            return false
//        }
//        
//    }
    // UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if(tabBarController.selectedIndex == 1){
            
            tabBarController.tabBar.isHidden = true
        }
        
    }
}

