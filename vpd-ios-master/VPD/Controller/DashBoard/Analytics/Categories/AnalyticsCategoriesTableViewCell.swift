//
//  AnalyticsCategoriesTableViewCell.swift
//  VPD
//
//  Created by Ikenna Udokporo on 24/01/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit

class AnalyticsCategoriesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var image_transaction: UIImageView!
    @IBOutlet weak var category_name: UILabel!
    @IBOutlet weak var numbers_of_transactions: UILabel!
    
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var percentage: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        progressBar.transform = progressBar.transform.scaledBy(x: 1, y: 1.5)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
