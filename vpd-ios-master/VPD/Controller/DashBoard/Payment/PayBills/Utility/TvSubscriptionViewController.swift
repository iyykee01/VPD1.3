//
//  TvSubscriptionViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 02/10/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class TvSubscriptionViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var viewWrapper: UIView!
    @IBOutlet weak var viewToHide: UIView!
    @IBOutlet weak var tvProviderTextField: UITextField!
    @IBOutlet weak var smartCardNumberTextField: UITextField!
    @IBOutlet weak var tvPlanTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var buyUsingWallet: UILabel!
    
    @IBOutlet weak var walletTextField: DesignableUITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var amountTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var amountHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var amountButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var amountLable: UILabel!
    @IBOutlet weak var amountTextField: DesignableUITextField!
    @IBOutlet weak var tvPlanView: DesignableView!
    @IBOutlet weak var buyUsingWalletView: DesignableView!
    @IBOutlet weak var buyUsingWalletHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buyUsingWalletBottomConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var  vpdWalletHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var tvProvider: UILabel!
    @IBOutlet weak var smartcard: UILabel!
    @IBOutlet weak var accountname: UILabel!
    @IBOutlet weak var tvPlan: UILabel!
    @IBOutlet weak var tvPlan2: UILabel!
    @IBOutlet weak var tvplanContrainst: NSLayoutConstraint!
    @IBOutlet weak var tvPlanButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var nextButtonConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var vpdPinTextLabel: UILabel!
    @IBOutlet weak var vpdPinTextField: UITextField!
    @IBOutlet weak var scrollToScroll: UIScrollView!
    @IBOutlet weak var convenienceFeeLabel: UILabel!
    
    //StorProviders
    var storeProviders = [TVSubscription]()
    
    
    var tv_sub_plan = [DataPlan]()
    var walletId = ""
    var provider_id = ""
    var card_number = ""
    var caller = 0
    var product_List = false
    var vpdPin = ""
    var transaction_face = face
    
    var message = ""
    var fee_for_trans = LoginResponse["response"]["charges"]["tv_convenience_fee"]["NGN"]["value"].stringValue
    
    var banks = ["First Bank", "Access Bank"]
    
    
    let piker1 = UIPickerView()
    let piker2 = UIPickerView()
    let piker3 = UIPickerView()
    
    var distributor_id  = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        convenienceFeeLabel.text = "You'll be charged NGN\(fee_for_trans) convenience fee for this."
        
        viewWrapper.isUserInteractionEnabled = false
        viewToHide.isHidden = true
        tvPlan2.isHidden  = true
        tvPlanTextField.isHidden = true
        walletTextField.isHidden = true
        buyUsingWallet.isHidden = true
        tvPlanView.isHidden = true
        buyUsingWalletView.isHidden = true
        
        // For amount
        
        amountLable.isHidden = true
        amountButtonConstraint.constant = 0 // 25
        amountTopConstraint.constant = 0 // 25
        amountTextField.isHidden = true
        amountHeightConstraint.constant = 0 //45
        tvplanContrainst.constant = 0 // 45
        buyUsingWalletHeightConstraint.constant = 0 // 45
        //buyUsingWalletBottomConstraint.constant = 0 // 20
        nextButtonConstraint.constant = 300 // 30
        
        // Do any additional setup after loading the view.
        tvProviderTextField.setLeftPaddingPoints(15)
        smartCardNumberTextField.setLeftPaddingPoints(15)
        tvPlanTextField.setLeftPaddingPoints(15)
        walletTextField.setLeftPaddingPoints(15)
        vpdPinTextField.setLeftPaddingPoints(14)
        
        tvProviderTextField.delegate = self
        smartCardNumberTextField.delegate = self
        tvPlanTextField.delegate = self
        vpdPinTextField.delegate = self
        
        
        nextButton.isEnabled = false
        
        piker1.dataSource = self
        piker1.delegate = self
        
        piker2.dataSource = self
        piker2.delegate = self
        
        piker3.dataSource = self
        piker3.delegate = self
        
        
        //print("\(tv_subscription)....from aTV")
        getProvidersAPI()
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.donePicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false);
        
        vpdPinTextField.inputAccessoryView = toolBar;
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        tvPlanTextField.inputView = piker1
        tvProviderTextField.inputView = piker2
        walletTextField.inputView = piker3
    }
    
    @objc func donePicker() {
        vpdPin = vpdPinTextField.text!
        view.endEditing(true)
        view.frame.origin.y = 0
    }
    
    @objc func keyboardwillChange(notification: Notification) {
        
        guard   let userInfo = notification.userInfo as? [String: NSObject],
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect  else { return }
        
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification  {
            view.frame.origin.y = -keyboardFrame.height / 5.0
        }
        else {
            view.frame.origin.y = 0
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1 {
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    
        
        if !tvProviderTextField.text!.isEmpty && !smartCardNumberTextField.text!.isEmpty && !tvPlanTextField.text!.isEmpty {
           
            nextButton.backgroundColor = UIColor(hexFromString: "#34B5CE")
            nextButton.setTitleColor(.white, for: .normal)
            nextButton.isEnabled = true
            
            
            tvPlan.text = tvPlanTextField.text
            smartcard.text = smartCardNumberTextField.text
            
        }
        else {
        
            nextButton.backgroundColor = .lightGray
            nextButton.titleLabel?.textColor = .darkGray
            nextButton.isEnabled = false
        }
    }
    
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //tvPlanTextField.endEditing(true)
        smartCardNumberTextField.endEditing(true)
        
        if smartCardNumberTextField.text != "" && tvProviderTextField.text != "Select TV provider"  {
            callTvSubAPI()
        }
        return false
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    func getProvidersAPI(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "type": "tvsubscription", "operation": "getproviders"]
        
        
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
        
        
        
        let url = "\(utililty.url)bill_payment"
        
        tvSubAPI(url: url, parameter: parameter, token: token, header: headers)
    }
    
    
    
    ///////////***********Post Data MEthod*********////////
    func tvSubAPI(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        self.activityIndicator.startAnimating()
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
                    
                    self.activityIndicator.stopAnimating()
                    self.viewWrapper.isUserInteractionEnabled = true
                    //********Response from server *******//
                    self.storeProviders = [TVSubscription]()
                    for i in decriptorJson["response"].arrayValue {
                        let tv_subscription = TVSubscription()
                        
                        tv_subscription.none = ""
                        tv_subscription.currency = i["currency"].stringValue
                        tv_subscription.id = i["id"].stringValue
                        tv_subscription.name = i["name"].stringValue
                        tv_subscription.productList = i["productList"].boolValue
                        tv_subscription.validation = i["validation"].boolValue
                        
                        self.storeProviders.append(tv_subscription)
                    }
                    
                }
                    
                else if (message == "Session has expired") {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    
                    ////From the alert Service
                    self.activityIndicator.stopAnimating()
                    self.viewWrapper.isUserInteractionEnabled = true
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                    
                }
            }
            else {
                self.activityIndicator.stopAnimating()
                self.viewWrapper.isUserInteractionEnabled = true
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
                
            }
        }
    }
    
    
    func callTvSubAPI(){
        
        card_number = smartCardNumberTextField.text!
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "type": "tvsubscription", "operation": "validate", "provider": provider_id,
                      "number": card_number]
        
        
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
        
        
        let url = "\(utililty.url)bill_payment"
        
        postData(url: url, parameter: parameter, token: token, header: headers)
    }
    
    //MARK - VALIDATE
    ///////////***********Post Data MEthod*********////////
    func postData(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        self.activityIndicator.startAnimating()
        self.viewWrapper.isUserInteractionEnabled = false
        
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
                    self.activityIndicator.stopAnimating()
                    self.viewWrapper.isUserInteractionEnabled = true
                    
                    
                    let user_name = decriptorJson["response"]["name"].stringValue
                    let split_username = user_name.split(separator: "-")
                    self.accountname.text = String(split_username[0])
                    
                    let productlist = self.product_List
                    print(productlist)
                    self.getPlan()
                    if productlist {
                        self.getPlan()
                    }
                        
                    else if  message == "Session has expired" {
                        self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                    }
                        
                    else {
                        self.amountTopConstraint.constant = 25
                        self.amountButtonConstraint.constant = 25
                        self.amountLable.isHidden = false
                        self.amountTextField.isHidden = false
                        self.amountHeightConstraint.constant = 45
                        self.tvplanContrainst.constant = 0 // 45
                        self.walletTextField.isHidden = false
                        self.buyUsingWallet.isHidden = false
                        self.tvPlanView.isHidden = false
                        
                        
                    }
                }
                else {
                    self.activityIndicator.stopAnimating()
                    self.viewWrapper.isUserInteractionEnabled = true
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.activityIndicator.stopAnimating()
                self.viewWrapper.isUserInteractionEnabled = true
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    //MARK: -  getPlan
    func getPlan(){
        
        card_number = smartCardNumberTextField.text!
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "type": "tvsubscription", "operation": "getplans", "provider": provider_id]
        
        
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
        
        
        let url = "\(utililty.url)bill_payment"
        
        postData2(url: url, parameter: parameter, token: token, header: headers)
    }
    
    ///////////***********Post Data MEthod*********////////
    func postData2(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        self.activityIndicator.startAnimating()
        self.viewWrapper.isUserInteractionEnabled = false
        
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
                    self.activityIndicator.stopAnimating()
                    self.viewWrapper.isUserInteractionEnabled = true
                    self.tvPlan2.isHidden  = false
                    self.tvPlanView.isHidden = false
                    self.tvPlanTextField.isHidden = false
                    self.walletTextField.isHidden = false
                    self.buyUsingWallet.isHidden = false
                    self.buyUsingWalletView.isHidden = false
                    self.tvplanContrainst.constant = 45
                    self.buyUsingWalletHeightConstraint.constant = 45
                    self.scrollToScroll.isScrollEnabled = true
                    self.nextButtonConstraint.constant = 30
                    //self.buyUsingWalletBottomConstraint.constant = 20
                    
                    self.vpdPinTextLabel.isHidden = false
                    self.vpdPinTextField.isHidden = false
                    
                    let dataFromServer = decriptorJson["response"].arrayValue
                    
                    for i in dataFromServer {
                        let new_data_plan = DataPlan()
                        
                        new_data_plan.id = i["id"].stringValue
                        new_data_plan.name = i["name"].stringValue
                        new_data_plan.price = i["price"].stringValue
                        
                        self.tv_sub_plan.append(new_data_plan)
                    }
                    
                }
                    
                else if  message == "Session has expired" {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.activityIndicator.stopAnimating()
                    self.viewWrapper.isUserInteractionEnabled = true
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.activityIndicator.stopAnimating()
                self.viewWrapper.isUserInteractionEnabled = true
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        
        vpdPin = vpdPinTextField.text!
        
        if nextButton.isEnabled {
            viewToHide.isHidden = false
            nextButton.setTitle("Subscribe", for: .normal)
        }
        
        if  walletId == "" {
            let alertService = AlertService()
            let alertVC =  alertService.alert(alertMessage: "Please Select Wallet currency")
            self.present(alertVC, animated: true)
            return
        }

        
        
        if nextButton.titleLabel?.text == "Subscribe" && vpdPin != ""{
            print("performing a segue")
            if transaction_face && isUserFace == false {
                let alertSV = FaceID()
                let alert = alertSV.showFaceID()
                self.present(alert, animated: true)
            }
            else {
                makePayment()
            }
        }
        
//        if amountTextField.text != "" {
//            makePayment()
//        }
    }
    
    
    
    
    
    var price = ""
    var plan_id = ""
    
    //MARK: - Make Payment
    func makePayment(){
        
        card_number = smartCardNumberTextField.text!
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
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "type": "tvsubscription", "operation": "purchase", "provider": provider_id,
                      "wallet": walletId, "number": card_number, "amount": price, "plan": plan_id, "transaction_pin": vpdPin, "auth_key": global_key]
        
        
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
        
        
        let url = "\(utililty.url)bill_payment"
        
        postData3(url: url, parameter: parameter, token: token, header: headers)
        global_key = ""
        isUserFace = false
    }
    
    ///////////***********Post Data MEthod*********////////
    func postData3(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        self.activityIndicator.startAnimating()
        self.viewWrapper.isUserInteractionEnabled = false
        
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
                    self.activityIndicator.stopAnimating()
                    self.viewWrapper.isUserInteractionEnabled = true
                    self.message = message
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
                    self.activityIndicator.stopAnimating()
                    self.viewWrapper.isUserInteractionEnabled = true
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.activityIndicator.stopAnimating()
                self.viewWrapper.isUserInteractionEnabled = true
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    
    @IBAction func dropDownButtonPressed (_ sender: UIButton){
        if sender.tag == 1 {
            tvProviderTextField.becomeFirstResponder()
        }
        else if sender.tag == 2 {
            tvPlanTextField.becomeFirstResponder()
        }
        else {
            walletTextField.becomeFirstResponder()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! FailedControllerViewController
        destination.from_segue = message
    }
    
}


extension TvSubscriptionViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == piker1 {
            return tv_sub_plan.count
        }
        else if pickerView == piker2{
            return storeProviders.count
        }
            
        else if pickerView == piker3 {
            return accountArray.count
        }
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == piker1 {
            return tv_sub_plan[row].name
        }
        else if pickerView == piker2{
            return storeProviders[row].name
        }
        else if pickerView == piker3 {
            return accountArray[row].currency
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == piker1 {
            tvPlanTextField.text = tv_sub_plan[row].name
            distributor_id = tv_sub_plan[row].id
            price = tv_sub_plan[row].price
            plan_id = tv_sub_plan[row].id
            
        }
            
        else if pickerView == piker2 {
            tvProviderTextField.text = storeProviders[row].name
            provider_id = storeProviders[row].id
            product_List = storeProviders[row].productList
            tvProvider.text = tvProviderTextField.text
            
            if smartCardNumberTextField.text != "" && tvProviderTextField.text != "Select TV provider"  {
                self.view.endEditing(true)
                callTvSubAPI()
            }
        }
            
        else if pickerView == piker3 {
            walletTextField.text = "\(accountArray[row].currency) - Wallet"
            walletId = accountArray[row].wallet_uid
            
        }
        self.view.endEditing(true)
    }
    
}

