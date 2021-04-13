//
//  MovieCellTableViewCell.swift
//  VPD
//
//  Created by Ikenna Udokporo on 28/11/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

protocol handleMaths {
    func subtract(counter: Int)
    func addition(counter: Int)
}

class CinemaTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cinemaLabel_location: UILabel!
    @IBOutlet weak var cinema_country: UILabel!
    @IBOutlet weak var viewColor: DesignableView!
    @IBOutlet weak var count_label: UILabel!
    
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
