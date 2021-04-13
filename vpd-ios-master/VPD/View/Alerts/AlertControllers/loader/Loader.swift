//
//  Loader.swift
//  VPD
//
//  Created by Ikenna Udokporo on 14/01/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import Foundation
import UIKit

class LoaderPopup {
    
    func Loader() -> NewLoaderViewController {
        
        let storyboard = UIStoryboard(name: "LoaderAlert", bundle: .main)
        
        let alertVC = storyboard.instantiateViewController(withIdentifier: "loaderSB") as! NewLoaderViewController
        
        return alertVC
    }
}
