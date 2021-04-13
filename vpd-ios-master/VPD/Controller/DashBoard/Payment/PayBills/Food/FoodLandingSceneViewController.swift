//
//  FoodLandingSceneViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 09/12/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage
import CoreLocation
import Cosmos


class FoodLandingSceneViewController: UIViewController, UITextFieldDelegate  {
    
    
    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    
    var currentLocationLongitude: CLLocationDegrees!
    var currentLocationLatitude: CLLocationDegrees!
    @IBOutlet weak var searchTextField: UITextField!
    
    var location_CLLocation: CLLocation?
    

    var currentLocation:CLLocationCoordinate2D! //location object

    //variables to store longlat
    var longitude_Api: String!
    var latitude_Api: String!
    
    var longitude_Clocation: String!
    var latitude_Clocation: String!
    
    @IBOutlet weak var user_location: UIButton!
    
    var myLocation: CLLocation?
    
    var searching = false
    
    var restaurant = [AllRestaurant]()
    var cuisines = [Cuisines]()
    var pack_fee = [PackFee]()
    
    var searchData = [AllRestaurant]()
    
    var selected_restuarant: AllRestaurant?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        tableView.rowHeight = 150
        tableView.dataSource = self
        tableView.delegate = self
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        delayToNextPage()
        
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
       
    //************Handles search when input text is filled************//
    @objc func textFieldDidChange(_ textField: UITextField) {
      
        searching = true
        let searchText = searchTextField.text
        
        searchData = restaurant.filter({$0.name.lowercased().prefix(searchText!.count) == searchText!.lowercased()})
        
        tableView.reloadData()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.resignFirstResponder()
        view.endEditing(true)
        if searchTextField.text == "" {
            searching = false
        }
        
        return false
    }
    
    

    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    // MARK API Call
    //++++++=========Delay function @if token is true move to next page+++++++===========//
    func delayToNextPage(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "operation": "getrestaurants"]
        
        
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
        
        
        
        let url = "\(utililty.url)food"
        
        postData(url: url, parameter: parameter, token: token, header: headers)
    }
   
    
    ///////////***********Post Data MEthod*********////////
    func postData(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        activityIndicator.startAnimating()
        
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
                
                
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                
                
                if(status) {
                    self.activityIndicator.stopAnimating()
                    
                    self.restaurant = [AllRestaurant]()
                    self.cuisines = [Cuisines]()
                    self.pack_fee = [PackFee]()
                    
                    for i in decriptorJson["response"].arrayValue {
                        let all_restaurant = AllRestaurant()
                        
                        all_restaurant._id = i["_id"].stringValue
                        all_restaurant.delivery = i["delivery"].stringValue
                        all_restaurant.image = i["image"].stringValue
                        all_restaurant.address = i["address"].stringValue
                        all_restaurant.allow_review = i["allow_review"].boolValue
                        all_restaurant.name = i["name"].stringValue
                        all_restaurant.rating = i["rating"].stringValue
                        all_restaurant.banner = i["banner"].stringValue
                        
                        //For contacts
                        all_restaurant.contact["email"] = i["contact"]["email"].stringValue
                        all_restaurant.contact["name"] = i["contact"]["name"].stringValue
                        all_restaurant.contact["phone"] = i["contact"]["phone"].stringValue
                        
                        //print(all_restaurant.contact, "from line ..... 156")
                        
                        // For cities
                        all_restaurant.city["_id"] = i["city"]["_id"].stringValue
                        all_restaurant.city["name"] = i["city"]["name"].stringValue
                        
                        
                        // For geo
                        all_restaurant.geo["address_formatted"] = i["geo"]["address_formatted"].stringValue
                        all_restaurant.geo["latitude"] = i["geo"]["latitude"].stringValue
                        all_restaurant.geo["longitude"] = i["geo"]["longitude"].stringValue
                        all_restaurant.geo["place_id"] = i["geo"]["place_id"].stringValue
                        
                        // For openings
                        all_restaurant.openings["weekdays"] = i["openings"]["weekdays"].stringValue
                        all_restaurant.openings["weekends"] = i["openings"]["weekends"].stringValue
                        
                        // For location
                        all_restaurant.location["name"] = i["location"]["name"].stringValue
                        all_restaurant.location["_id"] = i["location"]["_id"].stringValue
                        
                        // For cuisines
                        for j in i["cuisines"].arrayValue {
                            let new_cusine = Cuisines()
                            new_cusine._id = j["_id"].stringValue
                            new_cusine.name = j["name"].stringValue
                            
                            all_restaurant.cuisines.append(new_cusine)
                        }
                        
                        for x in i["pack_fee"].arrayValue {
                            let new_pack_fee = PackFee()
                            new_pack_fee._id = x["_id"].stringValue
                            new_pack_fee.amount = x["amount"].stringValue
                            new_pack_fee.category["_id"] = x["category"]["_id"].stringValue
                            new_pack_fee.category["name"] = x["category"]["name"].stringValue
                            
                            //print(new_pack_fee.amount )
                            all_restaurant.pack_fee.append(new_pack_fee)
                        }
                        
                        self.restaurant.append(all_restaurant)
                    }
                    
                    self.tableView.reloadData()
                }
                
                else if (message == "Session has expired") {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                   
                    ////From the alert Service
                    self.activityIndicator.stopAnimating()
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.activityIndicator.stopAnimating()
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
          
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! RestaurantDetailsViewController
        
        destination.from_segue = selected_restuarant
    }
   
}

extension FoodLandingSceneViewController: CLLocationManagerDelegate {
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]

        print(location)
        
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            
            myLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
//            longitude_Clocation = String(currentLocationLongitude)
//            latitude_Clocation = String(currentLocationLatitude)
            
            getAddressFromLocation(location: location)
        }

        else{
            print("No location was gotten")
        }

    }
    
    //MARK: - GeoLocation Manager Delegate Methods
       /***************************************************************/
       
       func getAddressFromLocation(location: CLLocation) {
       
           CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
               print(location)
               
               if error != nil {
                   print("Reverse geocoder failed with error \(error.debugDescription)")
               return
               }
               
               var placeMark: CLPlacemark!
               placeMark = placemarks?[0]
               
               if placeMark == nil {
                   return
               }
               
           })
       }
       
       
       //Write the didFailWithError method here
       func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
           print(error)
       }
}



extension FoodLandingSceneViewController: UITableViewDelegate, UITableViewDataSource {
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchData.count
        }
        else {
            return restaurant.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if searching {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FoodRestaurantableViewCell
            
            cell.selectionStyle = .none
            
            let cellDic = searchData[indexPath.row]
            
            cell.name.text = cellDic.name
            cell.imageForCell.sd_setImage(with: URL(string: cellDic.image), placeholderImage: UIImage(named: ""))
            cell.openTime.text = cellDic.openings["weekdays"]
            
            
            
            let delivery_fee = cellDic.pack_fee[indexPath.section].category["name"]!
            cell.fee.text = "\(delivery_fee) - #\(cellDic.pack_fee[indexPath.section].amount)"
            
            //let cosmosView: CosmosView = {
            //            let view = CosmosView()
            //            view.settings.updateOnTouch = false
            //            view.settings.fillMode = .precise
            //            view.settings.starSize = 15
            //            view.settings.starMargin = 2
            //            view.settings.emptyBorderColor = UIColor.lightGray
            //            let movie_rating = cellDic.rating
            //            if movie_rating != "" {
            //                view.rating = (movie_rating as NSString).doubleValue
            //            }
            //            else {
            //                view.rating = 0.0
            //            }
            //
            //
            //            view.text = movie_rating
            //            view.settings.textColor = .darkGray
            //            view.settings.textMargin = 5
            //            view.settings.textFont = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.regular)
            //            return view
            //        }()
            //
            //        cell.ratingView.addSubview(cosmosView)
            
            return cell
        }
        
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FoodRestaurantableViewCell
            
            cell.selectionStyle = .none
            
            let cellDic = restaurant[indexPath.row]
            
            cell.name.text = cellDic.name
            
            
            cell.imageForCell.sd_setImage(with: URL(string: cellDic.image), placeholderImage: UIImage(named: ""))
            cell.openTime.text = cellDic.openings["weekdays"]
            
            
            let delivery_fee = cellDic.pack_fee[indexPath.section].category["name"]!
            cell.fee.text = "\(delivery_fee) - #\(cellDic.pack_fee[indexPath.section].amount)"
            
            //let cosmosView: CosmosView = {
            //            let view = CosmosView()
            //            view.settings.updateOnTouch = false
            //            view.settings.fillMode = .precise
            //            view.settings.starSize = 15
            //            view.settings.starMargin = 2
            //            view.settings.emptyBorderColor = UIColor.lightGray
            //            let movie_rating = cellDic.rating
            //            if movie_rating != "" {
            //                view.rating = (movie_rating as NSString).doubleValue
            //            }
            //            else {
            //                view.rating = 0.0
            //            }
            //
            //
            //            view.text = movie_rating
            //            view.settings.textColor = .darkGray
            //            view.settings.textMargin = 5
            //            view.settings.textFont = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.regular)
            //            return view
            //        }()
            //
            //        cell.ratingView.addSubview(cosmosView)
            
            return cell
        }

    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if searching {
            selected_restuarant = searchData[indexPath.row]
            performSegue(withIdentifier: "goToRestaurantDetails", sender: self)
        }
        else {
            selected_restuarant = restaurant[indexPath.row]
            performSegue(withIdentifier: "goToRestaurantDetails", sender: self)
        }
    
        
    }
}



extension String{
    public func toDouble() -> Double? {
       if let num = NumberFormatter().number(from: self) {
                return num.doubleValue
            }
       else {
         return nil
        }
     }
}
