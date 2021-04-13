//
//  SignUpViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 20/04/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import CoreLocation


class SignUpViewController: UIViewController, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var buttonUI: UIButton!
    
    var label1: UILabel!
    var label2: UILabel!
    
    var labelColorForGray = UIColor.lightGray
    var labelColorForBlack = UIColor.black
    
    
    //***************************************//
    var countryDatas: [DataOBjectClass]?  = []
    var countryObject: [DataOBjectClass]? = []
    
    var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    
    //Variables for location
    var locationManager = CLLocationManager()
    var currentLocationLongitude: CLLocationDegrees!
    var currentLocationLatitude: CLLocationDegrees!
    
    
    //variables to store longlat
    var longitude: String!
    var latitude: String!
    var accountType = "personal"
    var countryName: String!
    var countryIso: String = ""
    var countryFlag: UIImage?
    var callingCode: String = ""
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        //setting up swiping of the scrollView
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
        leftSwipe.direction = UISwipeGestureRecognizer.Direction.left
        self.scrollView.addGestureRecognizer((leftSwipe))
        
        
        //setting up right scroller
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
        rightSwipe.direction = UISwipeGestureRecognizer.Direction.right
        self.scrollView.addGestureRecognizer((rightSwipe))
        
        
        
        
        frame.origin.x = scrollView.frame.size.width * CGFloat(0.0)
        //print("\(frame.origin.x) + ....when is one")
        frame.size = scrollView.frame.size
        
        label1 = UILabel(frame: frame)
        label1.text = "Personal"
        label1.textColor = labelColorForBlack
        label1.font = UIFont(name: "Muli-black", size: CGFloat(50))
        self.scrollView.addSubview(label1)
        
        
        
        
        //print(frame.origin.x)
//        frame.origin.x = scrollView.frame.size.width * CGFloat(1) - 100
//        //print("\(frame.origin.x) + ....when is two")
//        frame.size = scrollView.frame.size
//        
//        label2 = UILabel(frame: frame)
//        label2.font = label2.font.withSize(50)
//        label2.text = "Business"
//        label2.textColor = labelColorForGray
//        label2.font = UIFont(name: "Muli-black", size: CGFloat(50))
//        self.scrollView.addSubview(label2)
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
            
            if CLLocationManager.locationServicesEnabled(){
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
            }
            fetchJsonFromFile()
        
            self.activityIndicator.isHidden = true
            gottenCountry()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[locations.count - 1]
        
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            currentLocationLongitude = location.coordinate.longitude
            currentLocationLatitude = location.coordinate.latitude
            
            
            longitude = String(currentLocationLongitude)
            latitude = String(currentLocationLatitude)
            getAddress(location: location)
        }

        else{
            print("No location was gotten")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            //check  location permissions
            self.performSegue(withIdentifier: "goToFailedPermissions", sender: self)
        }
    }

    
    
    func fetchJsonFromFile() {
        
        guard let path = Bundle.main.path(forResource: "country_flag_calling_code", ofType: "json") else {
            print("NO path found");
            return
            
        }
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
    
    //================Getting User Location=============//
    ////////This method gets user location///////////
    func getAddress(location: CLLocation){
        
        let address = CLGeocoder.init()
        
        address.reverseGeocodeLocation(CLLocation.init(latitude: currentLocationLatitude, longitude: currentLocationLongitude)) { (places, error) in
            
            if error == nil{
                if let place = places{
                    
                    self.countryName = place.first!.country!
                    
                    //**********Filtering country by name from jsonFile***********//
                    self.countryObject = self.countryDatas!.filter({$0.labelText!.lowercased() == self.countryName.lowercased()})
                    
                    self.callingCode = self.countryObject![0].countryCallCode!
                    self.countryIso = self.countryObject![0].isIso!
                    
                    
                    //converting selected image to UIImage
                    let dataDecoded:NSData = NSData(base64Encoded: self.countryObject![0].imageUrl!, options: NSData.Base64DecodingOptions(rawValue: 0))!
                    let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
                    self.countryFlag = decodedimage
                    
                    if self.countryIso != "" {
                        self.stopActiveIndicator()
                    }
                    
                }
            }
            else{
                print("Cannot get location, please check to see if your wifi is turn on")
            }
        }
    }
    
    func gottenCountry() {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        buttonUI.isHidden = true
    }
    
    
    func stopActiveIndicator() {
        //**** Animate UI indicator ****/
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        self.buttonUI.isHidden = false
    }
    
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        
        ////From the alert Service
        let alertService = AlertService()
        //*********Fine a way to let the user know thier location was not gotten due to network issue********//
        if  countryIso != "" {
            performSegue(withIdentifier: "goToSVC2", sender: self)
        }
        else {
            stopActiveIndicator()
            let alertVC =  alertService.alert(alertMessage: "Error Getting location")
            self.present(alertVC, animated: true)
        }
        
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSVC2" {
            let SVC2 = segue.destination as! SignUpViewControllerPage2
            SVC2.accountType = accountType
            SVC2.latitude = latitude
            SVC2.longitude = longitude
            SVC2.calling_code = callingCode
            SVC2.Iso = countryIso
            SVC2.countryImage = countryFlag
        }
        
        
        //stopActiveIndicator()
    }
    
    func animateView() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
            self.label1.transform = CGAffineTransform(translationX: -((self.scrollView.frame.size.width) / 2), y: 0)
            self.label2.transform = CGAffineTransform(translationX: -((self.scrollView.frame.size.width) / 2 + 20), y: 0)
        })
        
    }
    
    func animateViewReverse() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
            self.label1.transform = CGAffineTransform(translationX: 0, y: 0)
            self.label2.transform = CGAffineTransform(translationX: 0, y: 0)
        })
        
    }
    
    
    @objc func swipeAction(swipe: UISwipeGestureRecognizer) {
        switch swipe.direction.rawValue {
        case 1:
            //print(swipe.direction.rawValue)
            //animateViewReverse()
            label1.textColor = labelColorForBlack
            //label2.textColor = labelColorForGray
            accountType = "personal"
            
            UserDefaults.standard.set(accountType, forKey: "account_type")
            UserDefaults.standard.synchronize()
            
        case 2:
            print(swipe.direction.rawValue)
//            animateView()
//            label1.textColor = labelColorForGray
//            label2.textColor = labelColorForBlack
//            accountType = "business"
//
//            UserDefaults.standard.set(accountType, forKey: "account_type")
//            UserDefaults.standard.synchronize()
        default:
            break
        }
    }
    
}



