//
//  RememberBVNViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 05/09/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class RememberBVNViewController: UIViewController {

    @IBOutlet var viewContainer: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dimissView))
        
        viewContainer.addGestureRecognizer(tapGestureRecognizer)
    }
    

    @objc func dimissView(sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }

}
