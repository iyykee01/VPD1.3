//
//  HideSubAccountTableViewCell.swift
//  VPD
//
//  Created by Ikenna Udokporo on 07/02/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit

class HideSubAccountTableViewCell: UITableViewCell {

    @IBOutlet weak var imageThumbnail: UIImageView!
    @IBOutlet weak var currency: UILabel!
    @IBOutlet weak var name_of_currency: UILabel!
    
    @IBOutlet weak var hidden_image: UIImageView!
    @IBOutlet weak var hide_sub_acct: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
