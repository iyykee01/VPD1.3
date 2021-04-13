//
//  InviteFriendsTableViewCell.swift
//  VPD
//
//  Created by Ikenna Udokporo on 20/11/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class InviteFriendsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberLable: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
