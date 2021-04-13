//
//  SelectCountryViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 17/05/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

protocol GetCounty {
    func getCountryObject(countryFlag: UIImage, countryIso: String, countryCode: String)
}

class SelectCountryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    /***********Delegate property for Protocol*************/
    var delegate: GetCounty?
    
    @IBOutlet weak var textFieldSearch: UITextField!
    @IBOutlet weak var tableview: UITableView!
    
    
    var image: UIImage!
    var text: UILabel!
    
    //*******Initializing array to be populated**********//
    var countryDatas: [DataOBjectClass]?  = []
    var searchData: [DataOBjectClass]? = []
    
    var isoSelected = String()
    var flagSelected: UIImage!
    var countryCallingCode = String()
    
    ///search country array initialize///////////
    var searchCountry = [String]()
    var searching = false;

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addBorderRadius()
        fetchJsonFromFile()
        
        self.tableview.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        textFieldSearch.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        textFieldSearch.setLeftPaddingPoints(14)
    }
    
    
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
                    let country_flag = countryData["flag"] as? String {

                    dataObject.labelText = country_name
                    dataObject.imageUrl = country_flag
                    dataObject.isIso = country_isIso
                    dataObject.countryCallCode = calling_code
                }

                self.countryDatas?.append(dataObject)
            }
        }catch {
            print(error)
        }
    }
    

    //************Handles search when input text is filled************//
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        let searchText = textFieldSearch.text
        searching = true
        searchData = countryDatas!.filter({$0.labelText!.lowercased().prefix(searchText!.count) == searchText!.lowercased()})

        tableview.reloadData()
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath) as! countryCell
        
        if(searching) {
            cell.labelForCell.text = self.searchData?[indexPath.row].labelText
            //////converting imageUrl to UIImageView format ////////////////////
            let dataDecoded:NSData = NSData(base64Encoded: (self.searchData?[indexPath.row].imageUrl)!, options: NSData.Base64DecodingOptions(rawValue: 0))!
            let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
            cell.imageForCell.image = decodedimage
        }
        else {
            
            cell.labelForCell.text = self.countryDatas?[indexPath.row].labelText
            
            //////converting imageUrl to UIImageView format ////////////////////
            let dataDecoded:NSData = NSData(base64Encoded: (self.countryDatas?[indexPath.row].imageUrl)!, options: NSData.Base64DecodingOptions(rawValue: 0))!
            let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
            cell.imageForCell.image = decodedimage
        }
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return self.searchData?.count ?? 0
        }
        else {
            return self.countryDatas?.count ?? 0
        }
    }
    
    
    ////Flag selected///////////////
    /////////////////**********//////////////
    var countryFlagSelected = String()
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if searching {
            isoSelected = (self.searchData?[indexPath.row].isIso)!
            countryCallingCode = (self.searchData?[indexPath.row].countryCallCode)!
            countryFlagSelected = (self.searchData?[indexPath.row].imageUrl)!
            
            
            //converting selected image to UIImage
            let dataDecoded:NSData = NSData(base64Encoded: countryFlagSelected, options: NSData.Base64DecodingOptions(rawValue: 0))!
            let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
            flagSelected = decodedimage
        }
        else{
            isoSelected = (self.countryDatas?[indexPath.row].isIso)!
            countryFlagSelected = (self.countryDatas?[indexPath.row].imageUrl)!
            countryCallingCode = (self.countryDatas?[indexPath.row].countryCallCode)!
            
            print(countryCallingCode)
            
            //converting selected image to UIImage
            let dataDecoded:NSData = NSData(base64Encoded: countryFlagSelected, options: NSData.Base64DecodingOptions(rawValue: 0))!
            let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
            flagSelected  = decodedimage
        }
        
        
        ////*********This is where i send selected country info back ************//
        //*******check if delegate is not nil*********
        delegate?.getCountryObject(countryFlag: flagSelected, countryIso: isoSelected, countryCode: countryCallingCode)
        
        //*****Dimiss ViewController*********//
        dismiss(animated: true, completion: nil)
    }
    
    
    func addBorderRadius() {
        textFieldSearch.layer.cornerRadius = 15.0
        textFieldSearch.layer.masksToBounds = true
        textFieldSearch.layer.borderWidth = 0.5
        textFieldSearch.layer.borderColor = UIColor.lightGray.cgColor
    }

    @IBAction func goBackToSelectContryPage(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
