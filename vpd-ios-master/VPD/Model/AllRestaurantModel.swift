//
//  AllRestaurantModel.swift
//  VPD
//
//  Created by Ikenna Udokporo on 16/12/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import Foundation

class AllRestaurant {
    var  city =  [ "name" : "", "_id" : ""]
    var banner = ""
    var image = ""
    var name = ""
    var address =  ""
    var delivery = ""
    var location =  ["name" : "", "_id" : ""]
    var _id = ""
    var rating = ""
    var cuisines = [Cuisines]()
    var openings = [ "weekends" : "", "weekdays" : ""]
    var allow_review = true
    var pack_fee = [PackFee]()
    var contact = ["name" : "", "phone" : "", "email" : ""]
    var geo = [
      "latitude" : "",
      "address_formatted" : "",
      "place_id" : "",
      "longitude" : ""
    ]
}

class Cuisines  {
    var _id = ""
    var name = ""
}

class PackFee {
    var _id =  ""
    var amount = ""
    var category = [ "name" : "", "_id" : ""]
}

