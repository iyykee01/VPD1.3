//
//  ASSFScreen3ViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 26/06/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit
import SwiftyJSON

class ASSFScreen3ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: DesignableUITextField!
    @IBOutlet weak var dayTextField: DesignableUITextField!
    @IBOutlet weak var monthTextField: DesignableUITextField!
    @IBOutlet weak var yearTextField: DesignableUITextField!
    @IBOutlet weak var phoneNumberTextField: DesignableUITextField!
    @IBOutlet weak var EmailTextField: DesignableUITextField!
    @IBOutlet weak var addressTextField: DesignableUITextField!
    @IBOutlet weak var LGATextField: DesignableUITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var checkBoxButton: UIButton!
    let piker1 = UIPickerView()
    
    var LGAArray = [States]()
  
    var phone = ""
    
    var checkBoxValue = false
    var name = ""
    var dob = ""
    var phonenumber = ""
    var email = ""
    var address = ""
    var lga = ""
    var lga_id = ""
    var date = ""
    
    private var datePicker: UIDatePicker?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        nameTextField.setLeftPaddingPoints(14)
        //phoneNumberTextField.setLeftPaddingPoints(14)
        EmailTextField.setLeftPaddingPoints(14)
        addressTextField.setLeftPaddingPoints(14)
        LGATextField.setLeftPaddingPoints(14)
        
        nameTextField.delegate = self
        dayTextField.delegate = self
        monthTextField.delegate = self
        yearTextField.delegate = self
        phoneNumberTextField.delegate = self
        EmailTextField.delegate = self
        addressTextField.delegate = self
        LGATextField.delegate = self
        
        LGATextField.delegate = self
        
        piker1.dataSource = self
        piker1.delegate = self
        
        LGATextField.inputView = piker1
        
        //***********Setting up Date Picker********************//
        datePicker = UIDatePicker()
        let calendar = Calendar(identifier: .gregorian)

        let currentDate = Date()
        var components = DateComponents()
        components.calendar = calendar

        components.year = -18
        components.month = 12
        let maxDate = calendar.date(byAdding: components, to: currentDate)!

        components.year = -150
        let minDate = calendar.date(byAdding: components, to: currentDate)!

        datePicker?.minimumDate = minDate
        datePicker?.maximumDate = maxDate
        
        
        datePicker?.datePickerMode = .date
        
        datePicker?.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        
        phoneNumberTextField.addTarget(self, action: #selector(removeZero), for: UIControl.Event.editingChanged)
        
        configToolBar()
        networkCallToLga()
        dayTextField.inputView = datePicker
        monthTextField.inputView = datePicker
        yearTextField.inputView = datePicker
    }
    
    //MARK: - Set up tool bar
    func configToolBar() {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.donePicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false);
        
        phoneNumberTextField.inputAccessoryView = toolBar;
        dayTextField.inputAccessoryView = toolBar;
        monthTextField.inputAccessoryView = toolBar;
        yearTextField.inputAccessoryView = toolBar;
    }
    
    //MARK: functionality for done
    @objc func donePicker() {
        view.endEditing(true)
    }
    
    //***********Method to handle date format and date dismiss*********//
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        date = dateFormatter.string(from: datePicker.date)
        
        let splited_date = date.split(separator: "-");
        
        dayTextField.text = String(splited_date[0]);
        monthTextField.text = String(splited_date[1]);
        yearTextField.text = String(splited_date[2]);
        
    }
    
    //**********Remove User Zero **********//
    @objc func removeZero() {
        if (self.phoneNumberTextField.text?.hasPrefix("0"))! {
            self.phoneNumberTextField.text?.remove(at:(self.phoneNumberTextField.text?.startIndex)!)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
    
    @IBAction func checkBoxButtonPressed(_ sender: Any) {
        checkBoxValue.toggle()
        if checkBoxValue {
            checkBoxButton.setImage(UIImage(named: "check-symbol"), for: .normal)
        }
        else {
            checkBoxButton.setImage(UIImage(named: ""), for: .normal)
        }
    }
    
    //MARK: Make network request
    func networkCallToLga() {
        
        activityIndicator.startAnimating()
        
        
        let utililty = UtilClass()
        let device = utililty.getPhoneId()
        
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "country_iso3": "NGA", ]
        
        
        
        utililty.delayToNextPage(params: params, path: "country_lga") { result in
            switch result {
            case .failure(let error):
                self.activityIndicator.stopAnimating()
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Please check that you have internet connection")
                self.present(alertVC, animated: true)
                
                print(error)
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
                //print(decriptorJson)
                
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                
                if(status) {
                    self.activityIndicator.stopAnimating()
                    self.LGAArray = [States]()
                    
                    for i in decriptorJson["response"]["Abia State"].arrayValue {

                        let lga = States()

                        lga.id = i["id"].stringValue
                        lga.name = i["name"].stringValue
                        
                        self.LGAArray.append(lga)
                    }
                    
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
    
   
    
    //check-symbol
    @IBAction func nextButtonPressed(_ sender: Any) {
        
        let utility = UtilClass();
        if nameTextField.text == "" || dayTextField.text == "" || monthTextField.text == "" ||  yearTextField.text == "" ||  phoneNumberTextField.text == "" || EmailTextField.text == "" ||  addressTextField.text == ""  {
            //Show alert here
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "Please fill all fields")
            self.present(alertVC, animated: true)
            return
        }

        //Verify Email Address
        if !utility.isValidEmail(EmailTextField.text!) {
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "Invalid email address")
            self.present(alertVC, animated: true)
            return
        }

        else {
            name = nameTextField.text!
            dob = "\(yearTextField.text!)-\(monthTextField.text!)-\(dayTextField.text!)"
            phonenumber = "+234\(phoneNumberTextField.text!)"
            email = EmailTextField.text!
            address = addressTextField.text!
            lga = lga_id
            performSegue(withIdentifier: "goNext", sender: self)
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goNext" {
            let destination = segue.destination as! ASSFScreen4ViewController
            
            destination.name = name
            destination.dob = dob
            destination.phonenumber = phonenumber
            destination.email = email
            destination.address = address
            destination.lga_id = lga
        }
    }
}


extension ASSFScreen3ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return LGAArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return LGAArray[row].name

    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        LGATextField.text = LGAArray[row].name
        lga_id = LGAArray[row].id
        
        self.view.endEditing(true)


    }
    
}

    
