//
//  NewLoaderViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 14/01/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit
import SwiftGifOrigin

class NewLoaderViewController: UIViewController {

    @IBOutlet weak var image: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        image.loadGif(name: "spinner")
    }
}



    

        
