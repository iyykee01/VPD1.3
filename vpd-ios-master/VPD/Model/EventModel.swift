//
//  EventModel.swift
//  VPD
//
//  Created by Ikenna Udokporo on 18/12/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import Foundation
import SwiftyJSON

class Event {
    var thumbnail = ""
    var title = ""
    var id = ""
    var location = [Location]()
    var ageRestriction = ""
    var banner = ""
    var description = ""
    var tickets = [Tickets]()
}

class Location {
    var venue = ""
    var dates = [Dates]()
}

class Dates {
    var time = [String]()
    var date = ""
}

class Tickets {

    var id =  ""
    var title =  ""
    var price =  ""
    var venue =  ""
    var is_selected = false
}

     
