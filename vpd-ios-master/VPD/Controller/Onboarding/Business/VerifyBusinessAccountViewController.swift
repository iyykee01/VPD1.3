//
//  VerifyBusinessAccountViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 17/09/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class VerifyBusinessAccountViewController: UIViewController, goBackDelegate {
    
    @IBOutlet weak var photoIDButton: UIButton!
    @IBOutlet weak var businessCertButton: UIButton!
    @IBOutlet weak var utilityBillButton: UIButton!
    
    var accountType = ""
    var bvn = ""
    var longitude = ""
    var latitude = ""
    var mobile = ""
    var country = ""
    var fullname = ""
    var dob = ""
    var email = ""
    
    var business_name = ""
    var business_category = ""
    var business_reg_no = ""
    
    
    var photoID = ""
    var businessCert = ""
    var utilityBills = ""
    
    var expected_photo = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
 

    //Conver UIImage to Base64 String//
    func makeBase64Image(imageToConvert: UIImage) -> String {
        
        //Made changes from 0.4 to 0.2
        let imageData: Data? = imageToConvert.jpegData(compressionQuality: 0.2)
        let imageStr = imageData?.base64EncodedString(options: .lineLength64Characters) ?? ""
        
        return imageStr
    }
    
    
    func imageCamera(image: UIImage) {
        if expected_photo == "photoID" {
            photoID =  makeBase64Image(imageToConvert: image)
            photoIDButton.setImage(UIImage(named: "Icon.png"), for: UIControl.State.normal)
        }
        
        if expected_photo == "businessCert" {
            businessCert =  makeBase64Image(imageToConvert: image)
            print("buinessssss cargt")
            businessCertButton.setImage(UIImage(named: "Icon.png"), for: UIControl.State.normal)
        }
        
        if expected_photo == "utilbill" {
            utilityBills =  makeBase64Image(imageToConvert: image)
            print("util bill")
            utilityBillButton.setImage(UIImage(named: "Icon.png"), for: UIControl.State.normal)
        }
        
    }
    
  

    @IBAction func buttonPressed(_ sender: UIButton) {
        
        switch sender.tag {
        case 2:
          
            expected_photo = "photoID"
            performSegue(withIdentifier: "goToPopUp", sender: self)
            
        case 3:
    
            expected_photo = "businessCert"
            performSegue(withIdentifier: "goToPopUp", sender: self)
            
        case 4:
            
            expected_photo = "utilbill"
            performSegue(withIdentifier: "goToPopUp", sender: self)
            
        case 5:
            
            self.validateImages()
            
        default:
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    func validateImages() {
        if photoID != "" && businessCert != "" && utilityBills != "" {
            performSegue(withIdentifier: "goToUsername", sender: self)
        }
        
        else {
            print("no go area")
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToPopUp" {
            let SCV = segue.destination as! chooseUploadTypeViewController
            SCV.expectedPhoto = expected_photo
            
            SCV.delegate = self
        }
        
        else if segue.identifier == "goToUsername" {
            let SCV = segue.destination as! UsernameViewController
            
                SCV.accountType = accountType
                SCV.bvn = bvn
                SCV.longitude = longitude
                SCV.latitude = latitude
                SCV.mobile = mobile
                SCV.country = country
                SCV.fullname = fullname
                SCV.dob = dob
                SCV.email = email
            
                SCV.business_category = business_category
                SCV.business_name = business_name
                SCV.business_reg_no = business_reg_no
                SCV.photoID = photoID
                SCV.businessCert = businessCert
                SCV.utilityBills = utilityBills
        }
    }

}

