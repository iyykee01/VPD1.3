//
//  RecurringPaymentViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 26/11/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class RecurringPaymentViewController: UIViewController, UITextFieldDelegate {
    
    var currency = "NGN"
    
    @IBOutlet weak var zeroTextField: UITextField!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var walletType: UILabel!
    @IBOutlet weak var zeroViewWrap: UIView!
    
    
    
    //From select bill segue
    var select_bill = ""
    
    
    //From add contact recurring segue
    var name_segue = ""
    var wallet = ""
    var phone = ""
    var amount = ""
    var contact_image = ""
    var balance = ""
    var account_number = ""
    var bank_code = ""
    var type = ""
    var number = ""
    var distributor = ""
    var provider = ""
    var planId = ""
    var card_number = ""
    
    var amt: Int = 0
    
    
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactPhone: UILabel!
    
    @IBOutlet weak var vpdPinTextLabel: UILabel!
    @IBOutlet weak var vpdPinTextField: UITextField!
    @IBOutlet weak var vpdBorderLine: UIView!
    var vpdPin = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if type == "tvsubscription" {
            zeroTextField.isUserInteractionEnabled = false
            zeroTextField.text = amount
        }
        
        if type != "vpdaccount" {
            contactImage.isHidden = true
        }
        
        // Do any additional setup after loading the view.
        
        zeroTextField.delegate = self
        vpdPinTextField.delegate = self;
        
        zeroTextField.attributedPlaceholder = NSAttributedString(string: updateAmount()!,
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        
        //zeroTextField.startBlink()
        
        contactImage!.sd_setImage(with: URL(string: contact_image), placeholderImage: UIImage(named: ""))
        contactName.text = name_segue
        contactPhone.text = phone
        
        balanceLabel.text = balance
        
        
        
        //***********Setting up Date Picker********************//
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.donePicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        
        zeroTextField.inputAccessoryView = toolBar
        vpdPinTextField.inputAccessoryView = toolBar;
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewWasTapped)))
        zeroViewWrap.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(textFieldTapped)))
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardwillChange(notification: Notification) {
        
        guard   let userInfo = notification.userInfo as? [String: NSObject],
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect  else { return }
        
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification  {
            view.frame.origin.y = -keyboardFrame.height / 2.0
        }
        else {
            view.frame.origin.y = 0
        }
        
    }
    
    //***********Method to handle date format and date dismiss*********//
    @objc func donePicker() {
        vpdPin = vpdPinTextField.text!
        view.endEditing(true)
    }
    
    
    func updateAmount() -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        
        let amount = Double(amt/100) + Double(amt%100)/100
        
        return formatter.string(from: NSNumber(value: amount))
    }
    
    //MARK - ADD Comma to Text
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 1 {
            if let digit = Int(string) {
                amt = amt * 10 + digit
                zeroTextField.text = updateAmount()
            }
            
            if string == "" {
                amt = amt/10
                zeroTextField.text = updateAmount()
            }
            
            return false
        }
            
        else if textField.tag == 2 {
            print("nil")
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        zeroTextField.stopBlink();
        print(textField.tag)
        if textField.tag == 2 {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        }
        else {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        }
    }
    
    
    @objc func textFieldTapped(sender: UIGestureRecognizer) {
        zeroTextField.stopBlink()
        zeroTextField.becomeFirstResponder()
    }
    
    
    @objc func viewWasTapped (sender : UITapGestureRecognizer) {
        zeroTextField.resignFirstResponder()
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        zeroTextField.endEditing(true)
        return false
    }
    
    func validate() {
        
        if (zeroTextField.text != "") && Int(zeroTextField.text!)! < 100 {
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "Minimum amount for transaction is 100")
            self.present(alertVC, animated: true)
        }
        
        if zeroTextField.text == "" {
            self.showToast(message: "Please fill all fields", font: UIFont(name: "Muli", size: 14)!)
        }
        else {
            view.endEditing(true)
            zeroTextField.resignFirstResponder()
        }
    }
    
    
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        
        if zeroTextField.text == "" || vpdPin == "" {
            self.showToast(message: "Please fill all fields", font: UIFont(name: "Muli", size: 14)!)
        }
        else {
            amount = zeroTextField.text!.split(separator: ",").joined()
            performSegue(withIdentifier: "goToRecurring", sender: self)
        }
        
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! RecurrenceViewController
        destination.amount = amount
        destination.wallet = wallet
        destination.phone = phone
        destination.bank_code = bank_code
        destination.type = type
        destination.account_number = account_number
        destination.distributor = distributor
        destination.number = number
        destination.provider = provider
        destination.planId = planId
        destination.card_number = card_number
        destination.vpdPin = vpdPin
    }
}
