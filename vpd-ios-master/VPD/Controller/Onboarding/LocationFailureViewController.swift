//
//  LocationFailureViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 19/02/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit
import CoreLocation

class LocationFailureViewController: UIViewController {
    
    //Variables for location
    var locationManager = CLLocationManager()
    var currentLocationLongitude: CLLocationDegrees!
    var currentLocationLatitude: CLLocationDegrees!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
    
    //check location services enabled or not
    
    func checkLocationPermission() {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                //open setting app when location services are disabled
                openSettingApp()
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
            @unknown default:
                print("nil")
            }
        } else {
            print("Location services are not enabled")
            openSettingApp()
        }
    }
    
    //open location settings for app
    func openSettingApp() {
        
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        }
    }
    
    
    @IBAction func permissionsButtonPressed(_ sender: Any) {
        checkLocationPermission()
    }
    
    
    @IBAction func retryButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
