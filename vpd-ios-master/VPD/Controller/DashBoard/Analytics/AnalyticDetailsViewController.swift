//
//  AnalyticDetailsViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 24/01/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit
import SwiftCharts
import SwiftyJSON
import Alamofire
import Charts

class AnalyticDetailsViewController: UIViewController {
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var percentage: UILabel!
    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var total_amount: UILabel!
    @IBOutlet weak var second_label_amount: UILabel!
    @IBOutlet weak var upImage: UIImageView!
    
    
    @IBOutlet weak var view_of_view: UIView!
    //var chartView: BarsChart!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var percentage_text: UILabel!
    @IBOutlet weak var categoryType: UILabel!
    
    let overall_percentage = Float(100);
    
    weak var axisFormatDelegate: IAxisValueFormatter?
    
    @IBOutlet weak var lineChart: LineChartView!
    var analytics = [(String, Double)]()
    
    var months = [String]()
    var unitsSold = [Double]()
    
    
    
    var category = [TransactionHistory]()
    var group_transaction2 = [[TransactionHistory]]()
    
    var select_transaction: [TransactionHistory] = []
    
    
    var category_from_segue: Category!
    var image_string = ""
    var wallet_id = ""
    
    
    var average = ""
    var last_month_compare_percent = ""
    var state = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.delegate = self
        tableview.dataSource = self
        
        tableview.rowHeight = 60
        
        progressBar.transform = progressBar.transform.scaledBy(x: 1, y: 1.9);
        progressBar.layer.cornerRadius = 6
        progressBar.clipsToBounds = true
        
        // Do any additional setup after loading the view.
        imageView.image = UIImage(named: image_string)
        
        type.text = category_from_segue.type.capitalized
        categoryType.text = category_from_segue.type.capitalized
        percentage.text = "\(category_from_segue.percentage)%"
        
        let dic_progres_to_int = Float(category_from_segue.percentage)
        progressBar.progress = dic_progres_to_int! / overall_percentage
        
        
        amount.text = "NGN \(category_from_segue.amount)"
        
        
        categoryCheck()
        analyticAPICall()
        
        axisFormatDelegate = self
        
        lineChart.rightAxis.enabled = false
        
        lineChart.leftAxis.axisMinimum = 0
        let yAxis = lineChart.leftAxis
        yAxis.axisLineColor = .lightGray
        yAxis.labelFont = .boldSystemFont(ofSize: 10)
        yAxis.labelTextColor = .darkGray
        yAxis.axisLineDashLengths = [8.0, 4.0]
        yAxis.gridColor = .lightGray
        yAxis.gridLineDashLengths = [8.0, 4.0]
        yAxis.gridLineWidth = (0.2)
        
        lineChart.xAxis.labelPosition = .bottom
        lineChart.xAxis.labelFont = .boldSystemFont(ofSize: 9)
        lineChart.xAxis.axisLineDashLengths = [8.0, 4.0]
        lineChart.xAxis.setLabelCount(5, force: false);
        lineChart.xAxis.axisLineColor = .lightGray
        lineChart.xAxis.labelTextColor = .darkGray
        lineChart.xAxis.gridColor = .lightGray
        lineChart.animate(xAxisDuration: 1)
        lineChart.xAxis.gridLineDashLengths = [8.0, 4.0]
        lineChart.xAxis.gridLineWidth = (0.2)
        lineChart.legend.enabled = false
        
    }
    
    func categoryCheck() {
        
        if image_string == "fork" {
            progressBar.progressTintColor = UIColor(hexFromString: "#EEFF01");
        }
        if image_string == "pay" {
            progressBar.progressTintColor = UIColor(hexFromString: "#FF0180");
        }
        
        if image_string == "device" {
            progressBar.progressTintColor = UIColor(hexFromString: "#01DCFF");
        }
        
        if image_string == "popcorn" {
            progressBar.progressTintColor = UIColor(hexFromString: "#FF8710");
        }
        
        if image_string == "transfer1" {
            progressBar.progressTintColor = UIColor(hexFromString: "#01FF2B");
        }
    }
    
    func creatBarChart(dataPoints: [String], values: [Double]) {
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: Double(values[i]) , data: self.months as AnyObject?)
            print(dataEntries)
            dataEntries.append(dataEntry)
        }
        
        
        let lineChartDataSet = LineChartDataSet(entries: dataEntries, label: nil)
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        let xAxisValue = lineChart.xAxis
        xAxisValue.valueFormatter = axisFormatDelegate
        lineChart.data = lineChartData
        
        lineChartDataSet.mode = .cubicBezier
        lineChartDataSet.lineWidth = 1.5
        lineChartDataSet.circleColors = [UIColor.brown]
        lineChartDataSet.setColor(.red)
        lineChartDataSet.circleHoleColor = UIColor.brown
        lineChartDataSet.fill = Fill(color: .green)
        lineChartDataSet.fillAlpha = 0.2
        lineChartDataSet.drawFilledEnabled = true
        lineChartDataSet.drawVerticalHighlightIndicatorEnabled = false
        lineChartDataSet.highlightColor = .systemRed
        lineChartDataSet.circleHoleColor = .green
        lineChartDataSet.circleRadius = 5
        
    }
    
    //MARK: Grouping Transaction History
    fileprivate func attemptToGroup () {
        
        let groupedMessages = Dictionary(grouping: category) { (elem) -> Date in
            let date = Date.dateFromCustom(customString: elem.date)
            
            return date
        }
        
        //provide sorting for keys
        let sortedKeys = groupedMessages.keys.sorted()
        sortedKeys.forEach { (key) in
            let values = groupedMessages[key]
            group_transaction2.append(values ?? [])
            
        }
        tableview.reloadData()
    }
    
    
    
    //MARK: ******* Analytics category  API Call******///
    func analyticAPICall(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "SessionID": session, "CustomerID": customer_id, "operation": "details", "wallet": wallet_id, "category": category_from_segue.type]
        
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
        
        
        let url = "\(utililty.url)analytics"
        
        analyticsApiCall(url: url, parameter: parameter, token: token, header: headers)
    }
    
    //MARK: For Transaction History Analytics
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
                    
                    let response = decriptorJson["response"]
                    self.view.isUserInteractionEnabled = true
                    
                    self.total_amount.text = "NGN\(response["total"].stringValue)"
                    self.second_label_amount.text = "NGN\(response["average"].stringValue)"
                    self.percentage_text.text = "\(response["last_month_compare_percent"]["percent"].stringValue)% from last month"
                    
                    response["last_month_compare_percent"]["state"].stringValue.lowercased() == "up" ? (self.upImage.image = UIImage(named: "up-arrow")) : (self.upImage.image = UIImage(named: "down-load"))
                    
                    for i in response["history"].dictionary! {
                        self.analytics.append((i.key, (i.value).doubleValue / 100))
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
            
            self.analytics = self.analytics.sorted {
                guard let d1 = $0.0.shortDateUS, let d2 = $1.0.shortDateUS else { return false }
                return d1 < d2
            }
            
            self.months.append(self.analytics[0].0)
            self.months.append(self.analytics[1].0)
            self.months.append(self.analytics[2].0)
            self.months.append(self.analytics[3].0)
            self.months.append(self.analytics[4].0)
            self.months.append(self.analytics[5].0)
            
            self.unitsSold.append(self.analytics[0].1)
            self.unitsSold.append(self.analytics[1].1)
            self.unitsSold.append(self.analytics[2].1)
            self.unitsSold.append(self.analytics[3].1)
            self.unitsSold.append(self.analytics[4].1)
            self.unitsSold.append(self.analytics[5].1)
            
            self.creatBarChart(dataPoints: self.months, values: self.unitsSold)
            
            self.view_of_view.reloadInputViews()
            
            self.analyticTransactionAPICall()
        }
    }
    
    
    //     //MARK: ******* Analytics API Call******///s
    func analyticTransactionAPICall(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        let date = Date()
        
        let five_months_ago = date.addMonth(n: -5)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let converted_current_date = dateFormatter.string(from: date)
        let converted_months_ago = dateFormatter.string(from: five_months_ago)
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "SessionID": session, "CustomerID": customer_id, "operation": "transactions", "wallet": wallet_id, "dateFrom": converted_months_ago, "dateTo": converted_current_date, "page": "1", "pageLimit": "50", "category": category_from_segue.type]
        
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
        
        analyticsTransactionHistoryApiCall(url: url, parameter: parameter, token: token, header: headers)
    }
    
    
    //MARK: For Transaction History Analytics
    /////////***********Post Data MEthod*********////////
    func analyticsTransactionHistoryApiCall(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
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
                    self.category = [TransactionHistory]()
                    self.view.isUserInteractionEnabled = true
                    self.activityIndicator.stopAnimating()
                    
                    for i in decriptorJson["response"].arrayValue {
                        let new_category = TransactionHistory()
                        new_category.amount = i["amount"].stringValue
                        new_category.date = i["date"].stringValue
                        new_category.memo = i["memo"].stringValue
                        new_category.tx = i["transaction_id"].stringValue
                        
                        new_category.receiver = i["receiver"].stringValue
                        new_category.account_number = i["account_number"].stringValue
                        new_category.status = i["status"].stringValue
                        new_category.bank = i["bank"].stringValue
                        new_category.sender = i["sender"].stringValue
                        
                        
                        self.category.append(new_category)
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
            //MARK: Calling my method to group
            self.tableview.reloadData()
            self.attemptToGroup()
            print("you called me here")
        }
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - TRANSACTION HISTORY
extension AnalyticDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return group_transaction2.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //MARK: THIS IS WHERE THE PROBLEM OCCURS
        return group_transaction2[section].count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath) as! TransactionTableViewCell
        
        //******Remove styling from selected cell
        cell.selectionStyle = .none
        
        let dictionary = group_transaction2[indexPath.section][indexPath.row]
        
        
        cell.amount.text = "NGN\(dictionary.amount)"
        
        let splited_memo = dictionary.memo.split(separator: "/")
        cell.memo.text = String(splited_memo.first ?? "")
        cell.thumbnail_image?.image = UIImage(named: image_string)
        cell.trasaction_id.text = dictionary.tx
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        select_transaction = [group_transaction2[indexPath.section][indexPath.row]]
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "transaction") as? TransactionDetailsViewController
        
        vc?.transaction_histrory_detail = select_transaction
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
}



extension Date {
    func addMonth(n: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .month, value: n, to: self)!
    }
    func addDay(n: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .day, value: n, to: self)!
    }
    func addSec(n: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .second, value: n, to: self)!
    }
}


extension String {
    static let shortDateUS: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM"
        return formatter
    }()
    var shortDateUS: Date? {
        return String.shortDateUS.date(from: self)
    }
}

extension AnalyticDetailsViewController: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return months[Int(value)]
    }
}

