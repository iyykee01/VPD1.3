//
//  slideFuckingSlideViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 30/04/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class slideFuckingSlideViewController: UIViewController {

    @IBOutlet weak var test: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.bringSubviewToFront(test)
    }
    

   

}
