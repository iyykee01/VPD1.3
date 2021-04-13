//
//  CinemaViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 26/09/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class CinemaViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var error_message: UILabel!
    
    
    var from_segue = [String]()
    var cinema_choosing = ""
    var message = ""
    
    
    var movies = [MovieModel]()
    var selected_cell: MovieModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = 100
        
        makeServerCall()
    }
    
    //MARK: page+++++++===========//
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
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "SessionID": session, "CustomerID": customer_id, "operation": "getcinemas"]
        
        
        
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
        
        print(token)
        
        let url = "\(utililty.url)movies"
        
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
                
                //print(decriptorJson)
                
                //*******Parameters for successful response and for data response*******///
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                
                if(status) {
                    if decriptorJson["response"].arrayValue.count == 0 {
                        self.error_message.isHidden = false
                        self.error_message.text = "No Cinema to display at the moment."
                    }
                    
                    self.activityIndicator.stopAnimating()
                    //********Response from server *******//
                    self.movies = [MovieModel]()
                    for i in decriptorJson["response"].arrayValue {
                        let new_moview = MovieModel()
                        
                        
                        new_moview.name = i["name"].stringValue
                        new_moview.cid = i["cid"].stringValue
                        new_moview.state = i["state"].stringValue
                        new_moview.location = i["location"].stringValue
                        
                        self.movies.append(new_moview)
                    }
                }
                    
                else if  message == "Session has expired" {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    //*******check if delegate is not nil*********
                    self.error_message.isHidden = false
                    self.error_message.text = message
                    self.activityIndicator.stopAnimating()
                    
                    self.message = message
                    
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
                
            }
            else {
                
                self.activityIndicator.stopAnimating()
                self.error_message.isHidden = false
                self.error_message.text = "No Cinema to display at the moment."
                
                self.message = "Nework Error"
                
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: self.message)
                self.present(alertVC, animated: true)
                self.makeServerCall()
            }
            self.tableView.reloadData()
        }
        
        
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! CinemaChoosingViewController
        
        destination.selected_cinema = selected_cell
        
    }
    
}

extension CinemaViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cinemaCell", for: indexPath) as! CinemaTableViewCell
        cell.selectionStyle = .none
        
        let subCell = movies[indexPath.row]
        
        cell.cinemaLabel_location.text = subCell.name
        cell.cinema_country.text = "\(subCell.location), \(subCell.state)."
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected_cell = movies[indexPath.row]
        performSegue(withIdentifier: "toToMovieShowing", sender: self)
    }
    
}


