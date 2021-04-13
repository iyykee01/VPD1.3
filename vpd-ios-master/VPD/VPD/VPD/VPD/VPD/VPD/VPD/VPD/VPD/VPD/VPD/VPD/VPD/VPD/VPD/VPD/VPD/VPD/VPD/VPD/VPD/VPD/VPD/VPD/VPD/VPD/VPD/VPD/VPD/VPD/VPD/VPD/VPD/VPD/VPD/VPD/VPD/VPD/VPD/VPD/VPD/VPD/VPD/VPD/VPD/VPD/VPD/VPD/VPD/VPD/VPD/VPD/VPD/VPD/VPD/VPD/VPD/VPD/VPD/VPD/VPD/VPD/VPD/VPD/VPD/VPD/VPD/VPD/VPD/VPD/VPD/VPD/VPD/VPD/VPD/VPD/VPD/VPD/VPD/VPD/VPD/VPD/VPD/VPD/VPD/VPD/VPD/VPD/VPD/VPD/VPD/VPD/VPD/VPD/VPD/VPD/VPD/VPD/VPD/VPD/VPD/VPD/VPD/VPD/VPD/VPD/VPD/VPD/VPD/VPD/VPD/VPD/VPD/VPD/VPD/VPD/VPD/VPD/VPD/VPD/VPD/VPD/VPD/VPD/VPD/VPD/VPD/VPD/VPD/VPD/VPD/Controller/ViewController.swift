//
//  ViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 06/04/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var circle4: UIImageView!
    @IBOutlet weak var circle1: UIImageView!
    @IBOutlet weak var circle2: UIImageView!
    @IBOutlet weak var circle3: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        UIView.animate(withDuration: 1.5, delay: 0, options: [.autoreverse, .repeat], animations: {
            self.circle1.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }) { (finished) in
        UIView.animate(withDuration: 1, animations: {
            self.circle1.transform = CGAffineTransform.identity
        })
        }
        
        UIView.animate(withDuration: 1.5, delay: 0, options: [.autoreverse, .repeat],  animations: {
            self.circle2.transform = CGAffineTransform(scaleX: 2, y: 2)
        }) { (finished) in
            UIView.animate(withDuration: 1, animations: {
                self.circle2.transform = CGAffineTransform.identity
            })
        }
        
        UIView.animate(withDuration: 1.5, delay: 0, options: [.autoreverse, .repeat],  animations: {
            self.circle3.transform = CGAffineTransform(scaleX: 2.5, y: 2.5)
        }) { (finished) in
            UIView.animate(withDuration: 1, animations: {
                self.circle3.transform = CGAffineTransform.identity
            })
        }

        
        UIView.animate(withDuration: 1.5, delay: 0, options: [.autoreverse, .repeat],  animations: {
            self.circle4.transform = CGAffineTransform(scaleX: 2.5, y: 2.5)
        }) { (finished) in
            UIView.animate(withDuration: 1, animations: {
                self.circle4.transform = CGAffineTransform.identity
            })
        }


    }


}

