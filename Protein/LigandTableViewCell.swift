//
//  LigandTableViewCell.swift
//  Protein
//
//  Created by Antoine LEBLANC on 12/11/17.
//  Copyright © 2017 Antoine LEBLANC. All rights reserved.
//

import UIKit

class LigandTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var downloaded: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
