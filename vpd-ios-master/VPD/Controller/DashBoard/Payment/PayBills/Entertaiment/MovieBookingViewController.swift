//
//  MovieBookingViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 27/09/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


struct MovieBooking: Codable {
    var ticketid: String
    var quantity: String
}


struct paramToforCinema: Codable {
    var AppID : String
    var language : String
    var RequestID : String
    var SessionID: String
    var CustomerID: String
    var operation: String
    var wallet: String
    var cid: String
    var mid: String
    var showtimeID: String
    var tickets: [MovieBooking]
    var transaction_pin: String
    var auth_key: String
}

class MovieBookingViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var viewWrap: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btn: DesignableButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var convenienceFeeLabel: UILabel!
    
    var from_segue = [TicketType]()
    var movie_selected: MovieCategory!
    var showTime = [ShowTime]()
    
    
    
    var ticket_id = ""
    var select_row_count = ""
    var count_check = 0
    var price = 0
    var cid = ""
    var mid = ""
    var showtimeID = ""
    var success_message = ""
    var transaction_face = face
    
    var picked_tickets = [String: String]()
    var picked_tickets_post = [MovieBooking]()
    
    var selected_ticket = [TicketType]()
    let walletId = currentWalletSelected["walletId"]
    
    @IBOutlet weak var vpdPinTextLabel: UILabel!
    @IBOutlet weak var vpdPinTextField: UITextField!
    
    
    var fee_for_trans = LoginResponse["response"]["charges"]["movie_convenience_fee"]["NGN"]["value"].stringValue
    
    var vpdPin = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Do any additional setup after loading the view.
        convenienceFeeLabel.text = "You'll be charged NGN\(fee_for_trans) convenience fee for this."
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        
        vpdPinTextField.setLeftPaddingPoints(14)
        vpdPinTextField.delegate = self;
        
        
        collectionView.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
        
        price = Int(from_segue[0].price)!
        
    
        //Set up for show time
        shuffle()
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .black
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.donePicker))

        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
    
        vpdPinTextField.inputAccessoryView = toolBar;
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillChange(notification:)), name:
        UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    @objc func donePicker(datePicker: UIDatePicker) {
        view.endEditing(true)
        vpdPin = vpdPinTextField.text!
        view.frame.origin.y = 0
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    
    @objc func keyboardwillChange(notification: Notification) {
        
        guard   let userInfo = notification.userInfo as? [String: NSObject],
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect  else { return }
        
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification  {
            view.frame.origin.y = -keyboardFrame.height
        }
        else {
            view.frame.origin.y = 0
        }
        
    }
    
 
    
    func shuffle () {
        let movie_selected_1 = movie_selected.showtime.filter({$0.showtimeID != showtimeID})
        
        let movie_selected_true = movie_selected.showtime.filter({$0.showtimeID == showtimeID})
        
        showTime = movie_selected_1
        
        for i in movie_selected_true {
            showTime.insert(i, at: 0)
        }
        
    }
    
    func ticket (obj: [TicketType]) {
        picked_tickets = [String: String]()
        for i in obj {
            let picked_tickets = MovieBooking(
                ticketid: i.ticketID,
                quantity: String(i.count)
            )
            picked_tickets_post.append(picked_tickets)
        }
    }
    
    @IBAction func dismissPopup(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func purchaseMovieAPI(){
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        if UserDefaults.standard.object(forKey: "authKey") != nil && transaction_face  {
            global_key = UserDefaults.standard.string(forKey: "authKey")!
        }
        
        let params = paramToforCinema(
            AppID: device.sha512,
            language: "en",
            RequestID: timeInSecondsToString,
            SessionID: session,
            CustomerID: customer_id,
            operation: "purchase",
            wallet: walletId ?? "",
            cid: cid,
            mid: mid,
            showtimeID: showtimeID,
            tickets: picked_tickets_post,
            transaction_pin: vpdPin,
            auth_key: global_key
        )

        
        
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
        
        
        let url = "\(utililty.url)movies"
        
        postData2(url: url, parameter: parameter, token: token, header: headers)
        global_key = ""
        isUserFace = false
    }
    
    ///////////***********Post Data MEthod*********////////
    func postData2(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        self.view.isUserInteractionEnabled = false
        self.btn.isHidden = true
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
                
                
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                
                
                
                if(status) {
                    self.view.isUserInteractionEnabled = true
                    self.btn.isHidden = false
                    self.activityIndicator.stopAnimating()
                    //********Response from server *******//
                    self.success_message = message
                    
                    let alertSV = SuccessAlertTransaction()
                    let alert = alertSV.alert(success_message: message) {
                        self.navigationController?.popToViewController(ofClass: ServicesViewController.self)
                    }
                    self.present(alert, animated: true)
                }
                    
                else if  message == "Session has expired" {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.view.isUserInteractionEnabled = true
                    self.btn.isHidden = false
                    self.activityIndicator.stopAnimating()
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.view.isUserInteractionEnabled = true
                self.btn.isHidden = false
                self.activityIndicator.stopAnimating()
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
            }
        }
    }
    
    
    @IBAction func confirmAndPay(_ sender: Any) {
        vpdPin = vpdPinTextField.text!
        
        if vpdPin == "" || walletId == "" {
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "Please fill all fields")
            self.present(alertVC, animated: true)
        }
        
        if walletId == "" {
            let alertService = AlertService()
            let alertVC =  alertService.alert(alertMessage: "Please Select Wallet currency")
            self.present(alertVC, animated: true)
            return
        }
        
        if count_check == 0 {
            ticket(obj: selected_ticket)
            vpdPin = vpdPinTextField.text!
            purchaseMovieAPI()
            count_check = 1
        }
        else {
            picked_tickets_post = [MovieBooking]()
            count_check = 1
            ticket(obj: selected_ticket)
            
            if transaction_face && isUserFace == false {
                let alertSV = FaceID()
                let alert = alertSV.showFaceID()
                self.present(alert, animated: true)
            }
            else {
                purchaseMovieAPI()
            }
            
        }
    }
}

extension MovieBookingViewController: handleMaths {
    func subtract(counter: Int) {
        
        if from_segue[counter].count >= 1 {
            from_segue[counter].count = from_segue[counter].count - 1
        }
        
        if from_segue[counter].count == 1 {
            from_segue[counter].price = String(price)
        }
        
        if from_segue[counter].count > 1 {
            from_segue[counter].price = String(Int(from_segue[counter].price)! - price)
        }
        
        if from_segue[counter].count == 0 && selected_ticket.count >= 1 {
            for (index, i) in selected_ticket.enumerated().reversed() {
                if (i.ticketID == from_segue[counter].ticketID) {
                    selected_ticket.remove(at: index)
                    
                }
            }
        }
        
        tableView.reloadData()
    }
    
    func addition(counter: Int) {
        //selected_ticket.append(from_segue[counter])
        
        from_segue[counter].count = from_segue[counter].count + 1
        
        if from_segue[counter].count == 1 {
            from_segue[counter].price = String(price)
            selected_ticket.append(from_segue[counter])
        }
        
        if from_segue[counter].count > 1 {
            /// first check if  movie is already in seleted_ticket array
            for i in selected_ticket {
                if i.ticketID == from_segue[counter].ticketID {
                    i.price = String(Int(from_segue[counter].price)! + price)
                }
            }
        }
        
        tableView.reloadData()
    }
    
}

extension MovieBookingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 45)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return showTime.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TicketTypeCollectionViewCell
        
        let dic =  showTime[indexPath.row]
        
  
        let date = Date.dateFromCustom(customString: dic.date)
        let customDate = Date.dateFormaterMonth(date: date)
        
        
        print(customDate)
        
        let split_date = customDate.split(separator: " ")
        
        
        if split_date[0] == "1" {
            cell.timeLabel.text = "\(split_date[1]) \(split_date[0])st, \(dic.time)"
        }
        else {
            cell.timeLabel.text = "\(split_date[1]) \(split_date[0])th, \(dic.time)"
        }
        
        if showtimeID == dic.showtimeID {
            cell.viewToColor.backgroundColor = UIColor(hexFromString: "#34B5CE")
        }
        else {
            cell.viewToColor.backgroundColor = .darkGray
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selected_row = showTime[indexPath.row]
        from_segue = selected_row.ticketType
        showtimeID = selected_row.showtimeID
        
         collectionView.reloadData()
         tableView.reloadData()
    }
    
}


extension MovieBookingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return from_segue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CinemaTableViewCell
        
        cell.selectionStyle = .none
        
        let dic = from_segue[indexPath.row]
        
        
        if indexPath.row == 1 || indexPath.row == 2  {
            cell.viewColor.backgroundColor = .darkGray
        }
        
        cell.cinema_country.text = dic.group
        cell.cinemaLabel_location.text = dic.price
        cell.count_label.text = String(dic.count)
        cell.cellDelegate = self
        cell.index = indexPath
        
        
        return cell
    }
}
