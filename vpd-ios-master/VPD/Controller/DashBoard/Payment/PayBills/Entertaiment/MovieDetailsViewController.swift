//
//  MovieShowingViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 27/09/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import Cosmos
import SDWebImage

class MovieDetailsViewController: UIViewController {
    
    var movie_selected: MovieCategory!
    var selected_showtime_id =  ""
    
    var selected_ticket_type = [TicketType]()
    
    
    var ticket_uid = ""
    var cid = ""
    var mid = ""
    var showtimeID = ""
    
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movie_rating: UIView!
    @IBOutlet weak var movie_description: UILabel!
    @IBOutlet weak var starRatingView: UIView!
    @IBOutlet weak var pg_duration: UILabel!
    
    @IBOutlet weak var genre1: UILabel!
    @IBOutlet weak var genre2: UILabel!
    @IBOutlet weak var genre3: UILabel!
    
    var cinema_location = ""
    var genre = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
  
        print(String(describing: movie_selected))
  
        tableview.delegate = self
        tableview.dataSource = self
        
        
        movieTitle.text = movie_selected.title
        movie_description.text = movie_selected.description
        backgroundImage.sd_setImage(with: URL(string: movie_selected.banner), placeholderImage: UIImage(named: ""))
        pg_duration.text = "\(movie_selected.ageRestriction) | \(movie_selected.duration )"
        location.text = cinema_location
        
        //for genre
        let genre_array = movie_selected.genre.split(separator: ",")
        let genre_array_count = genre_array.count
    
        
        switch genre_array_count {
        case 1:
            genre1.text = String(genre_array[0])
            break
        case 2:
            genre1.text = String(genre_array[0])
            genre2.text = String(genre_array[1])
            break
        case 3:
            genre1.text = String(genre_array[0])
            genre2.text = String(genre_array[1])
            genre3.text = String(genre_array[2])
            break
        case 4:
            genre1.text = String(genre_array[0])
            genre2.text = String(genre_array[1])
            genre3.text = String(genre_array[2])
            break
        default:
            print("nil")
            
        }
        tableview.rowHeight = 80
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! MovieBookingViewController
        destination.from_segue = selected_ticket_type
        destination.mid = mid
        destination.cid = cid
        destination.showtimeID = showtimeID
        destination.movie_selected = movie_selected
    }
    
}


extension MovieDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movie_selected.showtime.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "showTimeCell", for: indexPath) as! MovieShowTimeTableViewCell
        
        
        
        let showtime = movie_selected.showtime
        let dictionary = showtime[indexPath.row]
     
        
        let date = Date.dateFromCustom(customString: dictionary.date)
        let customDate = Date.dateFormaterMonth(date: date)
        let split_date = customDate.split(separator: " ")
        
        
        if split_date[0] == "1" {
            cell.dateLabel.text = "Date: \(dictionary.day), \(split_date[0])st \(split_date[1]) \(split_date[2])"
        }
        else {
            cell.dateLabel.text = "Date: \(dictionary.day), \(split_date[0])th \(split_date[1]) \(split_date[2])"
        }
        
        if showtimeID == dictionary.showtimeID {
            cell.viewToColor.backgroundColor = UIColor(hexFromString: "#34B5CE")
        }
        else {
            cell.viewToColor.backgroundColor = .darkGray
        }
        

        cell.timeLabel.text = "Time: \(dictionary.time)"
        cell.forward_arrow.image = UIImage(named: "cell_forward")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
 
        selected_ticket_type = movie_selected.showtime[indexPath.row].ticketType
        mid = movie_selected.mid
        showtimeID = movie_selected.showtime[indexPath.row].showtimeID
        
        
        if selected_ticket_type.count != 0 {
            performSegue(withIdentifier: "goToMovieTicket", sender: self)
        }
        else {
            showToast(message: "No Ticket available for this movie", font: UIFont(name: "Muli", size: 14)!)
      
        }
        tableView.reloadData()
    }
  
    
}


    

 
