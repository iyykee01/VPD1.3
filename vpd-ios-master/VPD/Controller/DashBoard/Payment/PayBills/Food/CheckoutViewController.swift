//
//  CheckoutViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 27/01/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


struct SelectedMeal: Codable  {
    var meal: String
    var quantity: String
    var choice: String
}


struct paramToPurchase: Codable {
    var AppID : String
    var language : String
    var RequestID : String
    var SessionID: String
    var CustomerID: String
    var operation: String
    var wallet: String
    var name: String
    var phone: String
    var rid: String
    var delivery_address: String
    var delivery_location: String
    var delivery_city: String
    var delivery_note: String
    var options: [SelectedMeal]
    var transaction_pin: String
    var auth_key: String
}


class CheckoutViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    let order_amount = 0
    var price = ""
    var amount = 0
    var walletId = ""
    var cities = [Cities]()
    var city_id = ""
    var caller = 0
    
    var name = ""
    var phone = ""
    var delivery_address = ""
    var rid = ""
    var delivery_location = ""
    var delivery_note = ""
    var meal_choice = ""
    
    var choice = [String]()
    
    let piker = UIPickerView()
    let piker2 = UIPickerView()
    let piker3 = UIPickerView()
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    var choosen_meal = [Meal]()
    var choosen_meal2 = [Meal]()
    var meal_amount = [Int]()
    
    var delegate: callFood?
    
    
    var picked_meal_post =  [SelectedMeal]()
    var picked_meals = [String: String]()
    
    
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var textview_one: UITextView!
    @IBOutlet weak var mobile_numberTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cityTextField: DesignableUITextField!
    @IBOutlet weak var walletTextFeild: DesignableUITextField!
    @IBOutlet weak var phoneNumberTextfield: DesignableUITextField!
    @IBOutlet weak var city_not_location: DesignableUITextField!
    @IBOutlet weak var select_choices: DesignableUITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var height_for_select_choice: NSLayoutConstraint!
    @IBOutlet weak var view_for_select_choice: DesignableView!
    @IBOutlet weak var topHeight_for_fullname: NSLayoutConstraint!
    
    @IBOutlet weak var payButton: DesignableButton!
    var total = 0
    
    
    @IBOutlet weak var vpdPinTextLabel: UILabel!
    @IBOutlet weak var vpdPinTextField: UITextField!
    @IBOutlet weak var vpdBorderLine: UIView!
    var vpdPin = ""
    var transaction_face = face
    @IBOutlet weak var convenienceFeeLabel: UILabel!
    
    var fee_for_trans = LoginResponse["response"]["charges"]["food_convenience_fee"]["NGN"]["value"].stringValue
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        convenienceFeeLabel.text = "You'll be charged NGN\(fee_for_trans) convenience fee for this."
        
        // Do any additional setup after loading the view.
        tableView.rowHeight = 67
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
        //textfield
        nameTextField.delegate = self
        mobile_numberTextField.delegate = self
        cityTextField.delegate = self
        walletTextFeild.delegate = self
        phoneNumberTextfield.delegate = self
        city_not_location.delegate = self
        select_choices.delegate = self
        vpdPinTextField.delegate = self
        
        nameTextField.setLeftPaddingPoints(14)
        mobile_numberTextField.setLeftPaddingPoints(14)
        cityTextField.setLeftPaddingPoints(14)
        walletTextFeild.setLeftPaddingPoints(14)
        phoneNumberTextfield.setLeftPaddingPoints(14)
        city_not_location.setLeftPaddingPoints(14)
        select_choices.setLeftPaddingPoints(14)
        vpdPinTextField.setLeftPaddingPoints(14)
        
        textview_one.layer.borderWidth = 0.5
        textview_one.layer.borderColor = UIColor.lightGray.cgColor
        textview_one.layer.cornerRadius = 5.0;
        
        textview_one.text = "Enter your address"
        textview_one.textColor = UIColor.lightGray
        
        textview_one.delegate = self
        
        choosen_meal2 = choosen_meal
        
        getChoosenCount()
        view.layoutIfNeeded()
        
        for i in choosen_meal {
            meal_amount.append(Int(i.amount)!)
            total = meal_amount.reduce(0, +)
            choice = i.choice
        }
        
        payButton.setTitle("Pay NGN\(total)", for: .normal)
        
        
        piker.dataSource = self
        piker.delegate = self
        
        piker2.dataSource = self
        piker2.delegate = self
        
        piker3.dataSource = self
        piker3.delegate = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.donePicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        walletTextFeild.inputView = piker
        walletTextFeild.inputAccessoryView = toolBar
        
        cityTextField.inputView = piker2
        cityTextField.inputAccessoryView = toolBar
        
        
        select_choices.inputView = piker3
        select_choices.inputAccessoryView = toolBar
        vpdPinTextField.inputAccessoryView = toolBar;
        phoneNumberTextfield.inputAccessoryView = toolBar

        
        delayToNextPage()
        
        
        if choice.count == 0 {
            print("yesss")
            view_for_select_choice.isHidden = true
            height_for_select_choice.constant = 0
            topHeight_for_fullname.constant = 30
        }
        else {
            print("nanananan")
            view_for_select_choice.isHidden = false
            height_for_select_choice.constant = 45
            topHeight_for_fullname.constant = 70
        }

        
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
    @objc func donePicker(datePicker: UIDatePicker) {
        view.endEditing(true)
        vpdPin = vpdPinTextField.text!
        view.frame.origin.y = 0
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func getChoosenCount() {
        let counts = choosen_meal.count
        tableViewHeight.constant = CGFloat(67 * counts)
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 2 {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        }
        else {
            view.frame.origin.y = 0
        }
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.tag == 1 && textview_one.textColor == UIColor.lightGray {
            
            textview_one.text = nil
            textview_one.textColor = UIColor.black
            
            return
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.tag == 1 && textview_one.text.isEmpty {
            textview_one.text = "Enter your address"
            textview_one.textColor = UIColor.lightGray
            return
        }
    }
    
    /* Updated for Swift 4 */
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
    
    
    @IBAction func dropDownPickerWallet(_ sender: UIButton) {
        if sender.tag == 1 {
            walletTextFeild.inputView = piker
            walletTextFeild.becomeFirstResponder()
        }
        
        if sender.tag == 6 {
            select_choices.becomeFirstResponder()
        }
        else {
            cityTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        delegate?.callFoodApi()
        dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func purchaseButtonPressed(_ sender: Any) {
        
        caller = 1
        
        if nameTextField.text!.isEmpty || mobile_numberTextField.text!.isEmpty || phoneNumberTextfield.text!.isEmpty || cityTextField.text == "Select city" || walletTextFeild.text == "  Wallet" || vpdPin == "" {
            
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "Please fill all fields")
            self.present(alertVC, animated: true)
        }
        else {
            name = nameTextField.text!
            delivery_address = mobile_numberTextField.text!
            phone = phoneNumberTextfield.text!
            delivery_note = textview_one.text
            vpdPin = vpdPinTextField.text!
            delivery_location = city_id
            if caller == 1 {
                mealsArray(obj: choosen_meal2)
            }
            if transaction_face && isUserFace == false {
                let alertSV = FaceID()
                let alert = alertSV.showFaceID()
                self.present(alert, animated: true)
            }
            else {
                callToPurchase()
            }
            
        }
    }
    
    
    func mealsArray (obj: [Meal]) {
        for i in obj {
            let picked_meals = SelectedMeal(
                meal: i._id,
                quantity: String(i.count),
                choice: meal_choice
            )
            picked_meal_post.append(picked_meals)
        }
        
    }
    
    
    
    // MARK API Call
    //++++++=========Delay function @if token is true move to next page+++++++===========//
    func callToPurchase(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        if UserDefaults.standard.object(forKey: "authKey") != nil && transaction_face  {
            global_key = UserDefaults.standard.string(forKey: "authKey")!
        }
        
        
        //MARK: - This section is For converting class to objects

        let params = paramToPurchase(
            AppID: device.sha512,
            language: "en",
            RequestID: timeInSecondsToString,
            SessionID: session,
            CustomerID: customer_id,
            operation: "purchase",
            wallet: walletId,
            name: name,
            phone: phone,
            rid: rid,
            delivery_address: delivery_address,
            delivery_location: delivery_location,
            delivery_city: "Lagos",
            delivery_note: delivery_note,
            options: picked_meal_post,
            transaction_pin: vpdPin,
            auth_key: global_key
        )


        let jsonEncode = JSONEncoder()
        let jsonData = try! jsonEncode.encode(params)
        let json = String(data: jsonData, encoding: .utf8)!
        
        
        ///*********converting shaDeivcepptiies to hexString*********////////
        /////*********converting shaDeivcepptiies to hexString*********////////
        let hexShaDevicePpties = utililty.convertToHexString(json)
        print(hexShaDevicePpties)
        
        
        let parameter = ["reqData": hexShaDevicePpties]
        let token = UserDefaults.standard.string(forKey: "Token")!
        let headers: HTTPHeaders = ["X-Authorization": token, "AppGroup": "IOS"]
        
        
        
        let url = "\(utililty.url)food"
        
        postToPurchase(url: url, parameter: parameter, token: token, header: headers)
        global_key = ""
        isUserFace = false
    }
    
    
    ///////////***********Post Data MEthod*********////////
    func postToPurchase(url: String, parameter: [String: Any], token: String, header: [String: String]) {
        
        
        view.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        payButton.isHidden = true
        
        Alamofire.request(url, method: .post, parameters: parameter, headers: header).responseJSON {
            response in
            if response.result.isSuccess {
                print("SUCCESSFUL.....")
                
                //******Getting Data******//
                let data: JSON = JSON(response.result.value!)
                
                //****Decode json hear****/
                let hexKey = data["reqResponse"].stringValue
                
                /******Import  and initialize Util Class*****////
                let utililty = UtilClass()
                //********decripting Hex key**********//
                let decriptor = utililty.convertHexStringToString(text: hexKey)
                
                //**********Changing Data back to Json format***///
                let jsonData = decriptor.data(using: .utf8)!
                
                let decriptorJson: JSON = JSON(jsonData)
                print(decriptorJson)
                
                
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                
                
                if(status) {
                    self.view.isUserInteractionEnabled = !false
                    self.activityIndicator.stopAnimating()
                    self.payButton.isHidden = !true
                    let alertSV = SuccessAlertTransaction()
                    let alert = alertSV.alert(success_message: message) {
                        self.navigationController?.popToViewController(ofClass: ServicesViewController.self)
                    }
                    self.present(alert, animated: true)
                    
                }
                    
                else if (message == "Session has expired") {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    
                    ////From the alert Service
                    self.view.isUserInteractionEnabled = !false
                    self.payButton.isHidden = !true
                    self.activityIndicator.stopAnimating()
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                    
                }
            }
            else {
                self.view.isUserInteractionEnabled = !false
                self.payButton.isHidden = !true
                self.activityIndicator.stopAnimating()
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
                
            }
            self.picked_meal_post =  [SelectedMeal]()
        }
    }
    
    
    
    
    // MARK API Call
    //++++++=========Delay function @if token is true move to next page+++++++===========//
    func delayToNextPage(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "operation": "getlocations"]
        
        
        let jsonEncode = JSONEncoder()
        let jsonData = try! jsonEncode.encode(params)
        let json = String(data: jsonData, encoding: .utf8)!
        
        
        ///*********converting shaDeivcepptiies to hexString*********////////
        /////*********converting shaDeivcepptiies to hexString*********////////
        let hexShaDevicePpties = utililty.convertToHexString(json)
        //print(hexShaDevicePpties)
        
        
        let parameter = ["reqData": hexShaDevicePpties]
        let token = UserDefaults.standard.string(forKey: "Token")!
        let headers: HTTPHeaders = ["X-Authorization": token, "AppGroup": "IOS"]
        
        
        
        let url = "\(utililty.url)food"
        
        postData(url: url, parameter: parameter, token: token, header: headers)
    }
    
    
    ///////////***********Post Data MEthod*********////////
    func postData(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        
        view.isUserInteractionEnabled = false
        
        Alamofire.request(url, method: .post, parameters: parameter, headers: header).responseJSON {
            response in
            if response.result.isSuccess {
                print("SUCCESSFUL.....")
                
                //******Getting Data******//
                let data: JSON = JSON(response.result.value!)
                
                //****Decode json hear****/
                let hexKey = data["reqResponse"].stringValue
                
                /******Import  and initialize Util Class*****////
                let utililty = UtilClass()
                //********decripting Hex key**********//
                let decriptor = utililty.convertHexStringToString(text: hexKey)
                
                //**********Changing Data back to Json format***///
                let jsonData = decriptor.data(using: .utf8)!
                
                let decriptorJson: JSON = JSON(jsonData)
                //print(decriptorJson)
                
                
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                
                
                if(status) {
                    self.cities = [Cities]()
                    self.view.isUserInteractionEnabled = !false
                    
                    for i in decriptorJson["response"].arrayValue {
                        let new_city = Cities()
                        
                        new_city._id = i["_id"].stringValue
                        new_city.location_type = i["location_type"].stringValue
                        new_city.name = i["name"].stringValue
                        new_city.city_id["_id"] = i["city_id"]["_id"].stringValue
                        new_city.city_id["name"] = i["city_id"]["name"].stringValue
                        
                        self.cities.append(new_city)
                    }
                    
                }
                    
                else if (message == "Session has expired") {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    
                    ////From the alert Service
                    self.view.isUserInteractionEnabled = !false
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                    
                }
            }
            else {
                self.view.isUserInteractionEnabled = !false
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
                
            }
            
        }
    }
}


extension CheckoutViewController: handleMaths {
    
    func addition(counter: Int) {
        
        
        choosen_meal2[counter].count = choosen_meal2[counter].count + 1
        choosen_meal2[counter].amount = String(Int(choosen_meal2[counter].amount)! + meal_amount[counter])
      
        payButton.setTitle("Pay NGN\(choosen_meal2[counter].amount)", for: .normal)
        
        tableView.reloadData()
    }
    
    func subtract(counter: Int) {
        
        if choosen_meal2[counter].count == 1 {
            choosen_meal2[counter].amount = String(meal_amount[counter])
        }
        
        if choosen_meal2[counter].count > 1 {
            choosen_meal2[counter].count = choosen_meal2[counter].count - 1
            choosen_meal2[counter].amount = String(Int(choosen_meal2[counter].amount)! - meal_amount[counter])
        }
        
        payButton.setTitle("Pay NGN\(choosen_meal2[counter].amount)", for: .normal)
        
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        choosen_meal2 = [Meal]()
        print("i was called on view did disappear")
    }
}

extension CheckoutViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choosen_meal2.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CheckoutTableViewCell
        
        cell.selectionStyle = .none
        
        let dict = choosen_meal2[indexPath.row]
        
        cell.food_name.text = dict.name
        cell.amount_label.text = String(dict.count)
        cell.price_label.text = "NGN\(dict.amount)"
        cell.cellDelegate = self
        cell.index = indexPath
        
        return cell
    }
    
}


extension CheckoutViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == piker {
            return accountArray.count
        }
        else if pickerView == piker3 {
            return choice.count
        }
        else {
            return cities.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == piker {
            return accountArray[row].currency
        }
        else if pickerView == piker3 {
            return choice[row]
        }
        else {
            return cities[row].name
        }
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == piker {
            walletTextFeild.text  = "\(accountArray[row].currency) - Wallet"
            walletId = accountArray[row].wallet_uid
        }
        else if pickerView == piker3 {
            select_choices.text = choice[row]
            meal_choice = choice[row]
        }
        else {
            cityTextField.text  = cities[row].name
            city_id = cities[row].name
        }
        
    }
    
}






