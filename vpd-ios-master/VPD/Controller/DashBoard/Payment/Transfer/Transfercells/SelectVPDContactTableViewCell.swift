//
//  SelectVPDContactTableViewCell.swift
//  VPD
//
//  Created by Ikenna Udokporo on 06/02/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit

class SelectVPDContactTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnail_image: UIImageView!
    @IBOutlet weak var vpd_name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
