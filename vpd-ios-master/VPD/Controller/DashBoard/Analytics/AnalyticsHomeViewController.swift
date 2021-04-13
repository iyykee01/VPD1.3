//
//  AnalyticsHomeViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 24/01/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import Charts

class AnalyticsHomeViewController: UIViewController {
    
    @IBOutlet weak var tableVIew: UITableView!
    
    @IBOutlet weak var circularProgress: CircularProgressBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    private var lastContentOffset: CGFloat = 0.0
    let overall_percentage = Float(100)
    
    
    @IBOutlet weak var pieChart: PieChartView!
    var topup = PieChartDataEntry(value: 0);
    var food = PieChartDataEntry(value: 0);
    var transfer = PieChartDataEntry(value: 0);
    var bill = PieChartDataEntry(value: 0);
    var entertainment = PieChartDataEntry(value: 0);
    var none = PieChartDataEntry(value: 100);
    var downDataEntries = [PieChartDataEntry]()
    
    
    @IBOutlet weak var pieAmountLabel: UILabel!
    @IBOutlet weak var pieMonthLabel: UILabel!
    
    
    @IBOutlet weak var yearTotalAmount: UILabel!
    @IBOutlet weak var averageMonthlyAmount: UILabel!
    
    @IBOutlet weak var forTopup: UILabel!
    @IBOutlet weak var forFood: UILabel!
    @IBOutlet weak var forTransfer: UILabel!
    @IBOutlet weak var forbill: UILabel!
    @IBOutlet weak var forEntertainment: UILabel!
    
    
    @IBOutlet weak var deviceImage: UIImageView!
    @IBOutlet weak var forkImage: UIImageView!
    @IBOutlet weak var transferImage: UIImageView!
    @IBOutlet weak var payImage: UIImageView!
    @IBOutlet weak var popcornImage: UIImageView!
    
    
    
    var category_array = [Category]()
    var select_category: Category!
    var selected_image = ""
    var wallet_id = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableVIew.rowHeight = 80
        tableVIew.delegate = self
        tableVIew.dataSource = self
        
//        deviceImage.isHidden = true
//        forkImage.isHidden = true
//        transferImage.isHidden = true
//        payImage.isHidden = true
//        popcornImage.isHidden = true
//
//        forTopup.isHidden = true
//        forFood.isHidden = true
//        forTransfer.isHidden = true
//        forbill.isHidden = true
//        forEntertainment.isHidden = true
        
        wallet_id = UserDefaults.standard.string(forKey: "wallet_id")!
        pieChart.chartDescription?.text = ""
        pieChart.holeColor = UIColor.clear
        pieChart.holeRadiusPercent = 0.85
        pieChart.legend.enabled = false
        pieChart.rotationEnabled = false
        pieChart.animate(xAxisDuration: 1)
        
        topup.value = topup.value
        food.value = food.value
        transfer.value = transfer.value
        bill.value = bill.value
        entertainment.value = entertainment.value
        
        downDataEntries = [entertainment, food, transfer, topup, bill];
        analyticAPICall()
        updateDataEntry()
        
        
            self.payImage.alpha = 0
            self.forbill.alpha = 0

            self.deviceImage.alpha = 0
            self.forTopup.alpha = 0

            self.forkImage.alpha = 0
            self.forFood.alpha = 0

            self.transferImage.alpha = 0
            self.forTransfer.alpha = 0

            self.forEntertainment.alpha = 0
            self.popcornImage.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animateImages()
    }
    
    func animateImages(){
        UIView.animate(withDuration: 0.5, animations: {
            self.payImage.alpha = 1
            self.forbill.alpha = 1
        }) { (completed) in
            UIView.animate(withDuration: 0.5, animations: {
                self.deviceImage.alpha = 1
                self.forTopup.alpha = 1
            }) { (completed) in
                UIView.animate(withDuration: 0.5, animations: {
                    self.forkImage.alpha = 1
                    self.forFood.alpha = 1
                }) { (completed) in
                    UIView.animate(withDuration: 0.5, animations: {
                        self.transferImage.alpha = 1
                        self.forTransfer.alpha = 1
                    }) { (completed) in
                        //Completion of whole animation sequence
                        UIView.animate(withDuration: 0.5, animations: {
                            self.forEntertainment.alpha = 1
                            self.popcornImage.alpha = 1
                        }) { (completed) in
                            
                        }
                    }
                }
            }
        }
    }
    
    
    
    func send_other_to_last() {
        
        let categories2 = category_array.filter({$0.type == "others"})
        
        category_array = category_array.filter({$0.type != "others"})
        
        for i in categories2 {
            category_array.insert(i, at: 5)
        }
        tableVIew.reloadData()
    }
    
    func updateDataEntry() {
        
        let chartDataSet = PieChartDataSet(entries: downDataEntries, label: nil);
        chartDataSet.drawValuesEnabled = false
        chartDataSet.highlightColor = .clear
        
        
        let chartData = PieChartData(dataSet: chartDataSet);
        
        let colors = [UIColor(hexFromString: "#01DCFF"), UIColor(hexFromString: "#EEFF01"), UIColor(hexFromString: "#01FF2B"), UIColor(hexFromString: "#FF0180"), UIColor(hexFromString: "#FF8000"), .white ];
        chartDataSet.colors = colors ;
        pieChart.data = chartData
    }
    
    
    
    
    //MARK: ******* Analytics API Call******///
    func analyticAPICall(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "SessionID": session, "CustomerID": customer_id, "operation": "summary", "wallet": wallet_id]
        
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
        
        
        let url = "\(utililty.url)analytics"
        
        analyticsApiCall(url: url, parameter: parameter, token: token, header: headers)
    }
    
    //MARK: Get Electricity Providers
    ///////////***********Post Data MEthod*********////////
    func analyticsApiCall(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = true
        
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
                    self.activityIndicator.stopAnimating()
                    
                    let des = decriptorJson["response"]
                    
                    self.yearTotalAmount.text = "NGN\(des["year_total"].stringValue)"
                    
                    self.averageMonthlyAmount.text = "NGN\(des["month_average"].stringValue)"
                    
                    if des["category"]["transfer"]["percentage"].doubleValue == 0 &&
                        des["category"]["bill"]["percentage"].doubleValue == 0 &&
                        des["category"]["food"]["percentage"].doubleValue == 0 &&
                        des["category"]["entertainment"]["percentage"].doubleValue == 0 && des["category"]["topup"]["percentage"].doubleValue == 0 {
                        
                        self.downDataEntries.append(self.none)
                        
                    }
                    
                    
                    self.transfer.value =  des["category"]["transfer"]["percentage"].doubleValue;
                    self.bill.value = des["category"]["bill"]["percentage"].doubleValue
                    self.food.value = des["category"]["food"]["percentage"].doubleValue
                    self.entertainment.value = des["category"]["entertainment"]["percentage"].doubleValue
                    self.topup.value = des["category"]["topup"]["percentage"].doubleValue
                    
                    
                    self.forTopup.text = "\(des["category"]["topup"]["percentage"].stringValue)%"
                    self.forbill.text = "\(des["category"]["bill"]["percentage"].stringValue)%"
                    self.forFood.text = "\(des["category"]["food"]["percentage"].stringValue)%"
                    self.forTransfer.text = "\(des["category"]["transfer"]["percentage"].stringValue)%"
                    self.forEntertainment.text = "\(des["category"]["entertainment"]["percentage"].stringValue)%"
                    
                    self.pieMonthLabel.text = des["this_month"].stringValue
                    self.pieAmountLabel.text = "N\(des["this_month_total"].stringValue).00"
                    
                    self.category_array = [Category]()
                    
                    for i in des["category"].dictionaryValue {
                        
                        let new_grouped = Category()
                        
                        if i.key == "food" {
                            
                            new_grouped.count = i.value["count"].stringValue
                            new_grouped.amount = i.value["amount"].stringValue
                            new_grouped.percentage = i.value["percentage"].stringValue
                            new_grouped.type = "food"
                            
                            self.category_array.append(new_grouped)
                        }
                        if i.key == "transfer" {
                            
                            new_grouped.count = i.value["count"].stringValue
                            new_grouped.amount = i.value["amount"].stringValue
                            new_grouped.percentage = i.value["percentage"].stringValue
                            new_grouped.type = "transfer"
                            
                            self.category_array.append(new_grouped)
                        }
                        
                        if i.key == "topup" {
                            
                            new_grouped.count = i.value["count"].stringValue
                            new_grouped.amount = i.value["amount"].stringValue
                            new_grouped.percentage = i.value["percentage"].stringValue
                            new_grouped.type = "topup"
                            
                            self.category_array.append(new_grouped)
                        }
                        
                        if i.key == "bill" {
                            
                            new_grouped.count = i.value["count"].stringValue
                            new_grouped.amount = i.value["amount"].stringValue
                            new_grouped.percentage = i.value["percentage"].stringValue
                            new_grouped.type = "bill"
                            
                            self.category_array.append(new_grouped)
                        }
                        if i.key == "entertainment" {
                            
                            new_grouped.count = i.value["count"].stringValue
                            new_grouped.amount = i.value["amount"].stringValue
                            new_grouped.percentage = i.value["percentage"].stringValue
                            new_grouped.type = "entertainment"
                            
                            self.category_array.append(new_grouped)
                        }
                        if i.key == "others" {
                            
                            new_grouped.count = i.value["count"].stringValue
                            new_grouped.amount = i.value["amount"].stringValue
                            new_grouped.percentage = i.value["percentage"].stringValue
                            new_grouped.type = "others"
                            
                            self.category_array.append(new_grouped)
                        }
                        
                    }
                }
                    
                else if (message == "Session has expired") {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                    
                else {
                    self.view.isUserInteractionEnabled = true
                    ////From the alert Service
                    self.activityIndicator.stopAnimating()
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                    
                }
            }
            else {
                self.view.isUserInteractionEnabled = true
                self.activityIndicator.stopAnimating()
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
            }
            self.send_other_to_last()
            self.tableVIew.reloadData()
            self.updateDataEntry()
        }
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! AnalyticDetailsViewController
        destination.category_from_segue = select_category
        destination.image_string = selected_image
        destination.wallet_id = wallet_id
    }
}


extension AnalyticsHomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return category_array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AnalyticsCategoriesTableViewCell
        
        cell.selectionStyle = .none
        
        let dictionary = category_array[indexPath.row]
        
        
        //cell.image_transaction.image = UIImage(named: dictionary["image"] ?? "")
        
        
        if dictionary.type == "food" {
            cell.image_transaction.image = UIImage(named: "fork")
            cell.category_name.text = "Food Purchase"
            cell.progressBar.progressTintColor = UIColor(hexFromString: "#EEFF01")
        }
            
        else if dictionary.type == "bill" {
            cell.image_transaction.image = UIImage(named: "pay")
            cell.category_name.text = "Utility Bills"
            cell.progressBar.progressTintColor = UIColor(hexFromString: "#FF0180")
        }
            
        else if dictionary.type == "topup" {
            cell.image_transaction.image = UIImage(named: "device")
            cell.category_name.text = "Mobile Topup"
            cell.progressBar.progressTintColor = UIColor(hexFromString: "#01DCFF")
        }
            
        else if dictionary.type == "entertainment" {
            cell.image_transaction.image = UIImage(named: "popcorn")
            cell.category_name.text = "Entertainment"
            cell.progressBar.progressTintColor = UIColor(hexFromString: "#FF8710")
        }
            
        else if dictionary.type == "transfer" {
            cell.image_transaction.image = UIImage(named: "transfer1")
            cell.category_name.text = "Fund Transfer"
            cell.progressBar.progressTintColor = UIColor(hexFromString: "#01FF2B")
        }
            
        else {
            cell.image_transaction.image = UIImage(named: "others")
            cell.category_name.text = "Others"
            cell.progressBar.progressTintColor = UIColor(hexFromString: "#5DB2CB")
        }
        
        cell.amount.text = "NGN\(dictionary.amount)"
        cell.percentage.text = "\(dictionary.percentage)%"
        
        
        let dic_progres_to_int = Float(dictionary.percentage)
        cell.progressBar.progress = dic_progres_to_int! / overall_percentage
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dictionary = category_array[indexPath.row]
        select_category = dictionary
        
        if dictionary.type == "food" {
            selected_image = "fork"
            performSegue(withIdentifier: "goToAnalyticsDetails", sender: self)
        }
            
        else if dictionary.type == "bill" {
            selected_image = "pay"
            performSegue(withIdentifier: "goToAnalyticsDetails", sender: self)
        }
            
        else if dictionary.type == "topup" {
            selected_image = "device"
            performSegue(withIdentifier: "goToAnalyticsDetails", sender: self)
        }
            
        else if dictionary.type == "entertainment" {
            selected_image = "popcorn"
            performSegue(withIdentifier: "goToAnalyticsDetails", sender: self)
        }
            
        else if dictionary.type == "transfer" {
            selected_image = "transfer1"
            performSegue(withIdentifier: "goToAnalyticsDetails", sender: self)
        }
            
        else {
            print("none")
            // create the alert
            //            let alert = UIAlertController(title: " ", message: "No transaction for the month", preferredStyle: UIAlertController.Style.alert)
            //
            //            // add an action (button)
            //            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            //
            //            // show the alert
            //            self.present(alert, animated: true, completion: nil);
        }
        
        
    }
    
}


