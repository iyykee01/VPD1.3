//
//  AirTimeViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 03/10/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SVProgressHUD

class AirTimeViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet var viewWrapper: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headerLable1: UILabel!
    @IBOutlet weak var headerLabel2: UILabel!
    @IBOutlet weak var collectionViewWrap: UICollectionView!
    @IBOutlet weak var serviceTextField: DesignableUITextField!
    @IBOutlet weak var phoneNumberTextField: DesignableUITextField!
    @IBOutlet weak var topupButton: DesignableButton!
    @IBOutlet weak var dropDownButton: UIButton!
    @IBOutlet weak var walletViewWrapper: DesignableView!
    @IBOutlet weak var dropDownTextField: UITextField!
    @IBOutlet weak var buttonTitle: DesignableButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var walletTextField: DesignableUITextField!
    @IBOutlet weak var walletLabel: UILabel!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var walletHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var networkFieldHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var vpdPinTextLabel: UILabel!
    @IBOutlet weak var vpdPinTextField: UITextField!

    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var convenienceFeeLabel: UILabel!
    
    
    
    var from_segue = ""
    var phone_number = ""
    var success_message = ""
    var type = ""
    
    let piker1 = UIPickerView()
    let piker2 = UIPickerView()
    
    var ticket_id = [DataModel]()
    
    //*******Initializing array to be populated**********//
    var countryDatas: [DataOBjectClass]?  = []
    
    var dataArray = [DataModel]()
    var selected_data_plan = [DataModel]()
    
    
    
    var fee_for_trans = LoginResponse["response"]["charges"]["data_convenience_fee"]["NGN"]["value"].stringValue
    
    var counter = 0
    var selected = false
    var wallet_uid = ""
    var plan_id = ""
    var price = ""
    
    
    
    var user_number = Profile["response"]["phone"].stringValue
    var to_send_number = ""
    var number_with_code = ""
    var vpdPin = ""
    var transaction_face = face
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        convenienceFeeLabel.text = "You'll be charged NGN\(fee_for_trans) convenience fee for this."
        // Do any additional setup after loading the view.
        tableHeightConstraint.constant = 0 // 300
        walletHeightConstraint.constant = 0 // 47
        networkFieldHeightConstraint.constant = 0 // 47
        collectionViewWrap.dataSource = self
        collectionViewWrap.delegate = self
        collectionViewWrap.allowsMultipleSelection = false
        scrollView.isScrollEnabled = false
        
        serviceLabel.isHidden = true;
        serviceTextField.isHidden = true;
        
        print(from_segue)
        
        walletViewWrapper.isHidden = true
        walletLabel.isHidden = true
        
        walletTextField.delegate = self
        phoneNumberTextField.delegate = self
        serviceTextField.delegate = self
        vpdPinTextField.delegate = self;
        
        walletTextField.setLeftPaddingPoints(15)
        serviceTextField.setLeftPaddingPoints(15)
        phoneNumberTextField.setLeftPaddingPoints(10)
        vpdPinTextField.setLeftPaddingPoints(14)
        
        
        headerLable1.text = "Mobile data top up"
        headerLabel2.text = "Top up mobile data directly from your wallet."
        
        piker1.dataSource = self
        piker1.delegate = self
        
        piker2.dataSource = self
        piker2.delegate = self
        
        
        walletTextField.inputView = piker1
        dropDownTextField.inputView = piker2
        
        fetchJsonFromFile()
        
        if type == "data" {
            convenienceFeeLabel.isHidden = true
            topupButton.setTitle("Next", for: .normal)
        }
        
        buttonTitle.setTitle("Recharge\(user_number)", for: .normal)
        
        phoneNumberTextField.addTarget(self, action: #selector(removeZero), for: UIControl.Event.editingChanged);
        
        
        
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
        
        
        walletTextField.inputAccessoryView = toolBar;
        phoneNumberTextField.inputAccessoryView = toolBar;
        serviceTextField.inputAccessoryView = toolBar;
        vpdPinTextField.inputAccessoryView = toolBar;
        
        topupButton.setTitle("Validate Number", for: .normal);
        topupButton.isUserInteractionEnabled = false;
    }
    
    //***********Method to handle date format and date dismiss*********//
    @objc func donePicker(datePicker: UIDatePicker) {
        view.endEditing(true)
        vpdPin = vpdPinTextField.text!
        view.frame.origin.y = 0
        topupButton.isUserInteractionEnabled = true
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        // handling code
        view.frame.origin.y = 0
        view.endEditing(true)
    }
    
    @objc func keyboardwillChange(notification: Notification) {
        
        guard   let userInfo = notification.userInfo as? [String: NSObject],
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect  else { return }
        
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification  {
            view.frame.origin.y = -keyboardFrame.height
        }
        else {
            view.frame.origin.y = 0
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 2 {
            
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        }
        else {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil);
            view.frame.origin.y = 0
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        walletTextField.endEditing(true)
        phoneNumberTextField.endEditing(true)
        view.frame.origin.y = 0
        
        if phoneNumberTextField.text != "" {
            phone_number = phoneNumberTextField.text ?? ""
            callTopAirtimeAPI()
        }
        return false
    }
    
    //**********Remove User Zero **********//
    @objc func removeZero() {
        if (self.phoneNumberTextField.text?.hasPrefix("0"))! {
            self.phoneNumberTextField.text?.remove(at:(self.phoneNumberTextField.text?.startIndex)!)
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        view.frame.origin.y = 0
        if !phoneNumberTextField.text!.isEmpty {
            
            topupButton.backgroundColor = UIColor(hexFromString: "#34B5CE")
            topupButton.setTitleColor(.white, for: .normal)
            topupButton.isEnabled = true
        }
        else {
            topupButton.backgroundColor = .lightGray
            topupButton.titleLabel?.textColor = .darkGray
            topupButton.isUserInteractionEnabled = false
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.tag == 1 {
            topupButton.backgroundColor = .lightGray
            topupButton.titleLabel?.textColor = .darkGray
            topupButton.isUserInteractionEnabled = false
            ticket_id = [DataModel]()
            collectionViewWrap.reloadData()
            topupButton.isUserInteractionEnabled = true
            topupButton.setTitle("Validate Number", for: .normal)
        }
        
        return true
    }
    
    
    func callTopAirtimeAPI(){
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        
        if user_number == phone_number {
            number_with_code = phone_number
            to_send_number = number_with_code
        }
        else {
            number_with_code = "\(dropDownTextField.text ?? "")\(phone_number)"
            to_send_number = number_with_code
        }
        
        
        
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "type": "data", "operation": "getprovider", "phone": number_with_code]
        
        
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
        
        
        
        let url = "\(utililty.url)topup_payment"
        
        postData(url: url, parameter: parameter, token: token, header: headers)
    }
    
    ///////////***********Post Data MEthod*********////////
    func postData(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        SVProgressHUD.show()
        plan_id = ""
        
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
                
                
                let data_plan = decriptorJson["response"]["plan"].arrayValue
                
                
                if(status) {
                    //********Response from server *******//
                    self.serviceTextField.text = decriptorJson["response"]["operator"].stringValue
                    SVProgressHUD.dismiss()
                    self.serviceTextField.isHidden = false
                    self.serviceLabel.isHidden = false
                    self.walletViewWrapper.isHidden = false
                    self.walletLabel.isHidden = false
                    self.collectionViewWrap.isHidden = false
                    self.tableHeightConstraint.constant = 300
                    self.networkFieldHeightConstraint.constant = 45
                    self.vpdPinTextLabel.isHidden = false
                    self.vpdPinTextField.isHidden = false
                    self.walletHeightConstraint.constant = 47
                    self.scrollView.isScrollEnabled = true
                    self.dataArray = [DataModel]()
                    self.topupButton.setTitle("Top up", for: .normal)
                    self.topupButton.isUserInteractionEnabled = true;
                    
                    for i in data_plan {
                        let new_data_Model = DataModel()
                        
                        new_data_Model.amount = i["amount"].stringValue
                        new_data_Model.currency = i["currency"].stringValue
                        new_data_Model.data = i["data"].stringValue
                        new_data_Model.id = i["id"].stringValue
                        new_data_Model.validity = i["validity"].stringValue
                        new_data_Model.selected = false
                        
                        
                        self.dataArray.append(new_data_Model)
                        
                    }
                    
                }
                    
                else if  message == "Session has expired" {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    SVProgressHUD.dismiss()
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                SVProgressHUD.dismiss()
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
            }
            self.collectionViewWrap.reloadData()
        }
    }
    
    
    //MARK: IBACTIONS
    
    @IBAction func backButtonPressed(_ sender: Any) {
        SVProgressHUD.dismiss()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dropDownButtonPressed(_ sender: Any) {
        walletTextField.becomeFirstResponder()
    }
    
    @IBAction func topupButtonPressed(_ sender: Any) {
        vpdPin = vpdPinTextField.text!
        
        
        if topupButton.titleLabel?.text == "Validate Number" &&  phoneNumberTextField.text != "" {
            phoneNumberTextField.endEditing(true)
            phone_number = phoneNumberTextField.text!
            callTopAirtimeAPI()
            return
        }
        
        if !selected || plan_id == "" {
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "Please select your data choice")
            self.present(alertVC, animated: true)
            return
        }
        
        if wallet_uid == "" {
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "Please Select Wallet currency")
            self.present(alertVC, animated: true)
            return
        }
        
        if phoneNumberTextField.text != "" && serviceTextField.text != "" && wallet_uid != "" && plan_id != "" && type == "data" && vpdPin != "" {
            
            phone_number = phoneNumberTextField.text!
            performSegue(withIdentifier: "goToRecurring", sender: self);
            phone_number = ""
            return
        }
            
        if phoneNumberTextField.text != "" && serviceTextField.text != "" && walletTextField.text != "" && plan_id != "" && vpdPin != "" && topupButton.titleLabel?.text != "Validate Number" {
            
            if transaction_face && isUserFace == false {
                let alertSV = FaceID()
                let alert = alertSV.showFaceID()
                self.present(alert, animated: true)
            }
            else {
                topupDataAPI()
            }
            
            return
        }
            
            
        else {
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "Please fill all fields")
            self.present(alertVC, animated: true)
            
        }
    }
    
    @IBAction func number_button_pressed(_ sender: Any) {
        
        phoneNumberTextField.text! = user_number
        phone_number = phoneNumberTextField.text!
        topupButton.backgroundColor = UIColor(hexFromString: "#34B5CE")
        topupButton.setTitleColor(.white, for: .normal)
        topupButton.isEnabled = true
        self.topupButton.setTitle("Top up", for: .normal)
        self.topupButton.isUserInteractionEnabled = true;
        callTopAirtimeAPI()
        
    }
    
    
    func topupDataAPI(){
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //\(dropDownTextField.text ?? "")
        
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        if UserDefaults.standard.object(forKey: "authKey") != nil && transaction_face  {
            global_key = UserDefaults.standard.string(forKey: "authKey")!
        }
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "type": "data", "operation": "purchase", "phone": number_with_code, "wallet": wallet_uid, "plan": plan_id, "amount": price, "transaction_pin": vpdPin, "auth_key": global_key]
        
        
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
        
        
        let url = "\(utililty.url)topup_payment"
        
        postData2(url: url, parameter: parameter, token: token, header: headers)
        global_key = ""
        isUserFace = false
    }
    
    ///////////***********Post Data MEthod*********////////
    func postData2(url: String, parameter: [String: String], token: String, header: [String: String]) {
        SVProgressHUD.setBackgroundColor(.lightGray)
        SVProgressHUD.show()
        
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
                    //********Response from server *******//
                    SVProgressHUD.dismiss()
                    self.success_message = message
                    let alertSV = SuccessAlertTransaction()
                    let alert = alertSV.alert(success_message: message) {
                        guard let VCS = self.navigationController?.viewControllers else {return }
                        for controller in VCS {
                            if controller.isKind(of: TabBarViewController.self) {
                                let tabVC = controller as! TabBarViewController
                                tabVC.selectedIndex = 0
                                self.navigationController?.popToViewController(ofClass: TabBarViewController.self, animated: true)
                                
                            }
                        }
                    }
                    self.present(alert, animated: true)
                }
                    
                else if  message == "Session has expired" {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    SVProgressHUD.dismiss()
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                SVProgressHUD.dismiss()
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "fromData" {
            let destination = segue.destination as! FailedControllerViewController
            destination.from_segue = success_message
            
        }
        
        if segue.identifier == "goToRecurring" {
            let destination = segue.destination as! RecurrenceViewController
            destination.wallet = wallet_uid
            destination.type = type
            destination.phone = "+234\(phone_number)"
            destination.plan = plan_id
            destination.vpdPin = vpdPin
            
        }
    }
    
}



extension AirTimeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dataCell", for: indexPath) as! DataCellCollectionViewCell
        
        if ticket_id.count == 1 && ticket_id[0].id == dataArray[indexPath.row].id {
            cell.datalabel.textColor = .white
            cell.periodlabel.textColor = .white
            cell.viewWrap.backgroundColor = UIColor(hexFromString: "#34B5CE")
        }
        else {
            cell.datalabel.textColor = UIColor(hexFromString: "#34B5CE")
            cell.periodlabel.textColor = .darkGray
            cell.viewWrap.backgroundColor = .white
        }
        
        cell.amountlabel.text = dataArray[indexPath.row].amount
        cell.periodlabel.text = dataArray[indexPath.row].validity
        
        if Int(dataArray[indexPath.row].data) ?? 0 < 1000 {
            cell.datalabel.text = "\(dataArray[indexPath.row].data)MB"
        }
        
        if Int(dataArray[indexPath.row].data) ?? 0 > 1000 {
            let divide_num = (Int(dataArray[indexPath.row].data) ?? 0 ) / 1000
            cell.datalabel.text = "\(String(divide_num))GB"
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selected = true
        let selected_row = dataArray[indexPath.row]
        plan_id = selected_row.id
        price = selected_row.amount
        
        if ticket_id.count == 1 {
            ticket_id = [DataModel]()
            ticket_id.append(selected_row)
        }
        
        if ticket_id.count == 0 {
            ticket_id.append(selected_row)
            return
        }
        
        
        collectionView.deselectItem(at: indexPath, animated: true)
        collectionView.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("nil")
    }
    
    
    //MARK: Get country code from countries json file
    func fetchJsonFromFile() {
        
        guard let path = Bundle.main.path(forResource: "country_flag_calling_code", ofType: "json") else {print("NO path found"); return}
        let url = URL(fileURLWithPath: path)
        
        ///////////////Empty article array/////////////////
        self.countryDatas = [DataOBjectClass]()
        
        do {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            
            guard let array = json as? [Any] else { return }
            for country in array {
                
                let dataObject = DataOBjectClass()
                
                guard let countryData = country as? [String: AnyObject] else {return}
                if let country_name = countryData["name"] as? String,
                    let country_isIso = countryData["isoAlpha3"] as? String,
                    let calling_code = countryData["calling_code"] as? String,
                    let currency = countryData["currency"]!["code"] as? String,
                    let currency_name = countryData["currency"]!["name"] as? String,
                    let country_flag = countryData["flag"] as? String {
                    
                    dataObject.labelText = country_name
                    dataObject.imageUrl = country_flag
                    dataObject.isIso = country_isIso
                    dataObject.countryCallCode = calling_code
                    dataObject.currency = currency
                    dataObject.currency_name = currency_name
                }
                
                self.countryDatas?.append(dataObject)
                
            }
        }catch {
            print(error)
        }
    }
}


extension AirTimeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == piker1 {
            return accountArray.count
        }
        else if pickerView == piker2 {
            return countryDatas!.count
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == piker1 {
            return accountArray[row].currency
        }
        if pickerView == piker2  {
            let cellDic = countryDatas![row]
            return cellDic.labelText
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == piker1 {
            walletTextField.text = "\(accountArray[row].currency) - Wallet"
            wallet_uid = accountArray[row].wallet_uid
            self.view.endEditing(false)
        }
        else {
            let cellDic = countryDatas![row]
            print(cellDic.countryCallCode ?? "")
            dropDownTextField.text = "+\(cellDic.countryCallCode ?? "" )"
            self.view.endEditing(false)
        }
    }
    
}




