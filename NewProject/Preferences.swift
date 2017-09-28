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
    let dayCountKey = "DayCount"
    let runCount = "FirstTime"
    let resultScreen = "ResultScreen"
    let reviewScreen = "ReviewScreen"
    let datePref = "datePreference"
    
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
    
    
    func setDayCountDimension() -> String
    {
        print(getDayCountDimension()+1)
        preferences.set(getDayCountDimension()+1, forKey : dayCountKey)
        
        return "\(getDayCountDimension())"
    }
    
    func getDayCountDimension() -> Int
    {
        if(preferences.object(forKey: dayCountKey) != nil)
        {
            return preferences.object(forKey: dayCountKey) as! Int
        }
        else{
            return 0
        }
    }
    
    func setRunCountPreference() -> String
    {
        preferences.set(getRunCountPreference()+1, forKey : runCount)
        return "\(getRunCountPreference())";
    }
    
    func getRunCountPreference() -> Int
    {
        if(preferences.object(forKey: runCount) != nil)
        {
        return preferences.object(forKey: runCount) as! Int
        }
        else{
            return 0
        }
    }
    
    func setResultScreenPreference() -> String
    {
        preferences.set(getResultScreenPreference()+1, forKey : resultScreen)
        
        return "\(getResultScreenPreference())"
    }
    
    func getResultScreenPreference() -> Int
    {
        if(preferences.object(forKey: resultScreen) != nil)
        {
        return preferences.object(forKey: resultScreen) as! Int
        }
        else{
            return 0
        }
    }
    
    func setReviewScreenPreference() -> String
    {
        preferences.set(getReviewScreenPreference()+1, forKey : reviewScreen)
        return "\(getReviewScreenPreference())"
    }
    
    func getReviewScreenPreference() -> Int
    {
        if(preferences.object(forKey: reviewScreen) != nil)
        {
        return preferences.object(forKey: reviewScreen) as! Int
        }
        else{
            return 0
        }
    }
    
    func getDayTimePreference() -> String
    {
       if(preferences.object(forKey: datePref) != nil)
       {
        return preferences.object(forKey: datePref) as! String
        }
       else{
        return ""
        }
    }
    
    func setDayTime(date : String)
    {
        preferences.set(date, forKey : datePref)
    }
    
    
}
