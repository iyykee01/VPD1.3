//
//  TableViewCell.swift
//  VPD
//
//  Created by Ikenna Udokporo on 19/11/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class InviteFriendsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var initailsLable: UILabel!
    @IBOutlet weak var nameLable: UILabel!
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
