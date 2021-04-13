//
//  ChooseYourCountryViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 02/09/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class ChooseYourCountryViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var currencyTextField: UITextField!
    @IBOutlet weak var countryDropDownView: DesignableButton!
    @IBOutlet weak var countryTextFeild: UITextField!
    @IBOutlet weak var flagView: UIImageView!
    @IBOutlet weak var flagView2: UIImageView!
    
    
    //*******Initializing array to be populated**********//
    var countryDatas: [DataOBjectClass]?  = []
    
    var selectedField: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        currencyTextField.delegate = self
        currencyTextField.setLeftPaddingPoints(60)
        countryTextFeild.setLeftPaddingPoints(60)
        
        flagView.isHidden = true
        view.sendSubviewToBack(flagView)
        
        fetchJsonFromFile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissPickerView)))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        creatPicker()    }
    
    
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
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        currencyTextField.resignFirstResponder()
        return false
    }
    
    @objc func dismissPickerView(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dropDownButtonPressed(_ sender: Any) {
        creatPicker()
    }
    
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        print("Clicked")
        performSegue(withIdentifier: "goToAccountDetails", sender: nil)
    }
}

extension ChooseYourCountryViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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
        
        //converting selected image to UIImage
        let dataDecoded:NSData = NSData(base64Encoded: cellDic.imageUrl!, options: NSData.Base64DecodingOptions(rawValue: 0))!
        let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
        
        flagView.image = decodedimage
        currencyTextField.text = "\(cellDic.currency!) - \(cellDic.currency_name!)"
        
        flagView.isHidden = false
        view.bringSubviewToFront(flagView)
        //converting selected image to UIImage
        let dataDecoded2:NSData = NSData(base64Encoded: cellDic.imageUrl!, options: NSData.Base64DecodingOptions(rawValue: 0))!
        let decodedimage2:UIImage = UIImage(data: dataDecoded2 as Data)!
        
        flagView2.image = decodedimage2
        
        countryTextFeild.text = cellDic.labelText
    }
    
    
    func creatPicker() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        
        countryTextFeild.inputView = pickerView
    }
}
