//
//  FoodRestaurantableViewCell.swift
//  VPD
//
//  Created by Ikenna Udokporo on 16/12/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class FoodRestaurantableViewCell: UITableViewCell {

    @IBOutlet weak var imageForCell: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var fee: UILabel!
    @IBOutlet weak var openTime: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var kmAway: UILabel!
    @IBOutlet weak var ratingView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    

}
