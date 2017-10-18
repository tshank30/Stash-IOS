//
//  HCollectionReusableView.swift
//  NewProject
//
//  Created by Shashank Tiwari on 12/10/17.
//  Copyright © 2017 Shashank Tiwari. All rights reserved.
//

import UIKit

class HCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var headerText: UILabel!
    static var nibName : String
    {
        get { return "headerNIB"}
    }
    
    static var reuseIdentifier: String
    {
        get { return "headerCell"}
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
