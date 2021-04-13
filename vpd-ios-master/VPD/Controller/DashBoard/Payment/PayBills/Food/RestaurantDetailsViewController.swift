//
//  RestaurantDetailsViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 17/12/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
//import SDWebImage
import Alamofire
import SwiftyJSON
import Cosmos

protocol callFood {
    func callFoodApi()
}

class RestaurantDetailsViewController: UIViewController, callFood {

    var from_segue: AllRestaurant!
    
    @IBOutlet weak var tableView1: UITableView!
    @IBOutlet weak var tableView2: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var checkout_button: DesignableButton!
    @IBOutlet weak var write_a_review_button: DesignableButton!
    
    var select_menu = [String]()
    var selected_food = [String]()
    
    
    var meal = [Meal]()
    var restaurant = [Restaurant]()
    var meal_pack_fee = [PackFee_meals]()
    
    
    var categories = [String]()
    
    var search_meal = [Meal]()
    
    var selected_meal =  [Meal]()
    var searching = false
    var filtered_meal = [Meal]()
    var choice = [String]()
    
    
    
    var review_array = [Review]()
    
    
    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var smallImage: UIImageView!
    @IBOutlet weak var restaurantAddress: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var restaurant_phone_number: UILabel!
    @IBOutlet weak var kmAwayLabel: UILabel!
    @IBOutlet weak var ratings: UILabel!
    @IBOutlet weak var delivery_time: UILabel!
    @IBOutlet weak var open_hours: UILabel!
    @IBOutlet weak var menu_button_outlet: UIButton!
    @IBOutlet weak var reviewButtonOutLet: UIButton!
    @IBOutlet weak var viewToMove: UIView!
    
    
    @IBOutlet weak var view_to_move: UIView!
    
    
    @IBOutlet weak var widthConstrainstLeft: NSLayoutConstraint!
    @IBOutlet weak var widthConstrainst: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkout_button.isHidden = true
        write_a_review_button.isHidden = true
        
        collectionView.allowsMultipleSelection = false
        // Do any additional setup after loading the view.
        
        tableView1.delegate = self
        tableView1.dataSource = self
        
        tableView2.delegate = self
        tableView2.dataSource = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        delayToNextPage()
        
        tableView1.rowHeight = 120
        
        tableView2.rowHeight = 130
        
        
        bannerImage!.sd_setImage(with: URL(string: from_segue.banner))
        smallImage!.sd_setImage(with: URL(string: from_segue.image))
        nameLabel.text = from_segue.name
        ratings.text = from_segue.rating
        restaurantAddress.text = from_segue.address
        
        open_hours.text = from_segue.openings["weekdays"]
        restaurant_phone_number.text = from_segue.contact["phone"]
        
        
        //For view width
        //Enable Autolayout
        viewToMove.translatesAutoresizingMaskIntoConstraints = false
        
        //Place the left side of the view to the left of the screen.
        viewToMove.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        
        //Set the width of the view. The multiplier indicates that it should be half of the screen.
        viewToMove.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        callTORestaurantReview()
    }
    
    func callFoodApi() {
        selected_meal =  [Meal]()
        delayToNextPage()
        show_checkout_button()
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
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "operation": "getmeals", "rid": from_segue._id]
        
        
        
        
        
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
        
        
        
        let url = "\(utililty.url)food"
        
        postData(url: url, parameter: parameter, token: token, header: headers)
    }
    
    
    ///////////***********Post Data MEthod*********////////
    func postData(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        activityIndicator.startAnimating()
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
                    self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = !false
                    self.meal = [Meal]()
                    self.restaurant = [Restaurant]()
                    self.meal_pack_fee = [PackFee_meals]()
                    
                    
                    for i in decriptorJson["response"].arrayValue {
                        let meal = Meal()
                        
                        meal.pack_fee.append(i["pack_fee"].stringValue)
                        meal.amount = i["amount"].stringValue
                        meal.name = i["name"].stringValue
                        meal.description = i["_id"].description
                        meal.pack = i["pack"].stringValue
                        meal.vat_amount = i["vat_amount"].stringValue
                        meal.image = i["image"].stringValue
                        meal._id = i["_id"].stringValue
                        meal.sorts = i["sorts"].stringValue
                        meal.container_amount = i["container_amount"].stringValue
                        meal.pickings.append(i["pickings"].stringValue)
                        meal.options.append(i["options"].stringValue)
                        
                        meal.category["_id"] = i["category"]["_id"].stringValue
                        meal.category["name"] = i["category"]["name"].stringValue
                        
                        if self.categories.contains(i["category"]["name"].stringValue) {
                            
                        }
                        else {
                            self.categories.append(i["category"]["name"].stringValue)
                        }
                        
                        for x in i["restaurant"].arrayValue {
                            let restaurant = Restaurant()
                            restaurant._id = x["_id"].stringValue
                            restaurant.name = x["name"].stringValue
                            
                            for j in x["pack_fee"].arrayValue {
                                let pack_meal = PackFee_meals()
                                pack_meal._id = j["_id"].stringValue
                                pack_meal.amount = j["amount"].stringValue
                                pack_meal.category = j["category"].stringValue
                                
                                self.meal_pack_fee.append(pack_meal)
                            }
                            
                            self.restaurant.append(restaurant)
                            
                        }
                        
                        for z in i["choice"]["choices"].arrayValue {
                            meal.choice.append(z.stringValue)
                        }
                        
                        self.meal.append(meal)
                        
                    }
                    self.callTORestaurantReview()
                    self.collectionView.reloadData()
                    self.tableView1.reloadData()
                }
                    
                else if (message == "Session has expired") {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    
                    ////From the alert Service
                    self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = !false
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                    
                }
            }
            else {
                self.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = !false
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
                
            }
            
        }
    }
    
    
    // MARK:- API Call to get restaurant review
    //++++++=========Delay function @if token is true move to next page+++++++===========//
    func callTORestaurantReview(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "rid": from_segue._id, "operation": "getreviews"]
        
        
        
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
        
        
        
        let url = "\(utililty.url)food"
        
        postToRestaurantReview(url: url, parameter: parameter, token: token, header: headers)
    }
    
    
    ///////////***********Post Data MEthod*********////////
    func postToRestaurantReview(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
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
                    self.activityIndicator.stopAnimating()
                    self.review_array = [Review]()
                    
                    
                    for i in decriptorJson["response"].arrayValue {
                        let new_review = Review()
                        
                        
                        new_review.name = i["name"].stringValue
                        new_review.headline = i["headline"].description
                        new_review.message = i["message"].stringValue
                        new_review.rating = i["rating"].stringValue
                      
                        new_review.date = i["date"].stringValue
                    
                        self.review_array.append(new_review)
                    }
                    
                    self.collectionView.reloadData()
                    self.tableView1.reloadData()
                    self.tableView2.reloadData()
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
    
    
    
    func show_checkout_button () {
        
        if selected_meal.count == 0 {
            checkout_button.isHidden = !false
        }
            
        else {
            checkout_button.isHidden = !true
        }
    }
    
    
    
    @IBAction func menuButtonPressed(_ sender: Any) {
        reviewButtonOutLet.setTitleColor(.gray, for: .normal)
        menu_button_outlet.setTitleColor(UIColor(hexFromString: "#34B5CE"), for: .normal)
        
        
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
            
            if self.selected_meal.count == 0 {
                self.checkout_button.isHidden = true
            }
            else {
                self.checkout_button.isHidden = false
            }
            
            self.write_a_review_button.isHidden = true
            self.tableView1.alpha = 1
            self.tableView1.isHidden = false
            self.tableView2.alpha = 0
            self.tableView2.isHidden = true
            self.collectionView.isHidden = false
            
            
            self.viewToMove.frame.origin.x = 0;
            self.view.layoutIfNeeded()
        });
    }
    
    @IBAction func ReviewButtonPressed(_ sender: Any) {
        
        menu_button_outlet.setTitleColor(.gray, for: .normal)
        
        
        reviewButtonOutLet.setTitleColor(UIColor(hexFromString: "#34B5CE"), for: .normal)
        
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
            
            self.checkout_button.isHidden = true
            self.write_a_review_button.isHidden = false
            self.tableView1.alpha = 0
            self.tableView1.isHidden = true
            self.tableView2.isHidden = false
            self.tableView2.alpha = 1
            self.collectionView.isHidden = true
            
            //self.tableView2.frame.origin.x += 0
            
            self.viewToMove.frame.origin.x = self.view.frame.size.width / 2;
            self.view.layoutIfNeeded()
        });
        
        
    }
    
    
    @IBAction func placeOrderButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToCheckOut", sender: self)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitReviewButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "goToReview", sender: self)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ==  "goToCheckOut" {
            let destination = segue.destination as! CheckoutViewController
            destination.choosen_meal = selected_meal
            destination.rid = from_segue._id
            destination.delegate = self
        }
        
        if segue.identifier ==  "goToReview" {
            let destination = segue.destination as! WriteAReviewViewController
            destination.restuarnat_id = from_segue._id
        }
    }
    
}

extension RestaurantDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let collectionViewWidth = collectionView.bounds.width
        return CGSize(width: collectionViewWidth / 2.5, height: collectionViewWidth / 2.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FoodMenuCellCollectionViewCell
        
        cell.labelForCell.text = categories[indexPath.row]
        
        if select_menu.count == 1 && select_menu[0] == categories[indexPath.row] {
            
            cell.viewbackground.backgroundColor = UIColor(hexFromString: "#34B5CE")
            cell.labelForCell.textColor = .white
        }
            
        else {
            cell.viewbackground.backgroundColor = .white
            cell.labelForCell.textColor = UIColor(hexFromString: "#34B5CE")
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let item = categories[indexPath.row]
        
        if select_menu.count == 0 {
            select_menu.append(item)
        }
        
        if select_menu.count == 1 {
            select_menu = [String]()
            select_menu.append(item)
        }
        
        searching = true
        search_meal = meal.filter{ $0.category["name"] == item }
        
        collectionView.reloadData()
        tableView1.reloadData()
    }
    
}





extension RestaurantDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == tableView1 && searching {
            return search_meal.count
        }
        
        if tableView == tableView1 {
            return meal.count
        }
            
        else {
            return review_array.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        if tableView == tableView1 && searching {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MealTableViewCell
            
            cell.selectionStyle = .none
            
            cell.meal_name.text = search_meal[indexPath.row].name
            cell.meal_price.text = "NGN\(search_meal[indexPath.row].amount)"
            
            cell.menuImage!.sd_setImage(with: URL(string: search_meal[indexPath.row].image))
            
            if search_meal[indexPath.row].is_selected {
                cell.plusImage.image = UIImage(named: "white_checked")
            }
            else {
                cell.plusImage.image = UIImage(named: "plus")
            }
            
            return cell
        }
        
        
        if tableView == tableView1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MealTableViewCell
            
            let dictionary = meal[indexPath.row]
            
            cell.meal_name.text = dictionary.name
            cell.meal_price.text = "NGN\(dictionary.amount)"
            
            cell.menuImage!.sd_setImage(with: URL(string: dictionary.image))
            
            if dictionary.is_selected {
                cell.plusImage.image = UIImage(named: "white_checked")
            }
            else {
                cell.plusImage.image = UIImage(named: "plus")
            }
            
            return cell
        }
            
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ReviewTableViewCell
            cell.selectionStyle = .none
            
            let dictionary = review_array[indexPath.row]
            
            cell.body.text = dictionary.message
            cell.header.text = dictionary.headline
            
            let date = dictionary.date
            
            
            cell.hours.text = String(date).toDate().timeAgoSinceDate()
            cell.name.text = dictionary.name
            cell.thumbnail_image.image = UIImage(named: "image")
            
            return cell
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if tableView == tableView1 && searching {
            
            let selected_row = search_meal[indexPath.row]
            selected_row.is_selected = !selected_row.is_selected
            
            if selected_meal.count == 0 {
                selected_meal.append(selected_row)
            }
                
                
            else if selected_meal.count != 0 {
                let new_filter = selected_meal.filter({$0._id == selected_row._id})
                
                if new_filter.count == 0 {
                    selected_meal.append(selected_row)
                }
                else {
                    selected_meal = selected_meal.filter({$0._id != selected_row._id})
                }
            }
        }
            
        else {
            
            let selected_row = meal[indexPath.row]
            selected_row.is_selected = !selected_row.is_selected
            
            if selected_meal.count == 0 {
                selected_meal.append(selected_row)
            }
                
                
            else if selected_meal.count != 0 {
                let new_filter = selected_meal.filter({$0._id == selected_row._id})
                
                if new_filter.count == 0 {
                    selected_meal.append(selected_row)
                }
                else {
                    selected_meal = selected_meal.filter({$0._id != selected_row._id})
                }
            }
        }
        
        tableView.reloadData()
        show_checkout_button()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension Date {

    func timeAgoSinceDate() -> String {

        // From Time
        let fromDate = self

        // To Time
        let toDate = Date()

        // Estimation
        // Year
        if let interval = Calendar.current.dateComponents([.year], from: fromDate, to: toDate).year, interval > 0  {

            return interval == 1 ? "\(interval)" + " " + "year ago" : "\(interval)" + " " + "years ago"
        }

        // Month
        if let interval = Calendar.current.dateComponents([.month], from: fromDate, to: toDate).month, interval > 0  {

            return interval == 1 ? "\(interval)" + " " + "month ago" : "\(interval)" + " " + "months ago"
        }

        // Day
        if let interval = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day, interval > 0  {

            return interval == 1 ? "\(interval)" + " " + "day ago" : "\(interval)" + " " + "days ago"
        }

        // Hours
        if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: toDate).hour, interval > 0 {

            return interval == 1 ? "\(interval)" + " " + "hour ago" : "\(interval)" + " " + "hours ago"
        }

        // Minute
        if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: toDate).minute, interval > 0 {

            return interval == 1 ? "\(interval)" + " " + "minute ago" : "\(interval)" + " " + "minutes ago"
        }

        return "a moment ago"
    }
}

extension String {
  func toDate(withFormat format: String = "yyyy-MM-dd HH:mm:ss") -> Date {
    
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    guard let date = dateFormatter.date(from: self) else {
      //preconditionFailure("Take a look to your format")
        
        return Date()
    }
    return date
  }
}




