//
//  MovieShowTimeTableViewCell.swift
//  VPD
//
//  Created by Ikenna Udokporo on 03/12/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class MovieShowTimeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var forward_arrow: UIImageView!
    
    @IBOutlet weak var viewToColor: DesignableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization cod

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
