//
//  Preferences.swift
//  NewProject
//
//  Created by Shashank Tiwari on 15/09/17.
//  Copyright © 2017 Shashank Tiwari. All rights reserved.
//

import Foundation


import Foundation
import UIKit


class Preferences
{
    static let shared:Preferences=Preferences()
    var preferences : UserDefaults
    let firstTimeKey = "FirstTime"
    
    init() {
        preferences = UserDefaults.standard
    }
    
    func setfistTimePreference()
    {
        preferences.set(true, forKey : firstTimeKey)
    }
    
    func getFirstTimePreference() -> Bool
    {
        return (preferences.object(forKey: firstTimeKey) != nil)
    }
    
}
