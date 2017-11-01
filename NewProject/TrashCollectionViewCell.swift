//
//  TrashCollectionViewCell.swift
//  NewProject
//
//  Created by Shashank Tiwari on 12/09/17.
//  Copyright © 2017 Shashank Tiwari. All rights reserved.
//

import UIKit

class TrashCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var checkBox: UIImageView!
    @IBOutlet weak var opaqueView: UIView!
    @IBOutlet weak var image: UIImageView!
    
    override func awakeFromNib() {
        image.layer.cornerRadius = 8
        image.clipsToBounds = true
        image.contentMode = .scaleToFill
    }
    
    
    func imageSelection() -> Bool
    {
        if(checkBox.image==UIImage(named:"partial_checked"))
        {
            if let image = UIImage(named:"checked") {
                checkBox.image = image
                opaqueView.isHidden=true
            }
            return true
        }
        else
        {
            if let image = UIImage(named:"partial_checked") {
                checkBox.image = image
                opaqueView.isHidden=false
            }
            return false
        }
        
    }
    
}
