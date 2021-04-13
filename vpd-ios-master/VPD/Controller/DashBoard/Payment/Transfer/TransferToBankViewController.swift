//
//  TransferToBankViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 26/09/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD

class TransferToBankViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var selecBankTextField: DesignableUITextField!
    @IBOutlet weak var account_nameTextField: UITextField!
    @IBOutlet weak var account_numberTextField: UITextField!
    @IBOutlet weak var makeTransferButtonOutlet: DesignableButton!
    @IBOutlet var viewWrapper: UIView!
    @IBOutlet weak var Validate_button: DesignableButton!
    @IBOutlet weak var checkBoxButton: DesignableButton!
    @IBOutlet weak var save_beneficiary_label: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    
    
    @IBOutlet weak var walletTextField: DesignableUITextField!
    
    @IBOutlet weak var searchTextField: DesignableUITextField!
    @IBOutlet weak var searchTextFieldTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchTextFieldHeightConstraint: NSLayoutConstraint!
    
    //Hide View
    @IBOutlet weak var selectWalletLabel: UILabel!
    @IBOutlet weak var viewToHide: DesignableView!
    @IBOutlet weak var accountName: UILabel!
    
    //For switch button outlets
    @IBOutlet weak var new_beneficiary: DesignableButton!
    @IBOutlet weak var existing_beneficiary: DesignableButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveBeneficiaryViewWrap: DesignableView!
    
    @IBOutlet weak var viewContraint: NSLayoutConstraint!
    
    var bank_code = ""
    var account_no = ""
    
    var wallet_id = ""
    var wallet_currency = ""
    var bank = ""
    
    
    var bankArray = [ListOfBanks]()
    var beneficiary_array = [Beneficiary]()
    var walletArray = accountArray
    
    let piker1 = UIPickerView()
    let piker2 = UIPickerView()
    
    
    var toggle = false
    var save = "0"
    var searchData = [Beneficiary]()
    var searching = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        viewWrapper.isUserInteractionEnabled = false
        
        selecBankTextField.setLeftPaddingPoints(15)
        account_nameTextField.setLeftPaddingPoints(15)
        account_numberTextField.setLeftPaddingPoints(15)
        walletTextField.setLeftPaddingPoints(15)
        searchTextField.setLeftPaddingPoints(15)
        
        selecBankTextField.delegate = self
        account_nameTextField.delegate = self
        account_numberTextField.delegate = self
        
        //makeTransferButtonOutlet.isEnabled = false
        
        piker1.dataSource = self
        piker1.delegate = self
        
        piker2.dataSource = self
        piker2.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
        
        listOfBankAPI()
        
        saveBeneficiaryViewWrap.isHidden = true
        
        selectWalletLabel.isHidden = true
        viewToHide.isHidden = true
        accountName.isHidden = true
        account_nameTextField.isHidden = true
        checkBoxButton.isHidden = true
        save_beneficiary_label.isHidden = true
        searchTextFieldHeightConstraint.constant = 0 // 45
        viewContraint.constant = 0 // 45
        
        
        
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
        toolBar.isUserInteractionEnabled = true

        selecBankTextField.inputView = piker1
        walletTextField.inputView = piker2
        
        walletTextField.inputAccessoryView = toolBar
        selecBankTextField.inputAccessoryView = toolBar
        account_numberTextField.inputAccessoryView = toolBar
        
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        account_numberTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        
        Validate_button.isUserInteractionEnabled = false
        Validate_button.backgroundColor = .lightGray
        Validate_button.setTitleColor(.darkGray, for: .normal)
        
    }
       
       //************Handles search when input text is filled************//
    @objc func textFieldDidChange(_ textField: UITextField) {
        searching = true
        let searchText = searchTextField.text
        
        searchData = beneficiary_array.filter({$0.account_name.lowercased().prefix(searchText!.count) == searchText!.lowercased()})
        
        tableView.reloadData()
        
        self.selectWalletLabel.isHidden = true
        self.viewToHide.isHidden = true
        self.accountName.isHidden = true
        self.account_nameTextField.isHidden = true
        self.checkBoxButton.isHidden =  true
        self.save_beneficiary_label.isHidden = true
        self.saveBeneficiaryViewWrap.isHidden = true
        self.viewContraint.constant = 0
        Validate_button.setTitle("Validate", for: .normal)
        
        
//        if account_numberTextField.text?.count == 10 && selecBankTextField.text != "" {
//            account_numberTextField.resignFirstResponder()
//            account_no = account_numberTextField.text!
//            validateAPI()
//        }
    }
    
 
    

    //***********Method to handle date format and date dismiss*********//
    @objc func donePicker(datePicker: UIDatePicker) {
        view.endEditing(true)
        
        if bank_code != "" && account_numberTextField.text?.count == 10 {
            Validate_button.isUserInteractionEnabled = true
            
            Validate_button.backgroundColor = UIColor(hexFromString: "#34B5CE")
            Validate_button.setTitleColor(.white, for: .normal)
        }
        else {
            Validate_button.isUserInteractionEnabled = false
            Validate_button.backgroundColor = .lightGray
            Validate_button.setTitleColor(.darkGray, for: .normal)
        }
    }
    
    
    //*********Make view move up when keyboard shows**********//
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        account_nameTextField.resignFirstResponder()
        account_numberTextField.resignFirstResponder()
        self.view.endEditing(true)
       
        return false
    }
    
    @objc func dismissPickerView(_ sender: UITapGestureRecognizer) {
        viewWrapper.endEditing(true)
    }
 
    
    
    //MARK: - Get Beneficiary API here)************************
    //++++++=========Delay function @if token is true move to next page+++++++===========//
    func getBeneficiaryAPI(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id]
        
        
        
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
        
        
        let url = "\(utililty.url)beneficiary"
        
        postToBeneficiaryAPI(url: url, parameter: parameter, token: token, header: headers)
    }
    
    
    // MARK: - NETWORK CALL- Post TO Beneficiary API
    func postToBeneficiaryAPI(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        Alamofire.request(url, method: .post, parameters: parameter, headers: header).responseJSON {
            response in
            if response.result.isSuccess {
                //print("SUCCESSFUL.....")
                
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
                    self.beneficiary_array = [Beneficiary]()
                    self.viewWrapper.isUserInteractionEnabled = true
                    self.activityIndicator.stopAnimating()
                    
                    for i in decriptorJson["response"].arrayValue {
                        
                        let new_beneficiary = Beneficiary()
                        new_beneficiary.id = i["id"].stringValue
                        new_beneficiary.account_name = i["account_name"].stringValue
                        new_beneficiary.account_number = i["account_number"].stringValue
                        new_beneficiary.bank_code = i["bank_code"].stringValue
                        new_beneficiary.save = "1"
                        new_beneficiary.bank_name = i["bank_name"].stringValue
                        
                        self.beneficiary_array.append(new_beneficiary)
                        
                    }
                }
                    
                else if (message == "Session has expired") {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.viewWrapper.isUserInteractionEnabled = true
                    self.activityIndicator.stopAnimating()
                    let alertService = AlertService()
                    let alertVC =  alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.viewWrapper.isUserInteractionEnabled = true
                self.activityIndicator.stopAnimating()
                let alertService = AlertService()
                let alertVC =  alertService.alert(alertMessage: "Network Error")
                self.present(alertVC, animated: true)
            }
            self.tableView.reloadData()
        }
    }
    
    //MARK: - DashBoard API HERE(Transaction History)************************
    //++++++=========Delay function @if token is true move to next page+++++++===========//
    func listOfBankAPI(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "SessionID": session, "CustomerID": customer_id]
        
       // print(params)
        
        
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
        
     
        let url = "\(utililty.url)list_banks"
        
        postToListOfBanks(url: url, parameter: parameter, token: token, header: headers)
    }

    
    // MARK: - NETWORK CALL- Post TO LIST OF BANKs
    func postToListOfBanks(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        self.activityIndicator.startAnimating()
        self.viewWrapper.isUserInteractionEnabled = false
        
        Alamofire.request(url, method: .post, parameters: parameter, headers: header).responseJSON {
            response in
            if response.result.isSuccess {
                //print("SUCCESSFUL.....")
                
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
                
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                
                
                if(status) {
                    self.bankArray = [ListOfBanks]()
                    
                    for i in decriptorJson["response"].arrayValue {

                        let bank_list = ListOfBanks()

                        bank_list.bank_name = i["bank_name"].stringValue
                        bank_list.id = i["id"].stringValue
                        bank_list.bank_code = i["bank_code"].stringValue
                        bank_list.logo = i["logo"].stringValue
                        bank_list.iso3 = i["iso3"].stringValue

                        self.bankArray.append(bank_list)

                    }
                }
                    
                else if (message == "Session has expired") {
                    let alertService = AlertService()
                    let alertVC =  alertService.alert(alertMessage: "Session has expired")
                    self.present(alertVC, animated: true)
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.viewWrapper.isUserInteractionEnabled = true
                    self.activityIndicator.stopAnimating()
                    let alertService = AlertService()
                    let alertVC =  alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.viewWrapper.isUserInteractionEnabled = true
                self.activityIndicator.stopAnimating()
                let alertService = AlertService()
                let alertVC =  alertService.alert(alertMessage: "Network Error")
                self.present(alertVC, animated: true)
            }
            self.getBeneficiaryAPI()
        }
    }
    
    
    
    //MARK: - Validate Bank Acount************************
    func validateAPI(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "SessionID": session, "CustomerID": customer_id, "bank_code": bank_code, "account_no": account_no]
        
        
        
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
        
     
        
        let url = "\(utililty.url)account_query"
        
        postForValidate(url: url, parameter: parameter, token: token, header: headers)
    }

    
    // MARK: - NETWORK CALL- Post TO LIST OF BANKs
    func postForValidate(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        self.activityIndicator.startAnimating()
        
        Alamofire.request(url, method: .post, parameters: parameter, headers: header).responseJSON {
            response in
            if response.result.isSuccess {
                //print("SUCCESSFUL.....")
                
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
                    self.viewWrapper.isUserInteractionEnabled = true
                    self.selectWalletLabel.isHidden = false
                    self.viewToHide.isHidden = false
                    self.accountName.isHidden = false
                    self.account_nameTextField.isHidden = false
                    self.checkBoxButton.isHidden = false
                    self.save_beneficiary_label.isHidden = false
                    self.saveBeneficiaryViewWrap.isHidden = false
                    self.viewContraint.constant = 45
                    self.activityIndicator.stopAnimating()
                    
                    self.account_nameTextField.text = decriptorJson["response"]["field"].stringValue
                    
                    
                    self.Validate_button.setTitle("Make Transfer", for: .normal)
                }
                    
                else if (message == "Session has expired") {                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.viewWrapper.isUserInteractionEnabled = true
                    self.activityIndicator.stopAnimating()
                    let alertService = AlertService()
                    let alertVC =  alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.viewWrapper.isUserInteractionEnabled = true
                self.activityIndicator.stopAnimating()
                let alertService = AlertService()
                let alertVC =  alertService.alert(alertMessage: "Network Error")
                self.present(alertVC, animated: true)
              
            }
       
        }
    }
    
    

    //MARK:- IBACTIONs
    @IBAction func switchButtonPressed(_ sender: UIButton) {
        new_beneficiary.isUserInteractionEnabled = false
        if sender.tag == 1 {
            
            new_beneficiary.backgroundColor = .white
            new_beneficiary.setTitleColor(.black, for: .normal)
            
            existing_beneficiary.backgroundColor = .clear
            existing_beneficiary.setTitleColor(.darkGray, for: .normal)
            
            tableView.isHidden = true
            searchTextField.isHidden = true
            searchTextFieldTopConstraint.constant = 0 // 12
            searchTextFieldHeightConstraint.constant = 0 // 45
            self.Validate_button.isHidden = false
            
            viewContraint.constant = 0 // 45
            Validate_button.setTitle("Validate", for: .normal)
            
            if bank_code != "" && account_numberTextField.text != "" {
               
                Validate_button.isUserInteractionEnabled = true
                Validate_button.backgroundColor = UIColor(hexFromString: "#34B5CE")
                Validate_button.setTitleColor(.white, for: .normal)
            }
            else {
                Validate_button.isUserInteractionEnabled = false
                Validate_button.backgroundColor = .lightGray
                Validate_button.setTitleColor(.darkGray, for: .normal)
            }
            
        }
        else {
            
            new_beneficiary.isUserInteractionEnabled = true
            existing_beneficiary.backgroundColor = .white
            existing_beneficiary.setTitleColor(.black, for: .normal)
            
            new_beneficiary.backgroundColor = .clear
            new_beneficiary.setTitleColor(.darkGray, for: .normal)
            
            tableView.isHidden = false
            searchTextField.isHidden = false
            searchTextFieldTopConstraint.constant = 12 // 12
            searchTextFieldHeightConstraint.constant = 45 // 45
            
            self.selectWalletLabel.isHidden = true
            self.viewToHide.isHidden = true
            self.accountName.isHidden = true
            self.account_nameTextField.isHidden = true
            self.checkBoxButton.isHidden = true
            self.save_beneficiary_label.isHidden = true
            self.saveBeneficiaryViewWrap.isHidden = true
            self.Validate_button.isHidden = true
            self.view.endEditing(true)
        }
    }
    
    @IBAction func dropDownPressed(_ sender: Any) {
        selecBankTextField.becomeFirstResponder()
    }
    
    @IBAction func dropDownPressed2(_ sender: Any) {
        walletTextField.becomeFirstResponder()
    }
    
    @IBAction func makeTransferButtonPressed() {
        
        account_no = account_numberTextField.text!
      
        if Validate_button.titleLabel?.text == "Make Transfer" {
            if wallet_id == "" {
                let alertService = AlertService()
                let alertVC =  alertService.alert(alertMessage: "Please Select Wallet currency")
                self.present(alertVC, animated: true)
                return
            }
            else {
                performSegue(withIdentifier: "goToTransferVPD", sender: self)
            }
        }
        else {
            validateAPI()
        }
    }
    
    
    //MARK: - Check box
    @IBAction func checkBoxButtonPressed(_ sender: Any) {
        toggle = !toggle
        
        if toggle {
            checkBoxButton.setBackgroundImage(UIImage(named: "check-symbol"), for: .normal)
            save = "1"
        }
        else {
            checkBoxButton.setBackgroundImage(UIImage(named: ""), for: .normal)
            save = "0"
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! PaymentLinkViewController
        
        destination.segue_bank_code = bank_code
        destination.segue_accountNumber = account_no
        destination.walletID = wallet_id
        destination.from_segue = "transfer"
        destination.save = save
    }
    
    @IBAction func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - TRANSACTION HISTORY
extension TransferToBankViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searching ? searchData.count : beneficiary_array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TransactionTableViewCell
        
        cell.selectionStyle = .none
        
        if searching {
            //******Remove styling from selected cell
            let dictionary = searchData[indexPath.row]
            
            cell.memo.text = dictionary.account_name
            cell.thumbnail_image?.image = UIImage(named: "bank")
            cell.trasaction_id.text = dictionary.account_number
            cell.amount.text = dictionary.bank_name
        }
        else {
            //******Remove styling from selected cell
            let dictionary = beneficiary_array[indexPath.row]
            cell.memo.text = dictionary.account_name
            cell.thumbnail_image?.image = UIImage(named: "bank")
            cell.trasaction_id.text = dictionary.account_number
            cell.amount.text = dictionary.bank_name
        }
        return cell
    }
    
    
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        
        print("i was clicked")
        Validate_button.isUserInteractionEnabled = true
        new_beneficiary.isUserInteractionEnabled = false
        
        Validate_button.backgroundColor = UIColor(hexFromString: "#34B5CE")
        Validate_button.setTitleColor(.white, for: .normal);
        
        self.viewContraint.constant = 45
        
        if searching {
            let selected_row = searchData[indexPath.row]
            
            account_nameTextField.text = selected_row.account_name
            checkBoxButton.setBackgroundImage(UIImage(named: "check-symbol"), for: .normal)
            account_numberTextField.text = selected_row.account_number
            selecBankTextField.text = selected_row.bank_name
            bank_code = selected_row.bank_code
            
        }
        else {
            let selected_row = beneficiary_array[indexPath.row]
            
            account_nameTextField.text = selected_row.account_name
            checkBoxButton.setBackgroundImage(UIImage(named: "check-symbol"), for: .normal)
            account_numberTextField.text = selected_row.account_number
            selecBankTextField.text = selected_row.bank_name
            bank_code = selected_row.bank_code
        }
        

        new_beneficiary.backgroundColor = .white
        new_beneficiary.setTitleColor(.black, for: .normal)


        tableView.isHidden = true
        searchTextField.isHidden = true
        searchTextFieldTopConstraint.constant = 0 // 12
        searchTextFieldHeightConstraint.constant = 0 // 45

        self.selectWalletLabel.isHidden = false
        self.viewToHide.isHidden = false
        self.accountName.isHidden = false
        self.account_nameTextField.isHidden = false
        self.checkBoxButton.isHidden = false
        self.save_beneficiary_label.isHidden = false
        self.saveBeneficiaryViewWrap.isHidden = false
        self.Validate_button.setTitle("Make Transfer", for: .normal)
        self.Validate_button.isHidden = false
        existing_beneficiary.backgroundColor = .clear
        existing_beneficiary.setTitleColor(.darkGray, for: .normal)

    }
}


extension TransferToBankViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == piker1 {
            return bankArray.count
        }
        else if pickerView == piker2 {
            return walletArray.count
        }
         return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == piker1 {
            return bankArray[row].bank_name
        }
        else if pickerView == piker2{
            
            return walletArray[row].currency
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == piker1 {
            bank_code = bankArray[row].bank_code
            selecBankTextField.text = bankArray[row].bank_name
        }
        
        else if pickerView == piker2 {
            
            wallet_id = walletArray[row].wallet_uid
            walletTextField.text = walletArray[row].currency
        }
    
    }
    
    
    func creatPicker() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        
        selecBankTextField.inputView = pickerView
    }
}






