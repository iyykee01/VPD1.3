//
//  NotificationTableViewCell.swift
//  VPD
//
//  Created by Ikenna Udokporo on 19/02/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var viewWrapper: DesignableView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    
    
    @IBOutlet weak var viewWrapper2: UIView!
    @IBOutlet weak var headerLabel2: UILabel!
    @IBOutlet weak var bodyLabel2: UILabel!
    @IBOutlet weak var button2: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        viewWrapper.isHidden = false
        viewWrapper2.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
   
}
