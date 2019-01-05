//
//  VenueCell.swift
//  Venues
//
//  Created by Rajesh Budhiraja on 03/01/19.
//  Copyright © 2019 Rajesh Budhiraja. All rights reserved.
//

import UIKit

class VenueCell: UITableViewCell {

 
    
    //MARK: IBOutlets
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var distance: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
