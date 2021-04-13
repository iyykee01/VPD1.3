//
//  WhatWalletCurrencyViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 26/08/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class WhatWalletCurrencyViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var buttonOutlet: UIButton!
    
    
    var firstname = ""
    var middlename = ""
    var lastname = ""
    var dob = ""
    var selected_currency = "NGN"
    
    var link = ""
    
    var currencyArray = [
        ["index": "0", "country": "NGN"],
        ["index": "1", "country":"USD"],
        ["index": "2", "country":"GBP"],
        ["index": "3", "country":"EURO"]
    ]
    
    var indexRow = 0
    
    var currency_picked = "NGN"
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        pageControl.numberOfPages = currencyArray.count
        pageControl.currentPage = 0
        
        //Setting decelerationRate to fast gives a nice experience
        collectionView.decelerationRate = .fast
        
        selected_currency = "NGN"

        print(firstname, middlename, lastname, dob, selected_currency)
        
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        AddDependantAPi()
    }
    
    //++++++=========Delay function @if token is true move to next page+++++++===========//
    func AddDependantAPi(){
        
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "SessionID": session, "CustomerID": customer_id,
                      "firstname": firstname, "lastname": lastname, "dob": dob, "currency": selected_currency]
        
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
        
        
        let url = "\(utililty.url)create_dependant"
        
        profileApiCall(url: url, parameter: parameter, token: token, header: headers)
    }
    
    
    ///////////***********Post Data MEthod*********////////
    func profileApiCall(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        activityIndicator.startAnimating()
        buttonOutlet.isHidden = true
        
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
                    self.activityIndicator.stopAnimating()
                    self.buttonOutlet.isHidden = false
                    self.link = decriptorJson["response"]["link"].stringValue
                    self.performSegue(withIdentifier: "goToSuccess", sender: self)
                }
                else {
                    //*******check if delegate is not nil*********
                    self.activityIndicator.stopAnimating()
                    self.buttonOutlet.isHidden = false
                    
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
                
            }
            else {
                
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Network Error")
                self.present(alertVC, animated: true)
                self.activityIndicator.stopAnimating()
                self.buttonOutlet.isHidden = false
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSuccess" {
            let destinationVC = segue.destination as! SuccessfulDependantViewController
            destinationVC.link = link
            
        }
    }
    
}

extension WhatWalletCurrencyViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currencyArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "currencyCell", for: indexPath) as! WhatCurrencyCell
        
        let cellDict = currencyArray[indexPath.row]
        
        
        if Int(cellDict["index"]!)  == indexRow {
            cell.currencyLabel.textColor = .black
        }
        else {
            cell.currencyLabel.textColor = .lightGray
        }
        
   
        cell.currencyLabel.text = cellDict["country"]
        return cell
    }
    
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let layout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        
        let cell = layout.itemSize.width + layout.minimumLineSpacing
        
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cell
        let roundIndex = round(index)
   
        
        indexRow = Int(roundIndex)
        selected_currency = String(currencyArray[indexRow]["country"]!)
        
        print(selected_currency)
        
        offset = CGPoint(x: roundIndex * cell - scrollView.contentInset.left, y: scrollView.contentInset.top)
        
        targetContentOffset.pointee = offset
        
        collectionView.reloadData()
    }
    
}
