//
//  CollectionViewCell.swift
//  NewProject
//
//  Created by Shashank Tiwari on 24/07/17.
//  Copyright © 2017 Shashank Tiwari. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
   // @IBOutlet weak var selectionImage: UIImageView!

    
    @IBOutlet weak var newImage: UIImageView!
    
    @IBOutlet weak var selection: UIButton!
    
    @IBAction func unSelectImage(_ sender: UIButton) {
        
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
        /**/
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func imageSelection()
    {
        if(selection.currentImage==UIImage(named:"partial_checked"))
        {
            if let image = UIImage(named:"checked") {
                selection.setImage( UIImage(named:"checked.png"), for: .normal)
            }
        }
        else
        {
            if let image = UIImage(named:"partial_checked") {
                selection.setImage(UIImage(named:"partial_checked.png"), for: .normal)
            }
        }

    }
}
