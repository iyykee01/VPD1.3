//
//  MovieCategories.swift
//  VPD
//
//  Created by Ikenna Udokporo on 28/11/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import Foundation

class MovieCategory {
    
    var duration = ""
    var description = ""
    var banner = ""
    var genre = ""
    var ageRestriction = ""
    var mid = ""
    var thumbImage =  ""
    var title = ""
    var showtime = [ShowTime]()
    
}

class ShowTime {
    
    var day =  ""
    var date =  ""
    var screenName =  ""
    var time =  ""
    var showtimeID =  ""
    var ticketType =  [TicketType]()
    var seatsAvailable =  ""
    var mid = ""
    var selected = false
}

class TicketType {
    
    var attribute = ""
    var group = ""
    var price = ""
    var ticketID = ""
    var isSelected = false
    var mid = ""
    var showtimeID =  ""
    var day =  ""
    var date =  ""
    var time =  ""
    var u_id = ""
    var count = 0

}

