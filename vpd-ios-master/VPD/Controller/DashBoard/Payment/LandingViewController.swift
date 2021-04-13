//
//  LandingViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 21/08/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Contacts
import Alamofire
import SwiftyJSON
import SVProgressHUD
import SDWebImage

struct Contacts: Codable  {
    var name: String
    var phoneNumber: String
}

var agentIDFromReg = ""

var vpd_contacts = [VPDContacts]()



class LandingViewController: UIViewController, UITextFieldDelegate, seguePerform {
    

    @IBOutlet weak var viewWrapper: UIView!
    @IBOutlet weak var payButton: DesignableButton!
    @IBOutlet weak var requestButton: DesignableButton!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var searchTextField: DesignableUITextField!
    @IBOutlet weak var button1: DesignableButton!
    @IBOutlet weak var button2: DesignableButton!
    @IBOutlet weak var button3: DesignableButton!
    @IBOutlet weak var button4: DesignableButton!
    @IBOutlet weak var button5: DesignableButton!
    @IBOutlet weak var setBoundsView: UIView!
    @IBOutlet weak var viewWrapperConstraint: NSLayoutConstraint!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var searchButtonLabel: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var recurringPaymentButton: DesignableButton!
    
    
    //MARK: Constraint
    @IBOutlet weak var fundWalletHeightConstraingt: NSLayoutConstraint!
    @IBOutlet weak var transferHeightConstraint: NSLayoutConstraint!
   
    @IBOutlet weak var transferTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var payBillTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var payBillHeightConstraint: NSLayoutConstraint!
   
    @IBOutlet weak var recurringPaymentHeight: NSLayoutConstraint!
    @IBOutlet weak var recurringBillTopConstraint: NSLayoutConstraint!
    
    //MARK: For other request section
    @IBOutlet weak var contactImageView: DesignableView!
    @IBOutlet weak var requestsusinglink: UIButton!
    @IBOutlet weak var requestFromContact: UILabel!
    @IBOutlet weak var myContactHeader: UILabel!
    @IBOutlet weak var vpdFriends: UILabel!
    
    @IBOutlet weak var topHeight: NSLayoutConstraint!
    @IBOutlet weak var serviceHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var requestButtonHieght: NSLayoutConstraint!
    
    var list_numbers = [String]()
    
    var indexRow: Int!
    
    var contacts = [Contacts]()
    var searchData = [VPDContacts]()
    
    
    var contact_name =  ""
    var contact_number = ""
    var contact_image = ""
    
    
    var passing_to_popup = ""
    var searching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //self.viewWrapper.isUserInteractionEnabled = false
        
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Search...",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        searchTextField.delegate = self
        
        requestButton.backgroundColor = .clear
        payButton.backgroundColor = .white
        payButton.setTitleColor(UIColor.black, for: .normal)
        
        searchTextField.setLeftPaddingPoints(15)
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.rowHeight = 60
        
        
        
        viewWrapperConstraint.constant = 750
        
        
        searchButtonLabel.alpha = 0
         searchTextField.alpha = 0
         lineView.alpha = 0
        
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if LoginResponse["response"]["agent"].arrayValue.count >= 1 {
            agentIDFromReg = LoginResponse["response"]["agent"].arrayValue[0]["id"].stringValue
        }
        
                
        print(agentIDFromReg, ".... i am an empty string")
        if agentIDFromReg != "" {
            button5.isHidden = false
        }
        else {
            button5.isHidden = true
        }
        fetchContacts()
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    //************Handles search when input text is filled************//
    @objc func textFieldDidChange(_ textField: UITextField) {
        searching = true
        let searchText = searchTextField.text
        
        searchData = vpd_contacts.filter({$0.name.lowercased().prefix(searchText!.count) == searchText!.lowercased()})

        tableview.reloadData()
    }
    
    func fetchContacts() {
        
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, err) in
            if let err = err {
                print("Failed access request", err)
            }
            if granted {
                print("Access granted")
                
                let keys = [CNContactGivenNameKey, CNContactPhoneNumbersKey, CNContactFamilyNameKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                
                do {
                    var contactsArray = [Contacts]()
                    
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointerIfYouWantToStop) in

                        
                        let name = contact.givenName
                        let phoneNumber = contact.phoneNumbers.first?.value.stringValue ?? "No Phone number found"
                        
                        self.list_numbers.append(phoneNumber)
                        contactsArray.append(Contacts(name: name, phoneNumber: phoneNumber))
                    })
                    
                    self.contacts = contactsArray
                    DispatchQueue.main.async {
                        self.getListOfContactsAPI()
                        self.tableview.reloadData()
                    }
                }
                catch let err {
                    print("Failed to enumerate contact", err)
                }
                
            }
            else {
                print("Access Denied")
            }
        }
    }
    
    func getListOfContactsAPI(){
        
       
        /******Import  and initialize Util Class*****////
        let utililty = UtilClass()
        
        let device = utililty.getPhoneId()
        
        //print("shaDevicePpties")
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        
        //let data = list_numbers.description // "[1, 2, 3]"
        
        let joinedStrings = list_numbers.joined(separator: ",")
        //******getting parameter from string
        let params = ["AppID":device.sha512,"language":"en","RequestID": timeInSecondsToString, "SessionID": session, "CustomerID": customer_id, "type": "mobile", "mobileList": joinedStrings]
        
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
        
        
        let url = "\(utililty.url)user_search"
        
        postData(url: url, parameter: parameter, token: token, header: headers)
    }
    
    //MARK - VALIDATE
    ///////////***********Post Data MEthod*********////////
    func postData(url: String, parameter: [String: Any], token: String, header: [String: String]) {
        
        self.activityIndicator.startAnimating()
        self.viewWrapper.isUserInteractionEnabled = false
        
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
                    self.viewWrapper.isUserInteractionEnabled = true
                    
                    vpd_contacts = [VPDContacts]()
                    for i in decriptorJson["response"].arrayValue {
                        let new_contact = VPDContacts()
                        
                        new_contact.name = i["name"].stringValue
                        new_contact.phone = i["phone"].stringValue
                        new_contact.photo = i["photo"].stringValue
                        
                        vpd_contacts.append(new_contact)
                    }
                }
                else if  message == "Session has expired" {
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                else {
                    self.activityIndicator.stopAnimating()
                    self.viewWrapper.isUserInteractionEnabled = true
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
            }
            else {
                self.activityIndicator.stopAnimating()
                self.viewWrapper.isUserInteractionEnabled = true
                ////From the alert Service
                let alertService = AlertService()
                let alertVC = alertService.alert(alertMessage: "Newtwork Error")
                self.present(alertVC, animated: true)
            }
            self.tableview.reloadData()
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        
        return false
    }

    var request = false
    
    func requestButtonClicked() {
        request = true
        
        UIView.animate(withDuration: 0.4, delay: 0.3, options: [.curveEaseInOut], animations: {
            self.searchButtonLabel.alpha = 0
            self.searchTextField.alpha = 0
            self.lineView.alpha = 0

            self.contactImageView.isHidden = false
            self.requestsusinglink.isHidden = false
            self.requestFromContact.isHidden = false
            self.myContactHeader.isHidden = false
            self.vpdFriends.isHidden = false
            self.tableview.isHidden = false

            self.contactImageView.alpha = 1
            self.requestsusinglink.alpha = 1
            self.requestFromContact.alpha = 1
            self.myContactHeader.alpha = 1
            self.vpdFriends.alpha = 1
        })
        
        UIView.animate(withDuration: 0.5, delay: 0.2, options: [.curveEaseInOut], animations: {
            
            self.fundWalletHeightConstraingt.constant = 0 // 80
            self.transferTopConstraint.constant = 15 // 20
            self.transferHeightConstraint.constant = 0 // 80
            self.payBillTopConstraint.constant = 0 // 20
            self.payBillHeightConstraint.constant = 0 // 80
            //self.withdrawalHeightConstraint.constant = 0 //  80
            self.recurringPaymentHeight.constant = 0 // 80
            
            self.serviceHeightConstraint.constant = 0 // 80
            self.requestButtonHieght.constant = 15 // 110
            
            self.view.layoutIfNeeded()
        })
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
            self.button1.center.x += self.view.bounds.width
        })
        
        UIView.animate(withDuration: 0.5, delay: 0.1, options: [.curveEaseInOut], animations: {
            self.button2.center.x -= self.view.bounds.width
        })
        
        UIView.animate(withDuration: 0.5, delay: 0.2, options: [.curveEaseInOut], animations: {
            self.button3.center.x -= self.view.bounds.width
        })
        
        UIView.animate(withDuration: 0.5, delay: 0.2, options: [.curveEaseInOut], animations: {
            self.button4.center.x += self.view.bounds.width
        })
        
        UIView.animate(withDuration: 0.5, delay: 0.2, options: [.curveEaseInOut], animations: {
            self.button5.center.x += self.view.bounds.width
        })
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
            self.recurringPaymentButton.center.x += self.view.bounds.width
        })
        
        UIView.animate(withDuration: 0.5, delay: 0.5, options: [.curveEaseInOut], animations: {
            self.searchButtonLabel.alpha = 1.0
        })
    }
    
    func payButtonClicked() {
    
//        view.endEditing(true)
//        searchTextField.resignFirstResponder()
        if request == true {
            
            UIView.animate(withDuration: 0.4, delay: 0.3, options: [.curveEaseInOut], animations: {
                self.searchButtonLabel.alpha = 0
                self.searchTextField.alpha = 0
                self.lineView.alpha = 0

                self.contactImageView.alpha = 0
                self.requestsusinglink.alpha = 0
                self.requestFromContact.alpha = 0
                self.myContactHeader.alpha = 0
                self.vpdFriends.alpha = 0
                self.tableview.isHidden = true
            })
            
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
                self.button1.center.x -= self.view.bounds.width
            })
            
            UIView.animate(withDuration: 0.5, delay: 0.1, options: [.curveEaseInOut], animations: {
                self.button2.center.x += self.view.bounds.width
            })

            
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
                self.button3.center.x += self.view.bounds.width
            })
            
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
                self.button4.center.x -= self.view.bounds.width
            })
            
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
                self.button5.center.x -= self.view.bounds.width
            })
            
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
                self.recurringPaymentButton.center.x -= self.view.bounds.width
            })
            
            UIView.animate(withDuration: 0.5, delay: 0.2, options: [.curveEaseInOut], animations: {
                
                self.fundWalletHeightConstraingt.constant =  80
                self.transferTopConstraint.constant = 15
                self.transferHeightConstraint.constant = 80
                
                self.payBillTopConstraint.constant = 15
                self.payBillHeightConstraint.constant = 80
                //self.withdrawalHeightConstraint.constant = 80
                self.recurringPaymentHeight.constant = 80
                
                
             
                self.serviceHeightConstraint.constant = 80
                
                self.requestButtonHieght.constant = 110
                self.view.layoutIfNeeded()
            })
         
            request = false
        }
    }
    
    
    func searchButtonAnimate() {
        
        if request == true {
            
            UIView.animate(withDuration: 0.4, delay: 0.3, options: [.curveEaseInOut], animations: {
                self.searchTextField.alpha = 1.0
                self.lineView.alpha = 1.0
            })
        }
    }

    
    @IBAction func allButtonPressed(_ sender: UIButton) {
        
        switch sender.tag {
        case 1:
            payButtonClicked()
            payButton.backgroundColor = .white
            requestButton.backgroundColor = .clear
            
            payButton.setTitleColor(UIColor.black, for: .normal)
            requestButton.setTitleColor(UIColor.white, for: .normal)
            break
        case 2:
            requestButtonClicked()
            requestButton.setTitleColor(UIColor.black, for: .normal)
            payButton.setTitleColor(UIColor.white, for: .normal)
            payButton.backgroundColor = .clear
            requestButton.backgroundColor = .white
            
            break
        case 3:
            performSegue(withIdentifier: "goToFundWallet", sender: self)
            break
        case 4:
            performSegue(withIdentifier: "goToPaymentLink", sender: self)
            break
        case 5:
            performSegue(withIdentifier: "goToServices", sender: self)
            break
            
        case 6:
            performSegue(withIdentifier: "goToPopup", sender: self)
            break
            
        case 7:
            let vc = UIStoryboard.init(name: "ASSF", bundle: Bundle.main).instantiateViewController(withIdentifier: "assfCreateUser") as? ASSFScreen2ViewController
                self.navigationController?.pushViewController(vc!, animated: true)
            
            break
        default:
            performSegue(withIdentifier: "goToListRecurring", sender: self)
        }
    }
   
    
    @IBAction func searchButton(_ sender: Any) {
       searchButtonAnimate()
    }
    
   //MARK: - Prepare for segue
    var to_segue = ""
    
    @IBAction func goToLink(_ sender: Any) {
        to_segue = "link"
        performSegue(withIdentifier: "goToPaymentLink", sender: self)
    }
    
    //Protocol for popUp
    func goNext(next: String) {
        performSegue(withIdentifier: next, sender: self)
    }
    
    //MARK: - Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let walletId = currentWalletSelected["walletId"]
        let currency = currentWalletSelected["currency"]
        let balance = currentWalletSelected["balance"]
        
        
        if segue.identifier == "goToFundWallet" {
            let destinationVC = segue.destination as! FundWalletViewController
            destinationVC.walletID = walletId!
            destinationVC.currency = currency!
            destinationVC.balance = balance!
        }
            
        else if segue.identifier == "goToTransferToVPD" {
            let destination = segue.destination as! PayAContactViewController
            destination.from_segue = "transfer"
        }
            
        else if segue.identifier == "goToPopup" {
            let destinationVC = segue.destination  as! TransferPopupViewController
            
            destinationVC.from_segue = "transfer"
            destinationVC.delegate = self
        }
        
        else if segue.identifier == "goToPaymentLink" {
            let destinationVC = segue.destination as! PaymentLinkViewController
            destinationVC.from_segue = to_segue
            
            if to_segue == "contact link" {
                destinationVC.image = contact_image
                destinationVC.number = contact_number
                destinationVC.name = contact_name
            }
        }
        
    }
}

extension LandingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        searching ? searchData.count : vpd_contacts.count
     
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactTableViewCell
        cell.selectionStyle = .none
        
        if searching {
            let contact = searchData[indexPath.row]
            
            //cell.name_abbr.text = String(contact.name.prefix(2))
            print(contact)
            cell.name.text = contact.name
            cell.phoneNumber.text = contact.phone
            cell.thumnailImage!.sd_setImage(with: URL(string: contact.photo), placeholderImage: UIImage(named: ""))
        }
            
        else {
            let contact = vpd_contacts[indexPath.row]
            
            //cell.name_abbr.text = String(contact.name.prefix(2))
            print(contact)
            cell.name.text = contact.name
            cell.phoneNumber.text = contact.phone
            cell.thumnailImage!.sd_setImage(with: URL(string: contact.photo), placeholderImage: UIImage(named: ""))
        }
        
        

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexRow = indexPath.row
        if searching {
            let contact = searchData[indexRow]
            
            contact_name  = contact.name
            contact_number = contact.phone
            contact_image = contact.photo
        }
        else {
            let contact = vpd_contacts[indexRow]
            
            contact_name  = contact.name
            contact_number = contact.phone
            contact_image = contact.photo
        }
        
     
        to_segue = "contact link"
        performSegue(withIdentifier: "goToPaymentLink", sender: self)
        
    }
    
    
}
