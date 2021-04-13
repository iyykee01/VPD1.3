//
//  WebViewForContactsViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 04/02/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit
import WebKit

class WebViewForContactsViewController: UIViewController, WKNavigationDelegate {
    
    var url_segue = ""

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        webView.navigationDelegate = self
        activityIndicator.startAnimating()
    }
    

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let url = URL(string: url_segue)!
        let urlRequest: URLRequest = URLRequest(url: url)
        webView.load(urlRequest)
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    
}
