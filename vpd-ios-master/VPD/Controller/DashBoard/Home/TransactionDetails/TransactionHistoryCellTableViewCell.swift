//
//  TransactionHistoryCellTableViewCell.swift
//  VPD
//
//  Created by Ikenna Udokporo on 04/11/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class TransactionHistoryCellTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var transactionImage: UIImageView!
    @IBOutlet weak var sideLable: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


