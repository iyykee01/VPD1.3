//
//  EventsViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 04/10/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class EventsViewController: UIViewController, UITextFieldDelegate  {
    
    var from_segue = ""
    var message = ""
    
    var eventsArray = [Event]()
    var location = [Location]()
    var date = [Dates]()
    var tickets = [Tickets]()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var error_message: UILabel!
    
    var searchData: [Event] = []
    var searching = false
    
    
    var selected_cell: Event!
    var selected_location : Location!
    

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        searchTextField.delegate = self
        print(from_segue, "I reached this page")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        makeServerCall()
    }
    
    //************Handles search when input text is filled************//
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        let searchText = searchTextField.text
        
        searching = true
        searchData = eventsArray.filter({$0.title.lowercased().prefix(searchText!.count) == searchText!.lowercased()})
        
        collectionView.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
    //MARK:- page+++++++===========//
    func makeServerCall(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "SessionID": session, "CustomerID": customer_id, "operation": "getevents"]
        
        
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
        
        let url = "\(utililty.url)events"
        
        apiCall(url: url, parameter: parameter, token: token, header: headers)
    }
    
    
    ///////////***********Post Data MEthod*********////////
    func apiCall(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
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
                
                //*******Parameters for successful response and for data response*******///
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                
                if(status) {
                    
                    if decriptorJson["response"].arrayValue.count == 0 {
                        self.error_message.isHidden = false
                        self.error_message.text = "No Events to display at the moment."
                    }
                    self.activityIndicator.stopAnimating()
                    
                    self.eventsArray = [Event]()
                    self.location = [Location]()
                    self.date = [Dates]()
                    self.tickets = [Tickets]()
                    
                    for i in decriptorJson["response"].arrayValue {
                        let new_event = Event()
                        
                        new_event.thumbnail = i["thumbnail"].stringValue
                        new_event.title = i["title"].stringValue
                        new_event.id = i["id"].stringValue
                        new_event.ageRestriction = i["ageRestriction"].stringValue
                        new_event.banner = i["banner"].stringValue
                        new_event.description = i["description"].stringValue
                        
                        
                        
                        for x in  i["location"].arrayValue {
                            let new_location = Location()
                            
                            new_location.venue = x["venue"].stringValue
                            
                            for date in x["dates"].arrayValue {
                                let new_date = Dates()
                                new_date.date = date["date"].stringValue
                                
                                for t in date["time"].arrayValue {
                                    new_date.time.append(t.stringValue)
                                }
                                
                                new_location.dates.append(new_date)
                            }
                            
                            new_event.location.append(new_location)
                        }
                        
                        for ticket in i["tickets"].arrayValue {
                            let new_ticket = Tickets()
                            
                            new_ticket.id = ticket["id"].stringValue
                            new_ticket.price = ticket["price"].stringValue
                            new_ticket.title = ticket["title"].stringValue
                            new_ticket.venue = ticket["venue"].stringValue
                            
                            print(new_ticket.price)
                            new_event.tickets.append(new_ticket)
                        }
                        
                        
                        
                        self.eventsArray.append(new_event)
                    }
                    
                    self.collectionView.reloadData()
                    
                }
                    
                else if  message == "Session has expired" {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    //*******check if delegate is not nil*********
                    
                    self.activityIndicator.stopAnimating()
                    self.message = message
                    self.error_message.isHidden = false
                    self.error_message.text = message
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
                
            }
            else {
                self.activityIndicator.stopAnimating()
                self.message = "Nework Error"
                
                self.error_message.isHidden = false
                self.error_message.text = "No Events to display at the moment."
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: self.message)
                self.present(alertVC, animated: true)
            }
            
        }
    }
    
    
    
    func populate(number: Int, image: String) -> [String] {
        
        var mobile = [String]()
        
        if number == 0 {
            return mobile
        }
        else {
            for _ in 1...number {
                mobile.append(image)
            }
            return mobile;
        }
        
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! EventDetailsViewController
        
        destination.from_segue = selected_cell
        //destination.from_segue_location = selected_location
    }

}




extension EventsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searching {
            return searchData.count
        }
        else {
            return eventsArray.count
        }
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MovieCollectionViewCell
        
   
        
        if searching {
            let search_array = searchData[indexPath.row]
            let search_location = searchData[indexPath.row].location
            
            if search_location.count != 0 {
                
                let date_convert = (search_location[indexPath.section].dates[indexPath.section].date)
                
                
                let date = Date.dateFromCustom(customString: date_convert)
                let customDate = Date.dateFormaterMonth(date: date)
                let split_date = customDate.split(separator: " ")
                
                if split_date[0] == "1"  {
                    cell.moviePG.text = "\(search_location[indexPath.section].venue) | \(split_date[0])st \(split_date[1])"
                }
                else {
                    cell.moviePG.text = "\(search_location[indexPath.section].venue) | \(split_date[0])th \(split_date[1])"
                }
                
                
            }
            else {
                cell.moviePG.text = ""
            }
            
            cell.movieImage.sd_setImage(with: URL(string: search_array.thumbnail), placeholderImage: UIImage(named: ""))
            cell.movieTitle.text = search_array.title
            cell.movieDescription.text = search_array.description
            
        }
        else {
            let dictionary_array = eventsArray[indexPath.row]
            let dictionary_location = eventsArray[indexPath.row].location
            
            if dictionary_location.count != 0 {
                
                let date_convert = (dictionary_location[indexPath.section].dates[indexPath.section].date)
                
                
                let date = Date.dateFromCustom(customString: date_convert)
                let customDate = Date.dateFormaterMonth(date: date)
                let split_date = customDate.split(separator: " ")
                
                if split_date[0] == "1"  {
                    cell.moviePG.text = "\(dictionary_location[indexPath.section].venue) | \(split_date[0])st \(split_date[1])"
                }
                else {
                    cell.moviePG.text = "\(dictionary_location[indexPath.section].venue) | \(split_date[0])th \(split_date[1])"
                }
                
                
            }
            else {
                cell.moviePG.text = ""
            }
            
            
            cell.movieImage.sd_setImage(with: URL(string: dictionary_array.thumbnail), placeholderImage: UIImage(named: ""))
            cell.movieTitle.text = dictionary_array.title
            cell.movieDescription.text = dictionary_array.description
        }
        
  
        
      
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        
        if searching {
            if searchData[indexPath.row].location.count != 0 {
                selected_cell = searchData[indexPath.row]
                
                performSegue(withIdentifier: "goToEventDetails", sender: self)
            }
            
            else {
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "No available location for this event.")
                self.present(alertVC, animated: true)
            }
        }
        else {
            if eventsArray[indexPath.row].location.count != 0 {
                selected_cell = eventsArray[indexPath.row]
                
                performSegue(withIdentifier: "goToEventDetails", sender: self)
            }
            
            else {
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "No available location for this event.")
                self.present(alertVC, animated: true)
            }
        }
        
    }
}






