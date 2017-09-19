//
//  UtilityMethods.swift
//  NewProject
//
//  Created by Shashank Tiwari on 02/08/17.
//  Copyright © 2017 Shashank Tiwari. All rights reserved.
//

import Foundation
import UIKit

class UtilityMethods
{
    
     static let shared:UtilityMethods=UtilityMethods()
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
   
    
   
}
