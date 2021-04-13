//
//  WebViewViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 25/07/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import SwiftyJSON

class WebViewViewController: UIViewController, WKNavigationDelegate {
    
    
    var url = ""
    var transactionID = ""
    var call = ""
    var success_message = ""

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingLable: UILabel!
   
    
    
    ////From the alert Service
    let alertService = AlertService()
    let successService = SuccessService()
    /******Import  and initialize Util Class*****////
    var utililty = UtilClass()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let description = "<p> HTML content <p>"
        var headerString = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0'></header>"
        headerString.append(description)
        self.webView.loadHTMLString("\(headerString)", baseURL: nil) 
        
        webView.navigationDelegate = self
        
        activityIndicator.startAnimating()
        loadingLable.isHidden = true
        
        webView.contentScaleFactor = 2.0
        
        let web_url = URL(string: url)
        let request = URLRequest(url: web_url!)
        webView.load(request)
        
    }
  
    
    //++++++=========Delay function @if token is true move to next page+++++++===========//
    func delayToNextPage(){
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "getStatus": transactionID]
        
        
        
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
        
        let url = "\(utililty.url)wallet_funding"
        
        if call == "1" {
            postData(url: url, parameter: parameter, token: token, header: headers)
        }
        else {
            print("Call is still Zero...................")
            call = "1"
        }

    }
    
    ///////////***********Post Data MEthod*********////////
    func postData(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        
        activityIndicator.startAnimating()
        loadingLable.isHidden = false
        
        
        Alamofire.request(url, method: .post, parameters: parameter, headers: header).responseJSON {
            response in
            if response.result.isSuccess {
                print("SUCCESSFUL.....")
                
                //******Getting Data******//
                let data: JSON = JSON(response.result.value!)
                
                //****Decode json hear****/
                let hexKey = data["reqResponse"].stringValue
                
                //********decripting Hex key**********//
                let decriptor = self.utililty.convertHexStringToString(text: hexKey)
                
                //**********Changing Data back to Json format***///
                let jsonData = decriptor.data(using: .utf8)!
                
                let decriptorJson: JSON = JSON(jsonData)
                print(decriptorJson)
                
                
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                
                
                if(status) {
                    //********Response from server *******//
                    
                    self.activityIndicator.stopAnimating()
                    self.loadingLable.isHidden = true
                    
                    self.success_message = message
                    let alertSV = SuccessAlertTransaction()
                    let alert = alertSV.alert(success_message: message) {
                        guard let VCS = self.navigationController?.viewControllers else {return }
                        for controller in VCS {
                            if controller.isKind(of: TabBarViewController.self) {
                                let tabVC = controller as! TabBarViewController
                                tabVC.selectedIndex = 0
                                self.navigationController?.popToViewController(ofClass: TabBarViewController.self, animated: true)
                                
                            }
                        }
                    }
                    self.present(alert, animated: true)
                }
                
                else if (message == "Session has expired") {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.activityIndicator.stopAnimating()
                    self.loadingLable.isHidden = true
                    
                    if self.call == "1" {
                        let alertVC =  self.alertService.alert(alertMessage: message)
                        self.present(alertVC, animated: true)
                        self.navigationController?.popToViewController(ofClass: WalletFundingWithCardViewController.self, animated: true)
                    }
                    
                }
            }
            else {
                self.activityIndicator.stopAnimating()
                self.loadingLable.isHidden = true
                let alertVC =  self.alertService.alert(alertMessage: "Connection Timed Out")
                self.present(alertVC, animated: true);
            }
        }
    }
    
    
    func goDashboard() {
        self.performSegue(withIdentifier: "backToDashBoard", sender: self)
    }
    
    
    //MARK:- WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
         print("I was started with loaded............")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard !webView.isLoading else{
            return
        }
        activityIndicator.stopAnimating()
        print(" i got called")
        delayToNextPage()
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        let alertVC =  self.alertService.alert(alertMessage: "OPPS \n Something went wrong!!!")
        self.present(alertVC, animated: true)
        navigationController?.popViewController(animated: true)
    }


    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
