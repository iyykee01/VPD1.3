//
//  EventDetailsViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 04/10/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import SDWebImage

class EventDetailsViewController: UIViewController {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var labelDes: UILabel!
    @IBOutlet weak var eventfee: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var from_segue: Event!
    //var from_segue_location: Location!
    
    
    var select_ticket: Tickets!
    var ticket_id = [Tickets]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        image.sd_setImage(with: URL(string: from_segue.banner), placeholderImage: UIImage(named: ""))
        
        titleLabel.text = from_segue.title
        labelDes.text = from_segue.description
        
        
        tableView.rowHeight = 120
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
        for i in from_segue.location {
            location.text = i.venue
            
            for j in i.dates {
                date.text = j.date
                if j.time.count > 1 {
                    timeLabel.text = "\(j.time[0]) - \(j.time[1])"
                }
                else {
                    timeLabel.text = j.time[0]
                }
                
            }
        }
        
        
    }

 
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func getTicketButtonPressed(_ sender: Any) {
        
        if ticket_id.count == 0 {
            //show alert here
            ////From the alert Service
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "No ticket selected")
            self.present(alertVC, animated: true)
        }
        else {
            performSegue(withIdentifier: "goToTicketAmount", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! EventBookingViewController
        destination.from_segue = select_ticket
        
    }
    
}


extension EventDetailsViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return from_segue.tickets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EventTicketFeeTableViewCell
        
        cell.selectionStyle = .none
        let dictionary = from_segue.tickets[indexPath.row]
        
        if ticket_id.count == 1 && ticket_id[0].id == dictionary.id {
            cell.viewSelect.backgroundColor = UIColor(hexFromString: "#34B5CE")
            cell.priceLabel.textColor = .white
            cell.vipLabel.textColor = .white
            cell.venueLabel.textColor = .white
        }
        else {
            cell.viewSelect.backgroundColor = .white
            cell.priceLabel.textColor = .black
            cell.vipLabel.textColor = .black
            cell.venueLabel.textColor = .black
        }
        
        
        cell.vipLabel.text = dictionary.title
        cell.venueLabel.text = dictionary.venue
        
        let price_to_int = Int(dictionary.price)
        cell.priceLabel.text = price_to_int!.withCommas()
       
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        select_ticket = from_segue.tickets[indexPath.row]
        select_ticket.is_selected.toggle()
        
        if ticket_id.count == 1  {
            ticket_id[0].is_selected.toggle()
            ticket_id = [Tickets]()
            ticket_id.append(select_ticket)
        }
        
        if ticket_id.count == 0 {
           ticket_id.append(select_ticket)
        }

        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
}

extension Int {
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}

