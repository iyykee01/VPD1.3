//
//  UsernameViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 21/05/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class UsernameViewController: UIViewController, UITextFieldDelegate {
    
    var bvn: String!
    var longitude: String!
    var latitude: String!
    var accountType: String!
    var mobile: String!
    var country: String!
    var fullname: String!
    var dob: String!
    var email: String!
    var username: String!
    
    
    //For Business segue
    var business_category = ""
    var business_name = ""
    var business_reg_no = ""
    var photoID = ""
    var businessCert = ""
    var utilityBills = ""
    
    @IBOutlet weak var buttonContainer: UIView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var viewConstrainst: NSLayoutConstraint!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
        
        usernameTextField.delegate = self
        usernameTextField.setLeftPaddingPoints(14)
            
        
        print(business_category, business_name, business_reg_no)
    }
    
    
//    ///Move button up
//    @objc func keyboardWillChange(notification: Notification){
//
//        guard let info = notification.userInfo else { return }
//        guard let frameInfo = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
//        let keyboardFrame = frameInfo.cgRectValue
//
//        let keyboardHeight = Int(keyboardFrame.height)
//
//        print(keyboardHeight)
//
//
//
//        UIView.animate(withDuration: 0.1){
//            self.viewConstrainst.constant = CGFloat(keyboardHeight + 90)
//            self.view.layoutIfNeeded()
//        }
//
//    }
//
//    //Stop listening for keyboard hide/show events//////
//    deinit {
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
//    }
//
//
//    func NsInformation(){
//        //Listen for keyboard events
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name:
//            UIResponder.keyboardWillShowNotification, object: nil)
//    }
    
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        NsInformation()
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //viewConstrainst.constant = 90
        view.endEditing(true)
        return false
    }
    
    
    @IBAction func nextButtonPressed(_ sender : Any){
        
        //viewConstrainst.constant = 90
        usernameTextField.resignFirstResponder()
        
        if(username != "") {
            username = usernameTextField.text
            performSegue(withIdentifier: "goToSVC6.5", sender: self)
        }
        else{
            print("Cant gooo")
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let SVC6 = segue.destination as! SignUpViewControllerPage6
        SVC6.accountType = accountType
        SVC6.bvn = bvn
        SVC6.longitude = longitude
        SVC6.latitude = latitude
        SVC6.mobile = mobile
        SVC6.country = country
        SVC6.fullname = fullname
        SVC6.dob = dob
        SVC6.email = email
        SVC6.username = username
        
        //For Business segue
         SVC6.business_category = business_category
         SVC6.business_name = business_name
         SVC6.business_reg_no = business_reg_no
         SVC6.photoID = photoID
         SVC6.businessCert = businessCert
         SVC6.utilityBills = utilityBills
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
