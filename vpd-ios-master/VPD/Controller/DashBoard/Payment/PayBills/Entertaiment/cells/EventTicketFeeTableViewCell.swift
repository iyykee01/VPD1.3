//
//  EventTicketFeeTableViewCell.swift
//  VPD
//
//  Created by Ikenna Udokporo on 20/12/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class EventTicketFeeTableViewCell: UITableViewCell {
    

    @IBOutlet weak var vipLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var venueLabel: UILabel!
    @IBOutlet weak var viewSelect: DesignableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
