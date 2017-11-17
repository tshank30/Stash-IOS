//
//  HCollectionReusableView.swift
//  NewProject
//
//  Created by Shashank Tiwari on 12/10/17.
//  Copyright © 2017 Shashank Tiwari. All rights reserved.
//

import UIKit

class HCollectionReusableView: UICollectionReusableView {
    
    //@IBOutlet weak var headerScanningView: UIView!
    @IBOutlet weak var headerText: UILabel!
  
    //@IBOutlet weak var scanningViewHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        headerScanningView.layer.cornerRadius = 4
//        headerScanningView.clipsToBounds = true
    }
}
