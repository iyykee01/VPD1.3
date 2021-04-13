//
//  EditProfileViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 22/08/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SDWebImage

class EditProfileViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    
    @IBOutlet weak var genderButtonMale: UIButton!
    @IBOutlet weak var genderButtonFemale: UIButton!
    
    
    @IBOutlet weak var maritalstatusTextField: UITextField!
    @IBOutlet weak var occupationTextfield: UITextField!
    @IBOutlet weak var DOBLabel: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var BVNTextField: UITextField!
    @IBOutlet weak var buildingNoTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var NearestBusstopTextField: UITextField!
    @IBOutlet weak var townTextField: UITextField!
    @IBOutlet weak var postalCodeTextField: UITextField!
    @IBOutlet weak var stateOfOriginTextField: UITextField!
    @IBOutlet weak var nationalityTextField: UITextField!
    @IBOutlet weak var cancel_saveButton: DesignableButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
   
    @IBOutlet weak var viewHieghtConstraints: NSLayoutConstraint!
    
    var globalImage: UIImage!
    
    //*******Initializing array to be populated**********//
    var countryDatas: [DataOBjectClass]?  = []
    
    var selectedField: String?
    var selected = ""
    
    var message = ""
    
    var resident = ""
    var state = ""
    var country = ""
    var city = ""
    var taken_image = false
    var gender = ""
    
    
    let imagePicker = UIImagePickerController()
    var imageBase64String: String = ""
    
    
    var profile = Profile["response"]
     var user_number = Profile["response"]["phone"].stringValue
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        
        addressTextField.delegate = self
        nationalityTextField.delegate = self
        NearestBusstopTextField.delegate = self
        buildingNoTextField.delegate = self
        titleTextField.delegate = self
        maritalstatusTextField.delegate = self
        occupationTextfield.delegate = self
        postalCodeTextField.delegate = self
        stateOfOriginTextField.delegate = self
        townTextField.delegate = self
        firstnameTextField.setLeftPaddingPoints(14)
        
        set_upTextFileds()
        
        
        let base64_image = profile["photo"].stringValue
     
        profileImage!.sd_setImage(with: URL(string: base64_image), placeholderImage: UIImage(named: ""))
        
        firstnameTextField.text = user_number
        
        fullnameLabel.text = profile["name"].stringValue
        DOBLabel.text = profile["dob"].stringValue
        emailLabel.text = profile["email"].stringValue
        BVNTextField.placeholder = profile["bvn"].stringValue
        maritalstatusTextField.text = profile["marital_status"].stringValue
        nationalityTextField.text = profile["country"].stringValue
        occupationTextfield.text = profile["occupation"].stringValue
        townTextField.text = profile["town"].stringValue
        stateOfOriginTextField.text = profile["stateoforigin"].stringValue
        
        titleTextField.text = profile["title"].stringValue
        buildingNoTextField.text = profile["buildingno"].stringValue
        addressTextField.text = profile["address"].stringValue
        NearestBusstopTextField.text = profile["bus_stop"].stringValue
        postalCodeTextField.text = profile["postalcode"].stringValue
        
        
        
        
        //var name = profile["name"].stringValue.split(separator: " ")
        
//        firstnameTextField.text = profile["name"].stringValue.split(separator: " ")[1]
//        
//        lastnameTextField.text = profile["name"].stringValue.split(separator: " ")[0]
        
        if profile["gender"].stringValue == "M" {
            genderButtonMale.setTitleColor(.white, for: .normal)
            genderButtonMale.backgroundColor = UIColor(hexFromString: "#34B5CE")
            return
        }
        if profile["gender"].stringValue == "F" {
            genderButtonFemale.setTitleColor(.white, for: .normal)
            genderButtonFemale.backgroundColor = UIColor(hexFromString: "#34B5CE")
            return
        }

        
        
        
        
        //MARK: - Data representation from screen
//        let name = profile["name"].stringValue.split(separator: " ")
//        firstnameTextField.text = String(name[0])
//        lastnameTextField.text = String(name[1])
        nationalityTextField.text = Profile["response"]["country"].stringValue
        
        
        fetchJsonFromFile()
        creatPicker()
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            taken_image = true
            
            profileImage.image = image
            
            
            globalImage = image
            
            let imageData: Data? = image.jpegData(compressionQuality: 0.4)
            let imageStr = imageData?.base64EncodedString(options: .lineLength64Characters) ?? ""
            
            imageBase64String = imageStr

            
            cancel_saveButton.setTitle("Save", for: .normal)
            
            imagePicker.dismiss(animated: true, completion: nil)
            
        }else {
            print("No image found")
        }
    }
    
    
    func set_upTextFileds() {
        titleTextField.setLeftPaddingPoints(14)
        //firstnameTextField.setLeftPaddingPoints(14)
        DOBLabel.setLeftPaddingPoints(14)
        //lastnameTextField.setLeftPaddingPoints(14)
        maritalstatusTextField.setLeftPaddingPoints(14)
        occupationTextfield.setLeftPaddingPoints(14)
        BVNTextField.setLeftPaddingPoints(14)
        postalCodeTextField.setLeftPaddingPoints(14)
        stateOfOriginTextField.setLeftPaddingPoints(14)
        buildingNoTextField.setLeftPaddingPoints(14)
        addressTextField.setLeftPaddingPoints(14)
        nationalityTextField.setLeftPaddingPoints(14)
        NearestBusstopTextField.setLeftPaddingPoints(14)
        townTextField.setLeftPaddingPoints(14)
        
        
        titleTextField.layer.cornerRadius = 12
        titleTextField.layer.borderWidth = 0.5
        titleTextField.layer.borderColor = UIColor(hexFromString: "#9A9A9A").cgColor
        
        DOBLabel.layer.cornerRadius = 12
        DOBLabel.layer.borderWidth = 0.5
        DOBLabel.layer.borderColor = UIColor(hexFromString: "#9A9A9A").cgColor
        
        
        maritalstatusTextField.layer.cornerRadius = 12
        maritalstatusTextField.layer.borderWidth = 0.5
        maritalstatusTextField.layer.borderColor = UIColor(hexFromString: "#9A9A9A").cgColor
        
        occupationTextfield.layer.cornerRadius = 12
        occupationTextfield.layer.borderWidth = 0.5
        occupationTextfield.layer.borderColor = UIColor(hexFromString: "#9A9A9A").cgColor
        
        BVNTextField.layer.cornerRadius = 12
        BVNTextField.layer.borderWidth = 0.5
        BVNTextField.layer.borderColor = UIColor(hexFromString: "#9A9A9A").cgColor
        
        postalCodeTextField.layer.cornerRadius = 12
        postalCodeTextField.layer.borderWidth = 0.5
        postalCodeTextField.layer.borderColor = UIColor(hexFromString: "#9A9A9A").cgColor
        
        stateOfOriginTextField.layer.cornerRadius = 12
        stateOfOriginTextField.layer.borderWidth = 0.5
        stateOfOriginTextField.layer.borderColor = UIColor(hexFromString: "#9A9A9A").cgColor
        print(profile)
        
        
        buildingNoTextField.layer.cornerRadius = 12
        buildingNoTextField.layer.borderWidth = 0.5
        buildingNoTextField.layer.borderColor = UIColor(hexFromString: "#9A9A9A").cgColor
        
        
        addressTextField.layer.cornerRadius = 12
        addressTextField.layer.borderWidth = 0.5
        addressTextField.layer.borderColor = UIColor(hexFromString: "#9A9A9A").cgColor
        
        
        NearestBusstopTextField.layer.cornerRadius = 12
        NearestBusstopTextField.layer.borderWidth = 0.5
        NearestBusstopTextField.layer.borderColor = UIColor(hexFromString: "#9A9A9A").cgColor
        
        
        townTextField.layer.cornerRadius = 12
        townTextField.layer.borderWidth = 0.5
        townTextField.layer.borderColor = UIColor(hexFromString: "#9A9A9A").cgColor
    }
    
    
    
    
    //++++++=========Delay function @if token is true move to next page+++++++===========//
    func delayToNextPageProfile(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        
        let occupation = occupationTextfield.text
        let maritalstatus = maritalstatusTextField.text
        let title = titleTextField.text
        let buildingNo = buildingNoTextField.text
        let town = townTextField.text
        let bus_stop = NearestBusstopTextField.text
        let postalcode = postalCodeTextField.text
        let stateoforigin = stateOfOriginTextField.text

        //******getting parameter from string
        let params = [
            "AppID":device.sha512,
            "language":"en",
            "RequestID": timeInSecondsToString,
            "SessionID": session,
            "CustomerID": customer_id,
            "photo": imageBase64String,
            "address": resident,
            "occupation": occupation,
            "gender": selected,
            "marital_status": maritalstatus,
            "title": title,
            "buildingno": buildingNo,
            "bus_stop": bus_stop,
            "town": town,
            "postalcode": postalcode,
            "stateoforigin": stateoforigin
        ]
        
        print(selected)
        
       
        
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
        
        print(token)
        
        let url = "\(utililty.url)update_profile"
        
        apiCall(url: url, parameter: parameter, token: token, header: headers)
    }
    
    
    ///////////***********Post Data MEthod*********////////
    func apiCall(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        self.activityIndicator.startAnimating()
        self.cancel_saveButton.isHidden = true
        
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
                
                
                //*******Parameters for successful response and for data response*******///
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                
                if(status) {
                    
                    if self.globalImage != nil {
                        let pngImage = self.globalImage.pngData()
                        UserDefaults.standard.set(pngImage, forKey: "image")
                    }
                    
                    
                    if self.taken_image == false {
                        self.cancel_saveButton.setTitle("Cancel", for: .normal)
                    }
                    
                    self.activityIndicator.stopAnimating()
                    self.cancel_saveButton.isHidden = false
                    self.cancel_saveButton.setTitle("Cancel", for: .normal)
                    self.delayToNextPageProfile2()
                }
                    
                else if  message == "Session has expired" {
                    self.activityIndicator.stopAnimating()
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    //*******check if delegate is not nil*********
                    self.taken_image = false
                    if self.taken_image == false {
                        self.cancel_saveButton.setTitle("Cancel", for: .normal)
                    }
                    self.activityIndicator.stopAnimating()
                    self.cancel_saveButton.isHidden = false
                    self.message = message
                    
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
                
            }
            else {
               
                self.activityIndicator.stopAnimating()
                self.cancel_saveButton.isHidden = false
                self.message = "Nework Error"
                
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: self.message)
                self.present(alertVC, animated: true)
            }
        }
    }
    
    
    //MARK: ******* Profile API Call******///
       func delayToNextPageProfile2(){
           
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
           
           
           let url = "\(utililty.url)profile"
           
           profileApiCall(url: url, parameter: parameter, token: token, header: headers)
       }
       
       
       
       ///////////***********Post Data MEthod*********////////
       func profileApiCall(url: String, parameter: [String: String], token: String, header: [String: String]) {
     
           
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
                   
                   //*******Parameters for successful response and for data response*******///
                   let status = decriptorJson["status"].boolValue
                   let message = decriptorJson["message"][0].stringValue
                   
                   if(status) {
                       Profile = decriptorJson
                    self.activityIndicator.stopAnimating()
                    let successService = SuccessService()
                    let alertVC = successService.popUp(alertMessage: "Successfully updated your profile")
                    self.present(alertVC, animated: true)
                   }
                   else if  message == "Session has expired" {
                        self.activityIndicator.stopAnimating()
                       self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                   }
               }
               else {
                   self.message = "Nework Error"
                   self.activityIndicator.stopAnimating()
                   ////From the alert Service
                   let alertService = AlertService()
                   let alertVC = alertService.alert(alertMessage: self.message)
                   self.present(alertVC, animated: true)
               }
           }
       }
    
    

    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if ((buildingNoTextField!.text != nil) || (addressTextField!.text != nil) || (NearestBusstopTextField!.text != nil) || (nationalityTextField!.text != nil) || (titleTextField!.text != nil) || (maritalstatusTextField!.text != nil)  || (occupationTextfield!.text != nil) || (townTextField!.text != nil) || (postalCodeTextField!.text != nil) || (stateOfOriginTextField!.text != nil) || (nationalityTextField!.text != nil)) {
            cancel_saveButton.setTitle("Save", for: .normal)
            
            resident = addressTextField.text!
            state = NearestBusstopTextField.text!
            country = nationalityTextField.text!
            
        }

        else {
            cancel_saveButton.setTitle("Cancel", for: .normal)
        }
    }
    
    // MARK - Text field should return keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        viewHieghtConstraints.constant = 1120
//        view.layoutIfNeeded()
        
        self.view.endEditing(true)
        return false
    }
    
    //MARK: Fetch Data from json
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
    
    //MARK: IBACTIONS Declearations
    
    @IBAction func editButtonPressed(_ sender: Any) {
        
        imagePicker.sourceType = .camera
        imagePicker.cameraDevice = .front
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)

    }
    
    @IBAction func openPicker(_ sender: Any) {
        //creatPicker()
    }
    
    //MARK: Button for Gender
    var bool = false
    @IBAction func maleButtonPressed(_ sender: Any) {
        selected = "M"
        cancel_saveButton.setTitle("Save", for: .normal)
        check_button_tapped()
    }
    
    @IBAction func femaleButtonPressed(_ sender: Any) {
        selected = "F"
        check_button_tapped()
        cancel_saveButton.setTitle("Save", for: .normal)
    }

    
    
    func check_button_tapped() {
        if selected == "M" {
            genderButtonMale.setTitleColor(.white, for: .normal)
            genderButtonMale.backgroundColor = UIColor(hexFromString: "#34B5CE")

            genderButtonFemale.setTitleColor(.darkGray, for: .normal)
            genderButtonFemale.backgroundColor = UIColor(hexFromString: "#F2F2F2")
        }
        else if selected == "F" {
            genderButtonFemale.setTitleColor(.white, for: .normal)
            genderButtonFemale.backgroundColor = UIColor(hexFromString: "#34B5CE")

            genderButtonMale.setTitleColor(.darkGray, for: .normal)
            genderButtonMale.backgroundColor = UIColor(hexFromString: "#F2F2F2")
        }
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        
        if cancel_saveButton.titleLabel?.text == "Cancel" {
            print("nnnonnonono")
            return
        }
        
        if (buildingNoTextField!.text != "" || addressTextField!.text != "" || NearestBusstopTextField!.text != "" || nationalityTextField!.text != "") || (taken_image == true) {
            
            delayToNextPageProfile()
            
        }
        else {
            taken_image = false
            dismiss(animated: true, completion: nil)
        }

    }
}



extension EditProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
         return 1
    }


    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryDatas!.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let cellDic = countryDatas![row]
        return cellDic.labelText
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let cellDic = countryDatas![row]
        
     
        nationalityTextField.text = "\(cellDic.currency!) - \(cellDic.currency_name ?? "")"

        nationalityTextField.text = cellDic.labelText
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { // Change `2.0` to the desired number of seconds.
            // Code you want to be delayed
            
            self.nationalityTextField.endEditing(true)
        }
    }
    
    
    func creatPicker() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        
        nationalityTextField.inputView = pickerView
        
    }
}

