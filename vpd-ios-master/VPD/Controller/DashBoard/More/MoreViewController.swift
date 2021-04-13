//
//  MoreViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 22/07/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SVProgressHUD
import SDWebImage
import Intercom

class MoreViewController: UIViewController, seguePerform {
    
    

    @IBOutlet weak var settings2Button: UIButton!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet var containerView: UIView!
    
    @IBOutlet weak var needHelpButton: UIButton!
    @IBOutlet weak var settingButton: DesignableButton!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    var image: UIImage!
    var message = ""

 
    
    override func viewDidLoad() {
        super.viewDidLoad();

        
        let base64_image = Profile["response"]["photo"].stringValue;
        
        print(base64_image, "Or said i found nothing here");
        profileImage!.sd_setImage(with: URL(string: base64_image), placeholderImage: UIImage(named: ""));

        
        let firstname = LoginResponse["response"]["lastname"].stringValue;
        let lastname = LoginResponse["response"]["firstname"].stringValue;
        
        
        fullnameLabel.text = "\(firstname) \(lastname)";
        
    
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        let base64_image = Profile["response"]["photo"].stringValue
        
        print(base64_image, "Or said i found nothing here")
        profileImage!.sd_setImage(with: URL(string: base64_image), placeholderImage: UIImage(named: ""))
    }
    
    
    @IBAction func buttonPressed(_ sender: UIButton){
        
        switch sender.tag {
        case 1:
            animatedButton(sender, segue: "goToContactUs", settingButton, button2: inviteButton, button3: logoutButton)
            break
        case 2:
            animatedButton(sender, segue: "goToSettings", needHelpButton, button2: inviteButton, button3: logoutButton)
            break
        case 3:
            animatedButton(sender, segue: "goToInviteFriends", settingButton, button2: needHelpButton, button3: logoutButton)
            break
        case 4:
            Intercom.logout()
            logout()
            break

        default:
            print("Nil")
        }
    }
    
    func logout() {
        let alertSV = LogoutAlert()
        let alert = alertSV.alert() {
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "login2") as? LoginWIthFaceOrTouchIDViewController
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        self.present(alert, animated: true)
    }
    
    func goNext(next: String) {
        if next != "1" {
            performSegue(withIdentifier: next, sender: self)
        }
        else {
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "webView") as? WebViewTermsAndConditionViewController
            vc?.url_segue = "https://voguepaydigital.com/terms"
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        
    }
    
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSettings" {
            let des = segue.destination as! SettingViewController
            des.delegate = self
        }
    }
    
    @IBAction func editProfileButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToEditProfile", sender: self)
    }
    
    func animatedButton (_ button: UIButton, segue: String, _ button1: UIButton, button2: UIButton, button3: UIButton) {
        UIButton.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
            button.center.x += self.view.bounds.width
        })
        UIButton.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
            self.performSegue(withIdentifier: segue, sender: self)
        })
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
            button1.center.x -= self.view.bounds.width
            button2.center.x -= self.view.bounds.width
            button3.center.x -= self.view.bounds.width
          
        })
        
        UIView.animate(withDuration: 1.5, delay: 0, options: [.curveEaseInOut], animations: {
            button.center.x -= self.view.bounds.width
            
        })
        UIView.animate(withDuration: 1.5, delay: 0, options: [.curveEaseInOut], animations: {
            button1.center.x += self.view.bounds.width
            button2.center.x += self.view.bounds.width
            button3.center.x += self.view.bounds.width
            
        })
    }
}


extension UIImageView {
    public func imageFromURL(urlString: String) {

        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        activityIndicator.startAnimating()
        if self.image == nil{
            self.addSubview(activityIndicator)
        }

        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in

            if error != nil {
                print(error ?? "No Error")
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                activityIndicator.removeFromSuperview()
                self.image = image
            })

        }).resume()
    }
}

