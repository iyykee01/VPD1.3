//
//  ReviewTableViewCell.swift
//  VPD
//
//  Created by Ikenna Udokporo on 28/01/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnail_image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var hours: UILabel!
    @IBOutlet weak var cosmos_view: UIView!
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var body: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
