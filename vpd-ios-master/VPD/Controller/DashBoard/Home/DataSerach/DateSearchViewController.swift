//
//  DateSearchViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 02/10/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import FSCalendar
import SwiftyJSON
import Alamofire

class DateSearchViewController: UIViewController {

    @IBOutlet var viewWrapper: UIView!
    @IBOutlet weak var dateViewWrapper: DesignableView!
    
    private weak var calendar: FSCalendar!
    @IBOutlet weak var serachButton: DesignableButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var from_segue = ""
    var transction_history = [TransactionHistory]()
    // first date in the range
    private var firstDate: Date?
    // last date in the range
    private var lastDate: Date?
    
    private var datesRange: [Date]?
    
    var delegate: passSelectedObj?
    
    private var converted_firstDate = ""
    private var converted_lastDate = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Do any additional setup after loading the view.
        let calendar = FSCalendar(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        calendar.dataSource = self
        calendar.delegate = self
        calendar.register(FSCalendarCell.self, forCellReuseIdentifier: "cell")
        
        calendar.translatesAutoresizingMaskIntoConstraints = false
        dateViewWrapper.addSubview(calendar)
        
        calendar.leadingAnchor.constraint(equalTo: dateViewWrapper.leadingAnchor).isActive = true
        calendar.trailingAnchor.constraint(equalTo: dateViewWrapper.trailingAnchor).isActive = true
        calendar.topAnchor.constraint(equalTo: dateViewWrapper.topAnchor).isActive = true
        calendar.bottomAnchor.constraint(equalTo: dateViewWrapper.bottomAnchor).isActive = true
        self.calendar = calendar
        
        
        calendar.allowsMultipleSelection = true

    }
    
    func datesRange(from: Date, to: Date) -> [Date] {
        // in case of the "from" date is more than "to" date,
        // it should returns an empty array:
        if from > to { return [Date]() }
        
        var tempDate = from
        var array = [tempDate]
        
        while tempDate < to {
            tempDate = Calendar.current.date(byAdding: .day, value: 1, to: tempDate)!
            array.append(tempDate)
        }
        
        return array
    }
    

    @IBAction func searchButtonClicked(_ sender: Any) {
        
        let current_date = Date()
        
        if datesRange == nil || datesRange!.count < 2 {
            let alert = AlertService()

            let alertVC =  alert.alert(alertMessage: "Invalid Date Selected ")
            self.present(alertVC, animated: true)
        }

        if datesRange == nil || datesRange![0] > current_date   {

            let alert = AlertService()

            let alertVC =  alert.alert(alertMessage: "Make sure to Select a valid Date range")
            self.present(alertVC, animated: true)
        }

        if datesRange == nil  || datesRange![datesRange!.count - 1] > current_date {
            let alert = AlertService()

            let alertVC =  alert.alert(alertMessage: "Date choosen should not be greater than current date.")
            self.present(alertVC, animated: true)
        }

        else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"

            converted_firstDate = dateFormatter.string(from: datesRange![0])
            converted_lastDate = dateFormatter.string(from: datesRange![datesRange!.count - 1])

            //Here is where to call post function
            print (converted_firstDate, converted_lastDate)
            delegate?.passingData(segue: "goToTransactionHistory", type: converted_firstDate , abbr: converted_lastDate)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension DateSearchViewController: FSCalendarDataSource, FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position)
        
        return cell
    }
    
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        //let current_date = Date()
        
        // nothing selected:
        if firstDate == nil {
            firstDate = date
            datesRange = [firstDate!]
            
            //print("datesRange contains: \(datesRange!)")
            
            return
        }
        
        // only 2222first date is selected:
//        if firstDate != nil && lastDate == nil {
//            // handle the case of if the last date is less than the first date:
//            if current_date < lastDate! {
//                calendar.deselect(lastDate!)
//                lastDate = date
//                datesRange = [lastDate!]
//                
//                //print("datesRange contains: \(datesRange!)")
//                
//                return
//            }
//            
//        }

  
        // only first date is selected:
        if firstDate != nil && lastDate == nil {
            // handle the case of if the last date is less than the first date:
            if date <= firstDate! {
                calendar.deselect(firstDate!)
                firstDate = date
                datesRange = [firstDate!]
                
                //print("datesRange contains: \(datesRange!)")
                
                return
            }
            
            let range = datesRange(from: firstDate!, to: date)
            
            lastDate = range.last
            
            for d in range {
                calendar.select(d)
            }
            
            datesRange = range
            
            //print("datesRange contains: \(datesRange!)")
            
            return
        }
        
        
        // both are selected:
        if firstDate != nil && lastDate != nil {
            for d in calendar.selectedDates {
                calendar.deselect(d)
            }
            
            lastDate = nil
            firstDate = nil
            
            datesRange = []
            
            //print("datesRange contains: \(datesRange!)")
        }
    }
    
    //MARK: Overide prepare segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToTransactionList" {
            let destination = segue.destination as! TransactionHistorySearchViewController

            destination.transactionHistoryFiltered = transction_history
        }
    }
}
