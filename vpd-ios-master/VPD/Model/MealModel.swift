//
//  MealModel.swift
//  VPD
//
//  Created by Ikenna Udokporo on 17/12/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import Foundation

class Meal {
   
    var is_selected = false
    var pack_fee = [String]()
    var amount = ""
    var name =  ""
    var description = ""
    var pack = ""
    var vat_amount = ""
    var image = ""
    var _id = ""
    var  sorts = ""
    var container_amount = ""
    var restuarant = [Restaurant]()
    var pickings = [String]()
    var options = [String]()
    var category =  ["_id" : "", "name" : ""]
    var count = 1
    var choice = [String]()
}



class Restaurant {
    var _id =  ""
    var pack_fee = [PackFee_meals]()
    var name = ""
}

class PackFee_meals {
    var category =  ""
    var amount =  ""
    var _id =  ""
}
    





