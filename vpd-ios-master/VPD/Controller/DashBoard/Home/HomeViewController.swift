//
//  HomeViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 26/06/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD


var DashBoardResponce: JSON!
var currencyList = [CurrencyList]()
var subCurrencyList = [CurrencyList]()
var g_accountArray = [Wallet]()
var accountArray = [Wallet]()
var wallet_is_current = [Wallet]()
var list_of_banks = [ListOfBanks]()





class HomeViewController: UIViewController, passSelectedObj {

    
    let screenHeight = UIScreen.main.bounds.height
    let screenWidth = UIScreen.main.bounds.width
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var subAccountView: UIView!
    @IBOutlet weak var scrollViewWrapper: UIScrollView!
    @IBOutlet var containerView: UIView!
    
    @IBOutlet weak var subAccountConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttomConstraintSubAccount: NSLayoutConstraint!
    @IBOutlet weak var topConstraintSubAccount: NSLayoutConstraint!
    
    
    //Constraint for the view Wrapper
    @IBOutlet weak var viewWrapperConstraint: NSLayoutConstraint!
    //@IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var transactionTableView: UITableView!
    @IBOutlet weak var vpdAcctNumberLabel: UILabel!
    @IBOutlet weak var linkAccountConstraint: NSLayoutConstraint!
    @IBOutlet weak var expenditureTopConstraint: NSLayoutConstraint!

    
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var expenseLabel: UILabel!
    

    @IBOutlet weak var height_background_image: NSLayoutConstraint!
    @IBOutlet weak var checkViewToSendToBack: UIView!
    @IBOutlet weak var logoutVIewToHide: UIView!
    
    
    @IBOutlet weak var levelLabel: UILabel!
    
    
    var acctnumber = ""
    var select_transaction: [TransactionHistory] = []
    
    lazy var refresh: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        
        refreshControl.addTarget(self, action:
            #selector(handleRefresh),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.white

        return refreshControl
    }()

    var should_show_indicator = false
    
    var  headerheight: CGFloat = 44
    
    var subWalletArray = [Wallet]()
    var show_subwallet = [Wallet]()
    var group_transaction = [[TransactionHistory]]()
    var notifications = [NotificationModel]()
    var account_numbert_to_Copy = ""
    
    private var lastContentOffset: CGFloat = 50

    
    var subAccountArray = [""]
    var linkedAccountArray = [""]
    

    //*************This variable was use to initialise an array of count one with empty values***********
    let new_wallets = Wallet()
    
    var arrayOfflag = ["flag", "us", "uk", "eu"]
    
    var convertFundWallet = ""
    
    var indexRow: Int!
    
    var transction_history = [TransactionHistory]()
    
    var last_transaction_history_count = 0
    
    
    
    @IBOutlet weak var collectionHeaderView: UICollectionView!
    @IBOutlet weak var subAccountCollectionView: UICollectionView!
    @IBOutlet weak var linkedAccountCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    
    //MARK: For BUsiness purpose only//************************
    /*****************************/
    @IBOutlet weak var pageControlConstraint: NSLayoutConstraint!
    @IBOutlet weak var linkedAccountLabel: UILabel!
    @IBOutlet weak var fund_walletButton: DesignableButton!
    @IBOutlet weak var requestCardButton: DesignableButton!
    @IBOutlet weak var topFundWalletConstrainst: NSLayoutConstraint!
    @IBOutlet weak var requestCardTopConstrainst: NSLayoutConstraint!
    @IBOutlet weak var requestHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var fundWalletHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var floatingButtonOutlet: DesignableButton!
    
    @IBOutlet weak var notification_count_button: DesignableButton!
    
    //MARK: Cell scale factor
    let cellScale: CGFloat = 0.9
    var notification_count = 0
    var count = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //scrollViewWrapper.refreshControl = UIRefreshControl()
        
        containerView.isUserInteractionEnabled = false
        collectionHeaderView.isScrollEnabled = false

        // Do any additional setup after loading the view.
        //****This loads the initial wallet that shows on screen*****//
        self.new_wallets.balance = ""
        self.new_wallets.currency = ""
        self.new_wallets.title = ""
        self.new_wallets.outflow = ""
        self.new_wallets.inflow =  ""
        self.new_wallets.wallet_uid = ""
        self.new_wallets.upgraded = ""
        self.new_wallets.status = ""
        self.new_wallets.type = ""
        
        accountArray.append(self.new_wallets)
        subWalletArray.append(self.new_wallets)
        
        pageControl.numberOfPages = accountArray.count
        pageControl.currentPage = 0
        pageControl.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        self.collectionHeaderView.decelerationRate = UIScrollView.DecelerationRate.fast
        self.subAccountCollectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        self.linkedAccountCollectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        
        //subAcctShow()
        scrollViewWrapper.delegate = self
        transactionTableView.delegate = self
        transactionTableView.dataSource = self
        
        transactionTableView.rowHeight = 80
        
        viewWrapperConstraint.constant = 800 + 44
        
        
        //forBusiness()
        
        requestCardButton.isHidden = true
        topFundWalletConstrainst.constant = 20
        requestCardTopConstrainst.constant = 0 // 15
        requestHeightConstraint.constant = 0 // 50
        fundWalletHeightConstraint.constant = 50
        linkAccountConstraint.constant = -30
        expenditureTopConstraint.constant = 20
        
        //screenSpacing()
        scrollViewWrapper.refreshControl = refresh
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //self.group_transaction = [[TransactionHistory]]()
        delayToNextPage()
        
        let screenSize = UIScreen.main.bounds.size
        let cellWidth = floor(screenSize.width * cellScale)
        let insetX = (view.bounds.width - cellWidth) / 2.0
        let layout = collectionHeaderView!.collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.itemSize = CGSize(width: cellWidth, height: 270)
        subAccountCollectionView.contentInset = UIEdgeInsets(top: 0, left: insetX, bottom: 0, right: insetX)
        
        collectionHeaderView.contentInset = UIEdgeInsets(top: 0, left: insetX, bottom: 0, right: insetX)
        
        collectionHeaderView.reloadData()
        
        self.view.layoutIfNeeded()
        
        notification_count_button.setTitle(String(notification_count), for: .normal)
        
        if !LoginResponse["response"]["authentication"]["pin_setup_complete"].boolValue {
            performSegue(withIdentifier: "goToSecurityAlert", sender: self);
            return
        }
       
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        //self.group_transaction = [[TransactionHistory]]()
        delayToNextPage()
        
        let screenSize = UIScreen.main.bounds.size
        let cellWidth = floor(screenSize.width * cellScale)
        let insetX = (view.bounds.width - cellWidth) / 2.0
        let layout = collectionHeaderView!.collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.itemSize = CGSize(width: cellWidth, height: 270)
        subAccountCollectionView.contentInset = UIEdgeInsets(top: 0, left: insetX, bottom: 0, right: insetX)
        
        collectionHeaderView.contentInset = UIEdgeInsets(top: 0, left: insetX, bottom: 0, right: insetX)
        
        collectionHeaderView.reloadData()
        
        self.view.layoutIfNeeded()
        
        
        notification_count_button.setTitle(String(notification_count), for: .normal)
        count = notification_count
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if refresh.isRefreshing == true {
            delayToNextPage()
        }
    }
    
    @objc func handleRefresh() {
        should_show_indicator = true
        delayToNextPage()
    }
    
    //MARK: - CollectionView for smaller Screens
    
    func forBusiness() {
        let acc_tyep = UserDefaults.standard.string(forKey: "account_type")
        
        if acc_tyep == "business" {
            subAccountView.isHidden = true
            subAccountConstraint.constant = 0
            // topConstraintSubAccount.constant = 0
            buttomConstraintSubAccount.constant = 0
            
            pageControlConstraint.constant = 0
            pageControl.isHidden = true
            
            linkedAccountLabel.text = "My Stores"
            fund_walletButton.isHidden = true
            requestCardButton.isHidden = true
            topFundWalletConstrainst.constant = 0
            requestCardTopConstrainst.constant = 0
            requestHeightConstraint.constant = 0
            fundWalletHeightConstraint.constant = 0
        }
    }
    
    override func didReceiveMemoryWarning() {
        print("I GOT LEACKAGES BABY")
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        let presentWallet = accountArray[pageControl.currentPage]
                
        currentWalletSelected["walletId"] = presentWallet.wallet_uid
        currentWalletSelected["currency"] = presentWallet.currency
        currentWalletSelected["balance"] = presentWallet.balance
        currentWalletSelected["wallet_type"] = presentWallet.type
        currentWalletSelected["upgraded"] = presentWallet.upgraded
        
        
        currentWalletSelected2 = presentWallet.wallet_uid

    }
    
//MARK: - Go to notification segue
    @IBAction func goToNotificationButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToNotification", sender: self)
    }
    
    //MARK: - Logout Pressed
    @IBAction func logOut() {
        let alertSV = LogoutAlert()
        let alert = alertSV.alert() {
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "login2") as? LoginWIthFaceOrTouchIDViewController
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        self.present(alert, animated: true)
    }
    
    //MARK: - Will increase view heigh base on amount of element in transaction_History List
    func increament() {
        
        if transction_history.count > last_transaction_history_count  {
            
            print(transction_history.count, "i got here also mofo")
            
            let cell = 99.5 + 44
            let total_height = Double(transction_history.count) * cell + (cell / 2.0) - 150
            viewWrapperConstraint.constant = viewWrapperConstraint.constant + CGFloat(total_height)
            
            
            last_transaction_history_count = transction_history.count
            
            attemptToGroup()
            
            if viewWrapperConstraint.constant > 1750 {
                viewWrapperConstraint.constant = 1820
            }
            return
        }
        
        if transction_history.count == last_transaction_history_count  {
            print(transction_history.count, "only for the same")
            attemptToGroup()
        }
        
        transactionTableView.reloadData()
    }
    
    //MARK: Grouping Transaction History
    fileprivate func attemptToGroup () {

        let groupedMessages = Dictionary(grouping: transction_history) { (elem) -> Date in
            let date = Date.dateFromCustom(customString: elem.date)
            
            return date
        }

        //provide sorting for keys
        let sortedKeys = groupedMessages.keys.sorted().reversed()
        sortedKeys.forEach { (key) in
            let values = groupedMessages[key]
            group_transaction.append(values ?? [])
        }
    }
    
    //MARK: will hide initially sub account on view did load and show only when data has load and if sub account is greater than 1
    //********Util method to help ui *******
    func subAcctShow() {
        
        //        let acc_tyep = UserDefaults.standard.string(forKey: "account_type")
        //        //check if subaccount array is less than or equal 1
        //        if subWalletArray.count <= 1 || acc_tyep == "business" {
        //            subAccountView.isHidden = true
        //            subAccountConstraint.constant = 0
        //           // topConstraintSubAccount.constant = 0
        //            buttomConstraintSubAccount.constant = 0
        //        }
        //        else {
        subAccountView.isHidden = false
        subAccountConstraint.constant = 145
        // topConstraintSubAccount.constant = 0
        buttomConstraintSubAccount.constant = 15
        
        show_subwallet = subWalletArray.filter({$0.hide == "NO"})
        show_subwallet.append(new_wallets)
        subAccountCollectionView.reloadData()
        //        }
    }
    
    
    
    //MARK: DashBoard API HERE************************
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
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "SessionID": session, "CustomerID": customer_id]
        
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
        

        let url = "\(utililty.url)dashboard"
        
        
        postData(url: url, parameter: parameter, token: token, header: headers)
    }
    
    //MARK: DashBoard API HERE(Transaction History)************************
    //++++++=========Delay function @if token is true move to next page+++++++===========//
    func callTransactionApi(){
        
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        
        let now = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
        
        let today = formatter.string(from: now as Date)
        let five_day_ago = formatter.string(from: Date.yesterday as Date)
        
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "SessionID": session, "CustomerID": customer_id, "dateFrom": five_day_ago, "dateTo": today, "page": "1", "pageLimit": "20"]
        
       // print(params)
        
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
        
     
        
        let url = "\(utililty.url)transaction_history"
        
        postToTransactionHistory(url: url, parameter: parameter, token: token, header: headers)
    }
    
    
    //MARK: Notification API HERE************************
      //++++++=========Delay function @if token is true move to next page+++++++===========//
      func NotifcationApi(){
          
          /******Import  and initialize Util Class*****////
          let utililty = UtilClass()
          
          let device = utililty.getPhoneId()
          
          //print("shaDevicePpties")
          let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
          let timeInSecondsToString = String(timeInSeconds)
          
          let session = UserDefaults.standard.string(forKey: "SessionID")!
          let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
          
    
         
          //******getting parameter from string
          let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString,  "SessionID": session, "CustomerID": customer_id]
          
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
          

          let url = "\(utililty.url)notifications"
          
          
          postToNotification(url: url, parameter: parameter, token: token, header: headers)
      }
    
    //MARK: - End point for new subWallet creation//
    func createNewSubWalletAPI(){
        
        
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
                   
        
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "currency": currencySelected, "wallet_type": wallet_type]
        
        
        
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
        
        let url = "\(utililty.url)create_wallet"
        
        postForCreationNewSubWallet(url: url, parameter: parameter, token: token, header: headers)
    }
    
    
    
    // MARK: -******Main Dashboard Api call******
    ///////////***********Post Data MEthod*********////////
    func postData(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        if !self.should_show_indicator  {
            self.activityIndicator.startAnimating()
        }
        

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
                DashBoardResponce = decriptorJson
                print(decriptorJson)
                
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                let wallet = decriptorJson["response"]["wallet"].arrayValue
                var wallet_id = ""
                
                
                if(status) {
                    accountArray = [Wallet]()
                    self.subWalletArray = [Wallet]()
                    self.show_subwallet = [Wallet]()
                    ///Check wallet for If SUB or MAIN
                    for i in wallet {
                        if i["type"] == "MAIN" {
                            
                            let new_wallet = Wallet()
                            
                            new_wallet.balance = i["balance"].stringValue
                            new_wallet.currency = i["currency"].stringValue
                            new_wallet.title = i["title"].stringValue
                            new_wallet.outflow = i["inflow"].stringValue
                            new_wallet.inflow = i["outflow"].stringValue
                            new_wallet.wallet_uid = i["wallet_uid"].stringValue
                            new_wallet.level = i["level"].stringValue
                            
                            wallet_id = i["wallet_uid"].stringValue
                            UserDefaults.standard.set(wallet_id, forKey: "wallet_id")
                            UserDefaults.standard.synchronize()
                            
                            new_wallet.upgraded = i["upgraded"].stringValue
                            new_wallet.status = i["status"].stringValue
                            new_wallet.type = i["type"].stringValue
                           
                            new_wallet.bank["bank_code"] = i["bank"]["bank_code"].stringValue
                            new_wallet.bank["account_number"] = i["bank"]["account_number"].stringValue
                            
                            self.account_numbert_to_Copy = i["bank"]["account_number"].stringValue
                            
                            
                            new_wallet.bank["balance"] = i["bank"]["balance"].stringValue
                            
                            
                            accountArray.append(new_wallet)
                            g_accountArray.append(new_wallet)
                        }
                            
                        else if i["type"] == "SUB" {
                          
                            let new_wallet = Wallet()
                            
                            new_wallet.balance = i["balance"].stringValue
                            new_wallet.currency = i["currency"].stringValue
                            new_wallet.title = i["title"].stringValue
                            new_wallet.outflow = i["outflow"].stringValue
                            new_wallet.inflow = i["inflow"].stringValue
                            new_wallet.wallet_uid = i["wallet_uid"].stringValue
                            new_wallet.upgraded = i["upgraded"].stringValue
                            new_wallet.status = i["status"].stringValue
                            new_wallet.type = i["type"].stringValue
                            new_wallet.hide = i["hide"].stringValue
                  
                            self.subWalletArray.append(new_wallet)
                        }
                    }
                    
                    //*** This will append empty wallet after wallets have been populated from back end//** ***//
                    accountArray.append(self.new_wallets)
                    self.subWalletArray.append(self.new_wallets)
                    
                    //self.show_subwallet.append(self.new_wallet)
                    
                    //##upDate page control
                    
                    self.pageControl.numberOfPages = accountArray.count
                    
                    self.containerView.isUserInteractionEnabled = true
                    self.callTransactionApi()
                    self.activityIndicator.stopAnimating()
                    self.refresh.endRefreshing()
                    
                }
                else if (message == "Session has expired") {
                   self.activityIndicator.stopAnimating()
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self )
                }
                else {
                    self.refresh.endRefreshing()
                    self.activityIndicator.stopAnimating()
                    let dashboardAlert = DashBoardAlertService()
                    let alertVC =  dashboardAlert.popUp(alertMessage: message){
                        print("Recall API")
                    }
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.refresh.endRefreshing()
                let dashboardAlert = DashBoardAlertService()
                self.activityIndicator.stopAnimating()
                let alertVC =  dashboardAlert.popUp(alertMessage: "Network Error"){
                    print("Recall API")
                    //self.delayToNextPage()
                }
                self.present(alertVC, animated: true)
            }
            
            self.collectionHeaderView.reloadData()
            self.subAcctShow()
            self.should_show_indicator = false
        }
        
    }
    
    // MARK: - NETWORK CALL- Post TO Transanction History
    func postToTransactionHistory(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        Alamofire.request(url, method: .post, parameters: parameter, headers: header).responseJSON {
            response in
            if response.result.isSuccess {
                //print("SUCCESSFUL.....")
                
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
                    self.group_transaction = [[TransactionHistory]]()
                    print(".......... i got here MOFO......")
                    self.transction_history = [TransactionHistory]()
                    for i in decriptorJson["response"].arrayValue {
                        
                        let history = TransactionHistory()
                        
                        history.amount = i["amount"].stringValue
                        history.memo = i["memo"].stringValue
                        history.method = i["method"].stringValue
                        history.currency = i["currency"].stringValue
                        history.type = i["type"].stringValue
                        history.tx = i["tx"].stringValue
                        history.account_number = i["account_number"].stringValue
                        history.bank = i["bank"].stringValue
                        
                        history.wallet_uid = i["wallet_uid"].stringValue
                        history.status = i["status"].stringValue
                        history.receiver = i["receiver"].stringValue
                        history.sender = i["sender"].stringValue
                       
                        let date = i["date"].stringValue
                        let new_date = date.split(separator: " ")
                        history.date = String(new_date[0])
                        
                        self.transction_history.append(history)
                        
                        print(i["amount"].stringValue, ".....testing")
                    }
                    self.NotifcationApi()
                }
                    
                else if (message == "Session has expired") {
                    self.activityIndicator.stopAnimating()
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self )
                }
                    
                else {
                    let alertService = AlertService()
                    let alertVC =  alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                let alertService = AlertService()
                let alertVC =  alertService.alert(alertMessage: "Network Error")
                self.present(alertVC, animated: true)
                //self.callTransactionApi()
            }
             self.transactionTableView.reloadData()
            
            //*******Call only when the is a new additionto transaction history
            self.increament()
           self.transactionTableView.reloadData()
        }
    }
    
    
    // MARK: - NETWORK CALL- Post TO Notifications
      func postToNotification(url: String, parameter: [String: String], token: String, header: [String: String]) {
          
          Alamofire.request(url, method: .post, parameters: parameter, headers: header).responseJSON {
              response in
              if response.result.isSuccess {
                  //print("SUCCESSFUL.....")
                  
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
                    self.notifications = [NotificationModel]()
                    
                    for i in decriptorJson["response"].arrayValue {
                        let notification = NotificationModel()
                        notification.date = i["date"].stringValue
                        notification.message =  i["message"].stringValue
                        notification.url =  i["url"].stringValue
                        notification.id = i["id"].stringValue
                        
                        self.notifications.append(notification)
                    }
                  }
                      
                  else if (message == "Session has expired") {
                    self.activityIndicator.stopAnimating()
                      self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                  }
                      
                  else {
                      let alertService = AlertService()
                      let alertVC =  alertService.alert(alertMessage: message)
                      self.present(alertVC, animated: true)
                  }
              }
              else {
                  let alertService = AlertService()
                  let alertVC =  alertService.alert(alertMessage: "Network Error")
                  self.present(alertVC, animated: true)
                  
              }
            if self.notifications.count == 0 {
                self.notification_count_button.isHidden = true
            }
            else {
                self.notification_count_button.isHidden = false
                self.notification_count = self.notifications.count
                self.notification_count_button.setTitle(String(self.notification_count), for: .normal)
            }
          }
      }
    
    //MARK: - ***********Post Data MEthod End point for new subWallet creation*********////////
    func postForCreationNewSubWallet(url: String, parameter: [String: String], token: String, header: [String: String]) {
        
        
            let loader = LoaderPopup()
            let loaderVC = loader.Loader()
            self.present(loaderVC, animated: true)

        
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
                    //********Response from server *******//
                    self.dismiss(animated: true, completion: nil)
                    
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                        let alertSV = SuccessAlertTransaction()
//                        let alert = alertSV.alert(success_message: message) {
//                            self.navigationController?.popToViewController(ofClass: TabBarViewController.self)
//                        }
//                        self.present(alert, animated: true)
//                        self.dismiss(animated: true, completion: nil)
//                    }
                    self.delayToNextPage()
                }
                    
                else if message == "Session has expired" {
                    self.dismiss(animated: true, completion: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                    }
                }
                    
                else {
                    self.dismiss(animated: true, completion: nil)
                    ////From the alert Service
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        let alertService = AlertService()
                        let alertVC = alertService.alert(alertMessage: message)
                        self.present(alertVC, animated: true)
                    }
                }
            }
            else {
                self.dismiss(animated: true, completion: nil)
                ////From the alert Service
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                    self.present(alertVC, animated: true)
                }
            }
        }
    }
    

    
    //MARK: -Method that controls pageControl
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if(scrollView.tag == 1) {
            let pageIndex = round(scrollView.contentOffset.x / view.frame.width);
            pageControl.currentPage = Int(pageIndex);
            
            let presentWallet = accountArray[pageControl.currentPage]
            
            
            //This will set currencySelected index to dictionary in TabBarVIewController??
            currentWalletSelected["walletId"] = presentWallet.wallet_uid
            currentWalletSelected["currency"] = presentWallet.currency
            currentWalletSelected["balance"] = presentWallet.balance
            currentWalletSelected["wallet_type"] = presentWallet.type
            
            //print(accountArray[pageControl.currentPage])
            expenseLabel.text = "\(presentWallet.currency) \(presentWallet.outflow)"
            incomeLabel.text = "\(presentWallet.currency) \(presentWallet.inflow)"
        }
    }

    //*********Wallet Id to Be passed to next page********/
    var walletId = ""
    var currency = ""
    var balance = ""
    var wallet_type = ""
    
    
    // MARK: - Fund Wallet Button reference
    @IBAction func convertButtonPressed() {
        
        let currentWallet = accountArray[pageControl.currentPage]
        walletId = currentWallet.wallet_uid
        currency = currentWallet.currency
        balance = currentWallet.balance
        wallet_type = currentWallet.type
        
        currentWalletSelected2 = currentWallet.wallet_uid
        
        if Double(currentWallet.balance) != 0.00 {
            createCurrencyObject()
            performSegue(withIdentifier: "goToConvert", sender: self)
        }
        else {
            performSegue(withIdentifier: "goToFundWallet", sender: self)
        }
    }
    
    // - MARK Create new Sub Wallet Button reference
    @IBAction func addNewSubAccoutPressed(_ sender: Any) {
        
        //goToOpenNewWallet()
        createCurrencyObject2()
        performSegue(withIdentifier: "addSubWallet", sender: self)
    }
    
    
    //MARK: - Copy account Number
    @IBAction func copyAccountNumbetButton(_ sender: Any) {
        UIPasteboard.general.string = account_numbert_to_Copy
        self.showToast(message: "Copied to clipboard", font: .systemFont(ofSize: 14))
    }
    
    //MARK: - Edit Sub account
    @IBAction func editSubAccountPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToHideSubAccount", sender: self)
    }
    
    
    //MARK:- Fund Wallet Button reference
    @IBAction func fundButtonPressed(_ sender: Any) {
        
        let currentWallet = accountArray[pageControl.currentPage]
        walletId = currentWallet.wallet_uid
        currency = currentWallet.currency
        balance = currentWallet.balance
        wallet_type = currentWallet.type
        
        currentWalletSelected2 = currentWallet.wallet_uid
        
        
        if currentWallet.balance != "" {
            performSegue(withIdentifier: "goToFundWallet", sender: self)
        }
    }
    
    
    //MARK: - Method should check if choosen account type is in curreny_list
    func createCurrencyObject() {
        
        let LoginResponseCurrency = LoginResponse["response"]["currency_list"]
        
        if currencyList.count <= 0 {
            for i in LoginResponseCurrency.arrayValue {
                let currency_list = CurrencyList()
                
                currency_list.cu_name = i["cu_name"].stringValue
                currency_list.cu_name_abbr = i["cu_name_abbr"].stringValue
                currency_list.cu_country_abbr = i["cu_country_abbr"].stringValue
                
                currencyList.append(currency_list)
            }
        }
    }
    
    //MARK: - Method should check if choosen account type is in curreny_list
    func createCurrencyObject2() {

        let LoginResponseCurrency = LoginResponse["response"]["currency_list"]

        if subCurrencyList.count <= 0 {
            for i in LoginResponseCurrency.arrayValue {
                let currency_list = CurrencyList()

                currency_list.cu_name = i["cu_name"].stringValue
                currency_list.cu_name_abbr = i["cu_name_abbr"].stringValue
                currency_list.cu_country_abbr = i["cu_country_abbr"].stringValue

                subCurrencyList.append(currency_list)
            }
        }
    }
    
    var currencySelected = ""
    var walletType = ""
    
    
    //MARK:- Calling stubs here
    func passingData(segue: String, type: String, abbr: String) {
        if type == "security" {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Security") as? SecurityViewController
                self.navigationController?.pushViewController(vc!, animated: true)
                //self.present(vc!, animated: true)
                return
            }
        }
        if type == "SUB" {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.wallet_type = type
                self.currencySelected = abbr
                self.createNewSubWalletAPI()
                return
                
            }
        }
        else {
            currencySelected = abbr
            walletType = type
            performSegue(withIdentifier: segue, sender: self)
        }
        
    }
    
    
    //MARK: - Discovered that @createCurrencyObject re-runs every time button is clicked//
    @IBAction func addNewWalletButtonPressed(_ sender: Any) {
        createCurrencyObject()
        performSegue(withIdentifier: "addWalletPopUp", sender: self)
        //goToOpenNewWallet()
    }
     
    //MARK: - Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToNotification" {
            let destinationVC = segue.destination as! NotificationViewController
            destinationVC.notifications = notifications
            //destinationVC.count = count
        }
        
        if segue.identifier == "goToFundWallet" {
            let destinationVC = segue.destination as! FundWalletViewController
            destinationVC.walletID = walletId
            destinationVC.currency = currency
            destinationVC.balance = balance 
        }
        
        if segue.identifier == "addWalletPopUp" {
            let destinationVC = segue.destination as! AddWalletModalViewController
            destinationVC.accountArray = accountArray
            //Should change based on something....don't know why for now//
            destinationVC.wallet_type = wallet_type
            destinationVC.delegate = self
        }
        
        if segue.identifier == "goToSecurityAlert" {
            let destinationVC = segue.destination as! SecurityAlertDashboardViewController
                destinationVC.delegate = self
        }
        
        
        if segue.identifier == "goToConvert" {
            let destinationVC = segue.destination as! SelectAccountsViewController
            destinationVC.amount = balance
            destinationVC.currency = currency
            destinationVC.wallet_uid = walletId
            destinationVC.wallet_type = wallet_type
            
            destinationVC.accountArray = accountArray
            destinationVC.subAccountArray = currencyList
        }
        
        if segue.identifier == "addSubWallet" {
            let destinationVC = segue.destination as! AddSubWalletPopupViewController
            destinationVC.subWalletArray = subWalletArray
            destinationVC.wallet_type = "SUB"
            destinationVC.delegate = self
        }
        
        if segue.identifier == "goToHideSubAccount" {
            let destinationVC = segue.destination as! HideSubAccountViewController
            destinationVC.subWalletArray = subWalletArray
        }
        
        if segue.identifier == "goToUpgrade" {
            print(accountArray[pageControl.currentPage].balance)
            wallet_is_current = [accountArray[pageControl.currentPage]]
        }
        
        if segue.identifier == "goToSearch" {
            let destination = segue.destination as! DateSearchViewController
            destination.from_segue = "dashboard"
            destination.delegate = self
        }
        
        if segue.identifier == "goToPhotID" {
            let destination = segue.destination as! OpenAnotherAccountViewController
            
            destination.currencySelected = currencySelected
            destination.wallet_type = walletType
            
        }
        
        if segue.identifier == "goToTransactionHistory" {
            let destination = segue.destination as! TransactionHistorySearchViewController
            
            destination.converted_firstDate = walletType
            destination.converted_lastDate = currencySelected
        }
        
        if segue.identifier == "goToTrasactionDetails" {
            let destination = segue.destination as! TransactionDetailsViewController
            destination.transaction_histrory_detail = select_transaction
        }
    }
    
    
    //MARK: - floating Button reference
    @IBAction func floatingButtonPressed(_ sender: Any) {

    }
    
   
    
    //MARK: Button for cell (Wallet switching)
    var walletSwitch = false
    var bankSwitched = true
    
    @IBAction func walletSwitchButtonPressed(_ sender: Any) {
        bankSwitched.toggle()
        walletSwitch.toggle()
        collectionHeaderView.reloadData()
    }
    
    @IBAction func bankAccSwitchButtonPressed(_ sender: Any) {
        bankSwitched.toggle()
        walletSwitch.toggle()
        collectionHeaderView.reloadData()
        
    }
    
    @IBAction func moreButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToSearch", sender: self)
    }
    
}


//************ @UICollectionViewDelegateFlowLayout  will allow each cell to be centered properly **********//
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionHeaderView  {
             return accountArray.count
        }
        if collectionView == self.subAccountCollectionView  {
            return show_subwallet.count
        }
        else {
            return linkedAccountArray.count
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //MARK: - This brings out button to add new wallet
        if collectionView == self.collectionHeaderView && indexPath.item == accountArray.count - 1 {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell2", for: indexPath) as! AddNewWalletCollectionViewCell
            //do all the stuff here for CellA
            cell.addNewLabel.text = "Add New Wallet"
            return cell
        }

        if collectionView == self.collectionHeaderView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! AddNewWalletCollectionViewCell

            //CellB
            let cellDic = accountArray[indexPath.row]
        
            //cell.amountLabel.text = cellDic.balance
            //*********Setting each wallet currency flag*********///
            //cell.acctnumber.text = "VPD Acct. No: \(customer_id)"
            
            
        //MARK: IF Wallet is upgraded
            let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
            
            self.expenseLabel.text = "\(cellDic.currency) \(cellDic.outflow)"
            self.incomeLabel.text = "\(cellDic.currency) \(cellDic.inflow)"
            
            
            if cellDic.upgraded == "YES" && walletSwitch {

                
                cell.stactViewShow.isHidden = false

                cell.accountHeader.isHidden = false
                cell.accountHeader.text = "Bank Acc No."

                cell.acctnumber.isHidden = false
                cell.acctnumber.text = cellDic.bank["account_number"]
                account_numbert_to_Copy = cellDic.bank["account_number"]!
                //cell.acctnumber.text = customer_id

                cell.flagImageView.isHidden = true
                cell.bankAccButon.isHidden = false
                cell.dashLine.isHidden = true
                cell.small_flag.isHidden = true
                cell.vpdWalletLabel.isHidden = true
                cell.walletButton.isHidden = false
                cell.activeLabel.isHidden = true
                cell.active_vpd_wallet.isHidden = true
                cell.current_balance.isHidden = false
                cell.vpd_wallet_under.isHidden = true
                
                cell.bankAccButon.backgroundColor = UIColor(hexFromString: "#34B5CE")
                cell.walletButton.backgroundColor = UIColor(hexFromString: "#F4F5F5")
                cell.walletButton.setTitleColor(.darkGray, for: .normal)
                 cell.bankAccButon.setTitleColor(.white, for: .normal)
    
            }
            
            if cellDic.upgraded == "YES" && bankSwitched {
            
               cell.stactViewShow.isHidden = false
               
               cell.accountHeader.isHidden = false
               cell.accountHeader.text = "VPD Acc No."
               
               cell.acctnumber.isHidden = false
               //cell.acctnumber.text = cellDic.bank["account_number"]
               cell.acctnumber.text = customer_id
               
               cell.flagImageView.isHidden = true
               cell.bankAccButon.isHidden = false
               //cell.dashLine.isHidden = false
               cell.small_flag.isHidden = false
               cell.vpdWalletLabel.isHidden = false
               cell.walletButton.isHidden = false
               cell.activeLabel.isHidden = false
           //    cell.active_vpd_wallet.isHidden = true
               cell.current_balance.isHidden = false
               //cell.vpd_wallet_under.isHidden = true
                
                cell.walletButton.backgroundColor = UIColor(hexFromString: "#34B5CE")
                cell.bankAccButon.backgroundColor = UIColor(hexFromString: "#F4F5F5")
                cell.walletButton.setTitleColor(.white, for: .normal)
                cell.bankAccButon.setTitleColor(.darkGray, for: .normal)
                
           }
            
            if cellDic.currency == "NGN" {
                cell.flagImageView.image = UIImage(named: "flag")
            }
            else if cellDic.currency == "GBP" {
                cell.flagImageView.image = UIImage(named: "uk")
            }
            else if cellDic.currency == "USD" {
                cell.flagImageView.image = UIImage(named: "us")
            }
            else {
                cell.flagImageView.image = UIImage(named: "eu")
            }
            
            cell.acctnumber.text = cellDic.wallet_uid
            
            
            //*****Concatinating "currency" and "balance" into a single string with different fonts and size******//
            let myAttribute = [NSAttributedString.Key.font: UIFont(name: "Muli-Bold", size: 28.0)!]
            let attributCurrency = NSMutableAttributedString(string: cellDic.currency)
            
            let space = NSAttributedString(string: " ")
            
            let balance = (bankSwitched ? cellDic.balance : cellDic.bank["balance"] ) ?? ""
            let myAttrString = NSAttributedString(string: balance, attributes: myAttribute)
            
            attributCurrency.append(space)
            attributCurrency.append(myAttrString)
     
            cell.amountLabel.attributedText = attributCurrency
            
            //**********Setting button to either fund wallet or convert wallet=****
            if accountArray[indexPath.row].balance == "0.00" {
                cell.fundButton.setTitle("Fund Wallet", for: .normal)
            }
            else {
                cell.fundButton.setTitle("Convert Fund", for: .normal)
            }
            
            cell.levelLable.text = "Level \(cellDic.level)"
            
            return cell
        //*****Header  collectionViewCell ends***********//
        }
        
        //***********Linked Account collectionView Starts************//
        if collectionView == self.linkedAccountCollectionView && indexPath.item == linkedAccountArray.count - 1 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "linkedAccountCell2", for: indexPath) as! LinkedAccountCollectionViewCell
            //do all the stuff here for CellA
            cell.labe1.text = "Exchange your fund to"
            cell.label2.text = "a new currency"
            return cell
        }
        if collectionView == self.linkedAccountCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "linkedAccountCell", for: indexPath) as! LinkedAccountCollectionViewCell
            //CellB
            cell.labe1.text = linkedAccountArray[indexPath.row]
            cell.label2.text = "3,000,000"
            return cell
        }
        
            
        //***********Sub Account collectionView Starts************//
        if collectionView == self.subAccountCollectionView && indexPath.item == show_subwallet.count - 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subAccountCell2", for: indexPath) as! SubAccountCollectionViewCell
            //do all the stuff here for CellA
            cell.bankAbrr.text = "Exchange your fund to"
            cell.bankFull.text = "a new currency"
            return cell
        }
        else {
            //CellB
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subAccountCell", for: indexPath) as! SubAccountCollectionViewCell
            
            
            let cellDic = show_subwallet[indexPath.row]
            
            if cellDic.hide == "NO" {
                cell.bankAbrr.text = cellDic.currency
                
                //*****Concatinating "currency" and "balance" into a single string with different fonts and size******//
                let myAttribute = [NSAttributedString.Key.font: UIFont(name: "Muli-Bold", size: 20.0)!]
                let attributCurrency = NSMutableAttributedString(string: cellDic.currency)
                let space = NSAttributedString(string: " ")
                let myAttrString = NSAttributedString(string: cellDic.balance, attributes: myAttribute)
                
                attributCurrency.append(space)
                attributCurrency.append(myAttrString)
                
                cell.currency.attributedText = attributCurrency
                
                
                if cellDic.currency == "NGN" {
                    cell.flagImage.image = UIImage(named: "flag")
                    cell.bankFull.text = "Nigeria Naira"
                }
                else if cellDic.currency == "GBP" {
                    cell.flagImage.image = UIImage(named: "uk")
                    cell.bankFull.text = "British Pounds"
                }
                else if cellDic.currency == "USD" {
                    cell.flagImage.image = UIImage(named: "us")
                    cell.bankFull.text = "American Dollar"
                }
                else {
                    cell.flagImage.image = UIImage(named: "eu")
                    cell.bankFull.text = "European Euro"
                }
            }
            
            return cell
        }
        //***********Sub Account collectionView end************//
    }


    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.subAccountCollectionView && indexPath.item != subWalletArray.count - 1 {
            
            indexRow = indexPath.row
            createCurrencyObject()
            
            let currentWallet = show_subwallet[indexRow]
            walletId = currentWallet.wallet_uid
            currency = currentWallet.currency
            balance = currentWallet.balance
            wallet_type = currentWallet.type
            performSegue(withIdentifier: "goToConvert", sender: self)
        }

    }
}


//**************This Extention handles Centering of Cards ***********//
extension HomeViewController: UIScrollViewDelegate  {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
      
        if scrollView.tag == 5 && (scrollView.contentOffset.y > self.lastContentOffset )   {
            
            // move up
            self.height_background_image.constant = 0
            checkViewToSendToBack.isHidden = true
            logoutVIewToHide.isHidden = true
        }
            
        else if scrollView.tag == 5 && (scrollView.contentOffset.y < self.lastContentOffset ) {
            // move down
            self.height_background_image.constant =  130
            checkViewToSendToBack.isHidden = false
            logoutVIewToHide.isHidden = false
        }
        
        
    }
    
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        
        if scrollView.tag == 1 {
            let layout = self.collectionHeaderView?.collectionViewLayout as! UICollectionViewFlowLayout
            let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
            
            var offset = targetContentOffset.pointee
            let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
            let roundedInedex = round(index)
            
            offset = CGPoint(x: roundedInedex * cellWidthIncludingSpacing - scrollView.contentInset.left, y:scrollView.contentInset.top )
            
            targetContentOffset.pointee = offset
            
            
//          let presentWallet = accountArray[pageControl.currentPage]
//            currentWalletSelected["upgraded"] = presentWallet.upgraded
//             print("\(currentWalletSelected["upgraded"]).........upgrade value")
//
//
//            if currentWalletSelected["upgraded"] == "YES" || (pageControl.currentPage == accountArray.count - 1 ){
//                floatingButtonOutlet.isHidden = true
//
//            }
//            else {
//                floatingButtonOutlet.isHidden = false
//            }

        }
         
        
    }


}


//MARK: - TRANSACTION HISTORY
//MARK: Extension for UI Table View and Delegate for transaction History
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return group_transaction.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //MARK: THIS IS WHERE THE PROBLEM OCCURS
        return group_transaction[section].count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath) as! TransactionTableViewCell
        
        //******Remove styling from selected cell
        cell.selectionStyle = .none
        
        let cell_dictionary = group_transaction[indexPath.section][indexPath.row]
        
        
        let myAttribute = [NSAttributedString.Key.font: UIFont(name: "Muli-Bold", size: 17.0)!]
        let attributCurrency = NSMutableAttributedString(string: cell_dictionary.currency)

        let myAttrString = NSAttributedString(string: cell_dictionary.amount, attributes: myAttribute)
        

        attributCurrency.append(myAttrString)

        cell.amount.attributedText = attributCurrency
        
        let splited_memo = cell_dictionary.memo.split(separator: "/")

        cell.memo.text = String(splited_memo.first ?? "")

        if String(splited_memo.first ?? "") == "TRF" {
            cell.thumbnail_image.image = UIImage(named: "transfer")

        }

        else if String(splited_memo.first ?? "") == "NIP transfer fee" {
            cell.thumbnail_image.image = UIImage(named: "transfer")

        }

        else if String(splited_memo.first ?? "") == "Data" {
            cell.thumbnail_image.image = UIImage(named: "topup")
        }

        else if String(splited_memo.first ?? "") == "Airtime" {
            cell.thumbnail_image.image = UIImage(named: "topup")
        }


        else if String(splited_memo.first ?? "") == "Wallet Funding" {
            cell.thumbnail_image.image = UIImage(named: "utility_bill1")
        }

        else {
            cell.thumbnail_image.image = UIImage(named: "utility_bill")
        }
        cell.trasaction_id.text = cell_dictionary.tx
         return cell
      
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerheight
    }
    
    //MARK: Header view representation
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = Bundle.main.loadNibNamed("HeaderViewTableViewCell", owner: self, options: nil)?.first as! HeaderViewTableViewCell
        
        let groupHeader = group_transaction[section].first
        
        if let firstDate = groupHeader {
      
           // print(type(of: firstDate.date))
            let date = Date.dateFromCustom(customString: firstDate.date)
            let customDate = Date.dateFormaterMonth(date: date)
            let split_date = customDate.split(separator: " ")
            
            headerView.dateOutlet.text = "\(String(Int(split_date[0])!.ordinal)) \(split_date[1])"
            
        }
        
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        select_transaction = [group_transaction[indexPath.section][indexPath.row]]
        performSegue(withIdentifier: "goToTrasactionDetails", sender: self)
    }
    
}



extension UIRefreshControl {
    func beginRefreshingManually() {
        if let scrollView = superview as? UIScrollView {
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y - frame.height), animated: true)
        }
        beginRefreshing()
    }
}

