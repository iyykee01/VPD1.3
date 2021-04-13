//
//  MealTableViewCell.swift
//  VPD
//
//  Created by Ikenna Udokporo on 17/12/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class MealTableViewCell: UITableViewCell {

    @IBOutlet weak var menuImage: UIImageView!
    @IBOutlet weak var meal_name: UILabel!
    @IBOutlet weak var meal_price: UILabel!
    @IBOutlet weak var rating: UIView!
  
    @IBOutlet weak var plusImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
