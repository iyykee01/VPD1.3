//
//  MovieChoosingViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 27/09/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Cosmos
import SwiftyJSON
import Alamofire
import SDWebImage



class CinemaChoosingViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchTextField: DesignableUITextField2!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var toChangeHeader: UILabel!
    @IBOutlet weak var error_message: UILabel!

    
    var searchData = [MovieCategory]()
    var searching = false
    
    
    var movieCategory = [MovieCategory]()
    var showTime = [ShowTime]()
    var ticketType = [TicketType]()
    
    
    
    var message = ""
    var from_segue = ""
    var selected_cinema: MovieModel!
    var selected_uid = ""
    
    var selected_movie: MovieCategory!

 
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(from_segue)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
         searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        toChangeHeader.text = "Movies showing at \(selected_cinema.name)"
        
        makeServerCall(cid: selected_cinema.cid)
    }
    
    //************Handles search when input text is filled************//
    @objc func textFieldDidChange(_ textField: UITextField) {
        searching = true
        let searchText = searchTextField.text
        
        searchData = movieCategory.filter({$0.title.lowercased().prefix(searchText!.count) == searchText!.lowercased()})

        collectionView.reloadData()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.resignFirstResponder()
        view.endEditing(true)
        if searchTextField.text == "" {
            searching = false
        }

        return false
    }
    
    //MARK: page+++++++===========//
    func makeServerCall(cid: String){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "SessionID": session, "CustomerID": customer_id, "cid": cid, "operation": "getcinemamovies"]
        
       
        
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
                
                print(decriptorJson)
                
                //*******Parameters for successful response and for data response*******///
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                
                if(status) {
                    if decriptorJson["response"].arrayValue.count == 0 {
                        self.error_message.isHidden = false
                        self.error_message.text = "No Movie to display at the moment."
                    }
                    
                    self.activityIndicator.stopAnimating()
                    //********Response from server *******//
                    self.ticketType = [TicketType]()
                    self.showTime = [ShowTime]()
                    self.movieCategory = [MovieCategory]()
                    
                    for i in decriptorJson["response"].arrayValue {
                        let new_movie_category = MovieCategory()
                        
                        new_movie_category.duration = i["duration"].stringValue
                        new_movie_category.description = i["description"].stringValue
                        new_movie_category.banner = i["banner"].stringValue
                        new_movie_category.genre = i["genre"].stringValue
                        new_movie_category.ageRestriction = i["ageRestriction"].stringValue
                        new_movie_category.mid  = i["mid"].stringValue
                        new_movie_category.thumbImage = i["thumbImage"].stringValue
                        new_movie_category.title = i["title"].stringValue
                        
                        
                        for j in i["showtime"].arrayValue {
                            
                            let new_show_time = ShowTime()
                            
                            new_show_time.date = j["date"].stringValue
                            new_show_time.showtimeID = j["showtimeID"].stringValue
                            new_show_time.seatsAvailable = j["seatsAvailable"].stringValue
                            new_show_time.time = j["time"].stringValue
                            new_show_time.day = j["day"].stringValue
                            new_show_time.screenName = j["screenName"].stringValue
                            new_show_time.mid = i["mid"].stringValue
                            
                            
                            new_movie_category.showtime.append(new_show_time)
                            
                            for x in j["ticketType"].arrayValue {

                                let new_ticket_type = TicketType()
                                
                                new_ticket_type.ticketID = x["ticketID"].stringValue
                                new_ticket_type.attribute = x["attribute"].stringValue
                                new_ticket_type.group = x["group"].stringValue
                                new_ticket_type.price = x["price"].stringValue
                                new_ticket_type.mid = i["mid"].stringValue
                                new_ticket_type.date = j["date"].stringValue
                                new_ticket_type.time = j["time"].stringValue
                                new_ticket_type.day = j["day"].stringValue
                                new_ticket_type.showtimeID = j["showtimeID"].stringValue
                                new_ticket_type.count = 0
                                
                                
                                new_show_time.ticketType.append(new_ticket_type)
                            }
                        }
                        
                        self.movieCategory.append(new_movie_category)
                    }
                    
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
                self.error_message.text = "No Movie to display at the moment."
                
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: self.message)
                self.present(alertVC, animated: true)
            }
            
            self.collectionView.reloadData()

        }
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToMovieDetails" {
            let destination = segue.destination as! MovieDetailsViewController
            
            destination.movie_selected = selected_movie
            destination.cinema_location = selected_cinema.name
            destination.cid = selected_cinema.cid
            destination.ticket_uid = selected_uid
        }
    }
}

extension CinemaChoosingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searching {
            return searchData.count
        }
        else {
            return movieCategory.count
        }
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MovieCollectionViewCell
        
        if searching {
            let dictionary = searchData[indexPath.row]
            
            cell.movieImage.sd_setImage(with: URL(string: dictionary.thumbImage), placeholderImage: UIImage(named: ""))
            
            
            cell.movieTitle.text = dictionary.title
            cell.moviePG.text = "\(dictionary.ageRestriction) | \(dictionary.duration)"
            cell.movieDescription.text = dictionary.description
            cell.movieGengre.text = dictionary.genre
        }
        else {
            let dictionary = movieCategory[indexPath.row]
            
            cell.movieImage.sd_setImage(with: URL(string: dictionary.thumbImage), placeholderImage: UIImage(named: ""))
            
            
            cell.movieTitle.text = dictionary.title
            cell.moviePG.text = "\(dictionary.ageRestriction) | \(dictionary.duration)"
            cell.movieDescription.text = dictionary.description
            cell.movieGengre.text = dictionary.genre
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if searching {
            selected_movie = searchData[indexPath.row]
        }
        
        else {
            selected_movie = movieCategory[indexPath.row]
        }
        
        
        // performSegue(withIdentifier: "goToTest", sender: self)
        performSegue(withIdentifier: "goToMovieDetails", sender: self)
    }
}






