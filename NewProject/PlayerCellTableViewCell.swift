//
//  PlayerCellTableViewCell.swift
//  NewProject
//
//  Created by Shashank Tiwari on 19/07/17.
//  Copyright © 2017 Shashank Tiwari. All rights reserved.
//

import UIKit

class PlayerCellTableViewCell: UITableViewCell {

    @IBOutlet weak var playerImage: UIImageView!
    @IBOutlet weak var playerGame: UILabel!
    @IBOutlet weak var playerName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
