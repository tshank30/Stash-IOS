//
//  CollectionHeader.swift
//  NewProject
//
//  Created by Shashank Tiwari on 02/08/17.
//  Copyright © 2017 Shashank Tiwari. All rights reserved.
//

import UIKit

class CollectionHeader: UICollectionReusableView {
    
    @IBOutlet weak var ImageCount: UILabel!
    
    @IBOutlet weak var checkBox: UIImageView!
  
    @IBOutlet weak var onBackPressed: UIButton!
        
    @IBAction func onBackPressed(_ sender: UIButton) {
        
        //navigationController.popViewControllerAnimated(true)
    }
}


    
