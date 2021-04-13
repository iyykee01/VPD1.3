//
//  HelpViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 22/08/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit


class HelpViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textViewMessage: UITextView!
    @IBOutlet weak var hieghtConstraint: NSLayoutConstraint!

    
    var keyboardHieght: CGRect?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 65
        textViewMessage.delegate = self
        
        
        
        let firstname = "Ikenna" //LoginResponse["response"]["lastname"].stringValue
        
        nameLable.text = "Hi \(firstname)"
        configureTableView()
        textViewConfig()
        
        
    }
    
 
    
//
//    @objc func keyboardwillChange(notification: Notification) {
////
////        guard   let userInfo = notification.userInfo as? [String: NSObject],
////            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect  else { return }
////
////        keyboardHieght = keyboardFrame
////        print(keyboardHieght, "lsksjkskjskjksksjj")
////
////    }
    
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
       
        hieghtConstraint.constant = KeyboardService.keyboardHeight()
        view.layoutIfNeeded()
        return true
    }
    
    func textViewConfig() {
        textViewMessage.font = .systemFont(ofSize: 14, weight: .semibold)
        
        textViewMessage.text = "Write a message"
        textViewMessage.textColor = .lightGray
        textViewMessage.centerVertically()
        //textViewMessage.textAlignment = .center
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write a message"
            textView.textColor = .lightGray
            textViewMessage.centerVertically()
        }
    }
    
     func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count + (text.count - range.length) <= 140
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        print("Backkked")
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        view.endEditing(true)
        hieghtConstraint.constant = 75
        print("Message sent from VPD")
    }
    
    
    func configureTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 65.0
    }
}

extension HelpViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatText", for: indexPath) as! HelpChatTableViewCell
        cell.selectionStyle = .none
        
        let array = ["First message", "Second Message skkjskjfkljskjkcjfks jfkjskfj dsf dsjk sj fksjkjf klsjf s  skjfsklj fk sjflksjkfj lskjksj", "Third Message"]
        
        cell.messageText.text = array[indexPath.row]
        
        return cell
    }
    
    
}


import UIKit

class KeyboardService: NSObject {
    static var serviceSingleton = KeyboardService()
    var measuredSize: CGRect = CGRect.zero

    @objc class func keyboardHeight() -> CGFloat {
        let keyboardSize = KeyboardService.keyboardSize()
        return keyboardSize.size.height
    }

    @objc class func keyboardSize() -> CGRect {
        return serviceSingleton.measuredSize
    }

    private func observeKeyboardNotifications() {
        let center = NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardChange), name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    private func observeKeyboard() {
        let field = UITextField()
        UIApplication.shared.windows.first?.addSubview(field)
        field.becomeFirstResponder()
        field.resignFirstResponder()
        field.removeFromSuperview()
    }

    @objc private func keyboardChange(_ notification: Notification) {
        guard measuredSize == CGRect.zero, let info = notification.userInfo,
            let value = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
            else { return }

        measuredSize = value.cgRectValue
    }

    override init() {
        super.init()
        observeKeyboardNotifications()
        observeKeyboard()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


