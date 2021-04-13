//
//  CheckoutTableViewCell.swift
//  VPD
//
//  Created by Ikenna Udokporo on 27/01/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit

class CheckoutTableViewCell: UITableViewCell {

    @IBOutlet weak var food_name: UILabel!
    @IBOutlet weak var amount_label: UILabel!
    @IBOutlet weak var price_label: UILabel!
    
    var cellDelegate: handleMaths?
       var index: IndexPath?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
       @IBAction func additionButtonPressed(_ sender: Any) {
           cellDelegate?.addition(counter: (index?.row)!)
       }
       
       @IBAction func subractionButtonPressed(_ sender: Any) {
           cellDelegate?.subtract(counter: (index?.row)!)
       }

}
