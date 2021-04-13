//
//  HelpChatTableViewCell.swift
//  VPD
//
//  Created by Ikenna Udokporo on 29/04/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit

class HelpChatTableViewCell: UITableViewCell {

    @IBOutlet weak var messageText: UILabel!
    @IBOutlet weak var tableViewView: UIView!
    @IBOutlet weak var leftConstraintTableview: NSLayoutConstraint!
       @IBOutlet weak var rightConstraintTableview: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
