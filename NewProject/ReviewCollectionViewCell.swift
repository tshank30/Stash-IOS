//
//  ReviewCollectionViewCell.swift
//  NewProject
//
//  Created by Shashank Tiwari on 17/08/17.
//  Copyright © 2017 Shashank Tiwari. All rights reserved.
//

import UIKit

class ReviewCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var checkBox: UIImageView!
    @IBOutlet weak var opaqueView: UIView!
    @IBOutlet weak var image: UIImageView!
   // @IBOutlet weak var checkBox: UIButton!
    /*@IBAction func Selection(_ sender: UIButton) {
    
        
        if(sender.currentImage==UIImage(named:"partial_checked"))
        {
            if let image = UIImage(named:"checked") {
                sender.setImage( UIImage(named:"checked.png"), for: .normal)
            }
        }
        else
        {
            if let image = UIImage(named:"partial_checked") {
                sender.setImage(UIImage(named:"partial_checked.png"), for: .normal)
            }
        }

    }*/
    
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
