//
//  ASSFMangeUserViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 26/06/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage

class ASSFMangeUserViewController: UIViewController {
    
    @IBOutlet weak var imageViewOutlet: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var accountNumber: UILabel!
    @IBOutlet weak var dateJoined: UILabel!
    @IBOutlet weak var level: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        NetworkCallCreateUserWallet()
    }
    
    //MARK: Make network to get agent profile
    func NetworkCallCreateUserWallet() {
        
        activityIndicator.startAnimating()
        
        let utililty = UtilClass()
        let device = utililty.getPhoneId()
        
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        
        //******getting parameter from string
        let params = [
            "AppID":device.sha512,
            "language":"en",
            "RequestID": timeInSecondsToString,
            "SessionID": session,
            "CustomerID": customer_id,
            "AgentID": agentIDFromReg
        ]
        
        utililty.delayToNextPage(params: params, path: "agent_profile") { result in
            switch result {
            case .failure(let error):
                self.activityIndicator.stopAnimating()
                
                print(error)
                print("Please check that you have internet connection")
                break
                
            case .success:
                
                let data: JSON = JSON(result.value!)
                
                //****Decode json hear****/
                let hexKey = data["reqResponse"].stringValue
                //******Import  and initialize Util Class*****////
                
                //********decripting Hex key**********//
                let decriptor = utililty.convertHexStringToString(text: hexKey)
                
                //**********Changing Data back to Json format***///
                let jsonData = decriptor.data(using: .utf8)!
                
                
                let decriptorJson: JSON = JSON(jsonData)
                print(decriptorJson)
                
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                
                if(status) {
                    self.activityIndicator.stopAnimating()
                    self.nameLabel.text = decriptorJson["response"]["name"].stringValue
                    self.accountNumber.text = decriptorJson["response"]["account_number"].stringValue
                    self.level.text = "Level \(decriptorJson["response"]["level"].stringValue)"
                    self.dateJoined.text = decriptorJson["response"]["date_joined"].stringValue
                    self.imageViewOutlet!.sd_setImage(with: URL(string: decriptorJson["response"]["photo"].stringValue));
                    
                }
                else if (message == "Session has expired") {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.activityIndicator.stopAnimating()
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
                break
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true);
    }
    
    @IBAction func editImageButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func cardButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToCard", sender: self);
    }
    
    @IBAction func userButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToUser", sender: self);
    }
    
}
