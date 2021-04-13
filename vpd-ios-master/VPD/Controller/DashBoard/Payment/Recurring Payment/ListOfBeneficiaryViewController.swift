//
//  ListOfBeneficiaryViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 09/09/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire



class ListOfBeneficiaryViewController: UIViewController, seguePerform {
  
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labelForNoRecurringPayment: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //["name": "Ikenna", "phone_number": "08163371931", "currency": "NGN"]
    
    
    var wallet_id = currentWalletSelected["walletId"]
    
    var arr = [String]()
    
    var list_recurring = [ListRecurringModel]()
    var selected_recurring: ListRecurringModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 100
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        callListOfRecuring()
    }
    
    //MARK: -  getPlan
       func callListOfRecuring(){

           /******Import  and initialize Util Class*****////
           let utililty = UtilClass()
           
           let device = utililty.getPhoneId()
           
           //print("shaDevicePpties")
           let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
           let timeInSecondsToString = String(timeInSeconds)
           
           let session = UserDefaults.standard.string(forKey: "SessionID")!
           let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
           
           //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "operation": "list", "wallet": wallet_id ]
           
           
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
           
           
           let url = "\(utililty.url)recurrent_payment"
           
           postToCallRecurring(url: url, parameter: parameter, token: token, header: headers)
       }
       
       //MARK - VALIDATE
       ///////////***********Post Data MEthod*********////////
       func postToCallRecurring(url: String, parameter: [String: String], token: String, header: [String: String]) {
           
        self.activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        tableView.isHidden = false
        labelForNoRecurringPayment.isHidden = true
           
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
                       self.view.isUserInteractionEnabled = true
                       
                    self.list_recurring = [ListRecurringModel]()
                    
                    for i in decriptorJson["response"].arrayValue {
                        
                        let new_recurring = ListRecurringModel()
                        
                        new_recurring.id = i["id"].stringValue
                        new_recurring.currency = i["currency"].stringValue
                        new_recurring.active = i["active"].stringValue
                        new_recurring.frequency = i["frequency"].stringValue
                        new_recurring.type = i["type"].stringValue
                        new_recurring.amount = i["amount"].stringValue
                        
                        self.list_recurring.append(new_recurring)
                    }
                       
                   }
                   else if (message == "Session has expired") {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                   }
                    
                   else {
                    self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                    self.tableView.isHidden = true
                    self.labelForNoRecurringPayment.isHidden = false
                }
               }
               else {
                self.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
                self.tableView.isHidden = true
                self.labelForNoRecurringPayment.isHidden = false
            }
            
            self.tableView.reloadData()
            if self.list_recurring.count == 0 {
                self.tableView.isHidden = true
                self.labelForNoRecurringPayment.isHidden = false
            }
           }
       }
    
    
    @IBAction func addRecurringButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "toPopUp", sender: nil)
    }
    
    //MARK: - Stub
    func goNext(next: String) {
        performSegue(withIdentifier: next, sender: self)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "toPopUp" {
            let destination = segue.destination as! UtilityPopUpViewController
           destination.from_segue = "recurring"
            destination.delegate = self
        }
        
        if segue.identifier == "goToRecurringDetails" {
            let destination = segue.destination as!  RecurringDetailsViewController
            
            destination.selected_recurring = selected_recurring
             
        }
        
    }
}


extension ListOfBeneficiaryViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return list_recurring.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SelectBeneficiaryTableViewCell
        
        cell.selectionStyle = .none
        
        let contact = list_recurring[indexPath.row]
        
        cell.name.text = contact.type
        cell.currency.text = "\(contact.currency) \(contact.amount)"
        cell.number.text = contact.frequency
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selected_recurring = list_recurring[indexPath.row]
        performSegue(withIdentifier: "goToRecurringDetails", sender: self)
    }
    
    
}
