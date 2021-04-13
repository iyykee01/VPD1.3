//
//  NotificationViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 19/02/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NotificationViewController: UIViewController {
    
    var notifications = [NotificationModel]()
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var tableVIew: UITableView!
    @IBOutlet weak var noNotificationLabel: UILabel!
    
    var url = ""
    var selected_row: NotificationModel!
    var id = ""
    var count = 0
    var selectedIndex: NSInteger! = -1
    
    @IBOutlet weak var notification_label: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        count = notifications.count
        
        tableVIew.dataSource = self
        tableVIew.delegate = self
        tableVIew.rowHeight = 90
        
        notification_label.text = String(count)
        
    }
    
    //    override func viewDidAppear(_ animated: Bool) {
    //
    //        if notifications.count == 0 {
    //            noNotificationLabel.isHidden = true
    //        }
    //        else {
    //            noNotificationLabel.isHidden = false
    //        }
    //    }
    
    
    
    //MARK: Notification API HERE************************
    //++++++=========Delay function @if token is true move to next page+++++++===========//
    func UrlRequestAPI(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "SessionID": session, "CustomerID": customer_id, "operation": "fetch", "paymentcode": url]
        
        
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
        
        
        let url = "\(utililty.url)request_payment"
        
        
        postData(url: url, parameter: parameter, token: token, header: headers)
    }
    
    
    
    // MARK: -******Main Dashboard Api call******
    ///////////***********Post Data MEthod*********////////
    func postData(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        self.activityIndicator.startAnimating()
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
                print(decriptorJson)
                
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                
                
                if(status) {
                    
                    self.view.isUserInteractionEnabled = true
                    self.activityIndicator.stopAnimating();
                    let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "paymenLink") as? PaymentLinkViewController
                    vc?.from_segue = "notifications"
                    vc?.amount = decriptorJson["response"]["amount"].stringValue
                    vc?.currency = decriptorJson["response"]["currency"].stringValue
                    vc?.note = decriptorJson["response"]["note"].stringValue
                    vc?.name = decriptorJson["response"]["name"].stringValue
                    vc?.code = self.url
                    vc?.number = decriptorJson["response"]["account"].stringValue
                    self.navigationController?.pushViewController(vc!, animated: true)
                }
                    
                else if (message == "Session has expired") {
                    self.activityIndicator.stopAnimating()
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self )
                }
                else {
                    self.view.isUserInteractionEnabled = true
                    self.activityIndicator.stopAnimating()
                    let alertService = AlertService()
                    let alertVC =  alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.view.isUserInteractionEnabled = true
                self.activityIndicator.stopAnimating()
                let alertService = AlertService()
                let alertVC =  alertService.alert(alertMessage: "Network error")
                self.present(alertVC, animated: true)
            }
        }
        
    }
    
    //MARK: Read Notification APi Start
    func readNotificationAPI(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "SessionID": session, "CustomerID": customer_id, "operation": "seen", "id": id]
        
        
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
        
        
        let url = "\(utililty.url)notifications"
        
        
        postData2(url: url, parameter: parameter, token: token, header: headers)
    }
    
    
    
    // MARK: -******Main Dashboard Api call******
    ///////////***********Post Data MEthod*********////////
    func postData2(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        //self.activityIndicator.startAnimating()
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
                print(decriptorJson)
                
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                
                
                if(status) {
                    //self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                }
                    
                else if (message == "Session has expired") {
                    self.activityIndicator.stopAnimating()
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self )
                }
                else {
                    self.view.isUserInteractionEnabled = true
                    self.activityIndicator.stopAnimating()
                    let alertService = AlertService()
                    let alertVC =  alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.view.isUserInteractionEnabled = true
                self.activityIndicator.stopAnimating()
                let alertService = AlertService()
                let alertVC =  alertService.alert(alertMessage: "Network error")
                self.present(alertVC, animated: true)
            }
        }
        
    }
    
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToReadNotification" {
            let des = segue.destination as! ReadNotificationViewController
            
            des.date = selected_row.date
            des.message = selected_row.message
        }
    }
    
}

extension NotificationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NotificationTableViewCell
        cell.selectionStyle = .none
        
        cell.headerLabel.text = notifications[indexPath.row].date
        cell.bodyLabel.text = notifications[indexPath.row].message
        
        cell.headerLabel2.text = notifications[indexPath.row].date
        cell.bodyLabel2.text = notifications[indexPath.row].message
        
        return cell
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! NotificationTableViewCell
        
        selected_row = notifications[indexPath.row]
        selected_row.read.toggle()
        
        
        
        if notifications[indexPath.row].url != "" {
            let splited = notifications[indexPath.row].url.split(separator: "/")
            url = String(splited[3])
            UrlRequestAPI()
            return
        }
        if indexPath.row == selectedIndex {
            selectedIndex = -1
            //readNotificationAPI()
        }
        
        if selected_row.read {
            
            cell.viewWrapper2.isHidden = false
            cell.viewWrapper.isHidden = true
            
            if !selected_row.counted {
                count = count - 1
                notification_label.text = String(count)
                cell.headerLabel.textColor = .black
                cell.bodyLabel.textColor = .black
                selected_row.counted = true
            }
        }
        
        
        else {
            cell.viewWrapper2.isHidden = !false
            cell.viewWrapper.isHidden = !true
            id = selected_row.id
            selectedIndex = indexPath.row
            //readNotificationAPI()
        }
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
   
        if notifications[indexPath.row].read {
            return 130
        }
        else {
            return 90
        }
        
    }
}



