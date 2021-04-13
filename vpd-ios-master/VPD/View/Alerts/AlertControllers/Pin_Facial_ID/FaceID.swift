//
//  FaceID.swift
//  VPD
//
//  Created by Ikenna Udokporo on 28/05/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import Foundation
import UIKit

class FaceID {
    
    func showFaceID() -> FaceIDViewController {
        
        let storyboard = UIStoryboard(name: "FaceID", bundle: .main)
        
        let alertVC = storyboard.instantiateViewController(withIdentifier: "faceID") as! FaceIDViewController
        
        
        //alertVC.buttonAction = completion
        
        return alertVC
    }
}
