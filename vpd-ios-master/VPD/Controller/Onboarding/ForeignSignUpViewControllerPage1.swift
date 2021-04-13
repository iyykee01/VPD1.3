//
//  ForeignSignUpViewControllerPage1.swift
//  VPD
//
//  Created by Ikenna Udokporo on 08/05/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class ForeignSignUpViewControllerPage1: UIViewController {
    
    
    var mobile: String!
    var country: String!
    var longitude: String!
    var latitude: String!
    var accountType: String!
    var card: String!
    
    
    //MARK: This variable will determine what is being printed on the scan page
    var choosenButton: String!

    @IBOutlet weak var diriverLicense: UIButton!
    @IBOutlet weak var passport: UIButton!
    @IBOutlet weak var button: UIButton!
    
    let yourAttributes : [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15),
        NSAttributedString.Key.foregroundColor : UIColor.black,
        NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addBorderRadius(diriverLicense)
        addBorderRadius(passport)
        
        let attributeString = NSMutableAttributedString(string: "i don't have any of these ID's",
                                                        attributes: yourAttributes);
        button.setAttributedTitle(attributeString, for: .normal)
    }

    @IBAction func dirverLicensePressed(_ sender: Any) {
        choosenButton = "Driver's License"
        performSegue(withIdentifier: "goToSVCForeign2", sender: self)
    }
    
    @IBAction func passportPressed(_ sender: Any) {
        choosenButton = "Passport"
        performSegue(withIdentifier: "goToSVCForeign2", sender: self)
    }
    
    @IBAction func backButton(_ sender: Any) {
         dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSVCForeign2" {
            let destination = segue.destination as! ForeignSignUpViewControllerPage2
            
            destination.accountType = accountType
            destination.country = country
            destination.latitude = latitude
            destination.longitude = longitude
            destination.mobile = mobile
            destination.choosenParameter = choosenButton
            
        }
           
    }
    
    func addBorderRadius(_ button: UIButton) {
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        
    }
}


//extension ForeignSignUpViewControllerPage1: CameraImageDelegate {
//
//    func imageTakenFromCamera(image: UIImage, expectedPhoto: String) {
//        //dismiss(animated: true, completion: nil)
//
//        card = makeBase64Image(imageToConvert: image)
//
//    }
//
//    //Conver UIImage to Base64 String//
//    func makeBase64Image(imageToConvert: UIImage) -> String {
//
//        //Made changes from 0.4 to 0.2
//        let imageData: Data? = imageToConvert.jpegData(compressionQuality: 0.2)
//        let imageStr = imageData?.base64EncodedString(options: .lineLength64Characters) ?? ""
//
//        return imageStr
//    }
//
//}
