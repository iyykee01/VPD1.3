//
//  CardViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 11/06/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class CashBox: UIViewController, seguePerformBackwards {
    
    
    
    @IBOutlet weak var imageToTransform: UIImageView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var cashboxLabel: UILabel!
    @IBOutlet weak var welcomeConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //print(currencyList.count)
    

        welcomeLabel.alpha = 0
        cashboxLabel.alpha = 0
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animationFunc()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {

            // should segue only when animation is done
            self.performSegue(withIdentifier: "goToSceenTwo", sender: self)
        }
    }
    
    func goBack() {
        tabBarController?.selectedIndex = 0
        tabBarController?.tabBar.isHidden = false
    }
    
    
    func animationFunc() {
        UIView.animate(withDuration: 0.7, delay: 0, options: [.curveEaseInOut], animations: {
            self.imageToTransform.transform = CGAffineTransform(scaleX: 3.2, y: 3.2)

        })
        
        UIView.animate(withDuration: 0.7, delay: 1.0, options: [.curveEaseInOut], animations: {
           
            self.welcomeLabel.alpha = 1
            self.cashboxLabel.alpha = 1
            self.welcomeLabel.transform = CGAffineTransform(translationX: 0, y: -250)
            self.cashboxLabel.transform = CGAffineTransform(translationX: 0, y: -250)
            //self.view.layoutIfNeeded()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToSceenTwo" {
            
            let destinationVC =  segue.destination as! CashboxBalanceViewController
                
            destinationVC.delegate = self
        }
        

    }
}
