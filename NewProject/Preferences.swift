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
    let firstTimeInsertion = "FirstTimeInsertion"
    let dayCountKey = "DayCount"
    let runCount = "FirstTime"
    let resultScreen = "ResultScreen"
    let reviewScreen = "ReviewScreen"
    let datePref = "datePreference"
    let firstTimeHomeScreenGa = "firstTimeHomeScreenGa"
    let firstTimeReviewScreenGa = "firstTimeReviewScreenGa"
    let firstTimeResultScreenGa = "firstTimeResultScreenGa"
    let firstTimeTrashScreenGa = "firstTimeTrashScreenGa"
    let firstTimeDeletionScreenGa = "firstTimeDeletionScreenGa"
    let firstTimeDeletionConfScreenGa = "firstTimeDeletionConfScreenGa"
    
    let splashFirstTimeCounter = "splashFirstTimeCounter"
    let homeScreenFirstTimeAnalyticsSent = "homeFirstTimeCounter"
    let homeScreenFirstTimeAnalyticsSentEvent = "homeFirstTimeCounterEvent"
    let reviewScreenFirstTimeAnalyticsSent = "reviewFirstTimeCounter"
    let fromTrashBtnLandig = "fromTrashBtnLanding"
    
    init() {
        preferences = UserDefaults.standard
    }
    
    
    func getFromTrashBtnLanding() -> Bool
    {
        return preferences.bool(forKey: fromTrashBtnLandig)
    }
    
    func setFromTrashBtnLanding(landing : Bool)
    {
         preferences.set(landing,forKey: fromTrashBtnLandig)
    }
    
    func getFirstTimeSplashCounter() -> Int
    {
        let value=preferences.integer(forKey: splashFirstTimeCounter)
        print("Splash Counter Value ",value)
        
        return value
        
    }
    
    func setFirstTimeSplashCounter()
    {
        preferences.set((1+getFirstTimeSplashCounter()), forKey : splashFirstTimeCounter)
    }
    
    func getFirstTimeHomeScreenAnalyticsSent() -> Bool
    {
        let pref=preferences.bool(forKey: homeScreenFirstTimeAnalyticsSent)
        return pref
        
    }
    
    func setFirstTimeHomeScreenAnalyticsSent()
    {
        preferences.set(true, forKey : homeScreenFirstTimeAnalyticsSent)
    }
    
    func getFirstTimeHomeScreenAnalyticsSentEvent() -> Bool
    {
        let pref=preferences.bool(forKey: homeScreenFirstTimeAnalyticsSentEvent)
        return pref
        
    }
    
    func setFirstTimeHomeScreenAnalyticsSentEvent()
    {
        preferences.set(true, forKey : homeScreenFirstTimeAnalyticsSentEvent)
    }
    
    func getFirstTimeReviewScreenAnalyticsSent() -> Bool
    {
        return preferences.bool(forKey: reviewScreenFirstTimeAnalyticsSent)
        
    }
    
    func setFirstTimeReviewScreenAnalyticsSent()
    {
        preferences.set(true, forKey : reviewScreenFirstTimeAnalyticsSent)
    }
    
    
    
    func getFirstTimeHomeScreenGaPreference() -> Bool
    {
        return preferences.bool(forKey: firstTimeHomeScreenGa)
    }
    
    func setFirstTimeHomeScreenGaPreference()
    {
        preferences.set(true, forKey : firstTimeHomeScreenGa)
    }
    
    func getFirstTimeDeletionConfScreenGaPreference() -> Bool
    {
        return preferences.bool(forKey: firstTimeDeletionConfScreenGa)
    }
    
    func setFirstTimeDeletionConfScreenGaPreference()
    {
        preferences.set(true, forKey : firstTimeDeletionConfScreenGa)
    }
    
    func getFirstTimeReviewScreenGaPreference() -> Bool
    {
        return preferences.bool(forKey: firstTimeReviewScreenGa)
    }
    
    func setFirstTimeReviewScreenGaPreference()
    {
        preferences.set(true, forKey : firstTimeReviewScreenGa)
    }
    
    func getFirstTimeResultScreenGaPreference() -> Bool
    {
        return preferences.bool(forKey: firstTimeResultScreenGa)
    }
    
    func setFirstTimeResultScreenGaPreference()
    {
        preferences.set(true, forKey : firstTimeResultScreenGa)
    }
    
    func getFirstTimeTrashScreenGaPreference() -> Bool
    {
        return preferences.bool(forKey: firstTimeTrashScreenGa)
    }
    
    func setFirstTimeTrashScreenGaPreference()
    {
        preferences.set(true, forKey : firstTimeTrashScreenGa)
    }
    
    func getFirstTimeDeletionScreenGaPreference() -> Bool
    {
        return preferences.bool(forKey: firstTimeDeletionScreenGa)
    }
    
    func setFirstTimeDeletionScreenGaPreference()
    {
        preferences.set(true, forKey : firstTimeDeletionScreenGa)
    }
    
    func setfistTimePreference()
    {
        preferences.set(true, forKey : firstTimeKey)
    }
    
    func setFirstTimeInsertionPreference()
    {
        preferences.set(true, forKey : firstTimeInsertion)
    }
    
    func getFirstTimePreference() -> Bool
    {
        return preferences.bool(forKey: firstTimeKey)
    }
    
    func getFirstTimeInsertionPreference() -> Bool
    {
        let returnVal = preferences.bool(forKey: firstTimeInsertion)
        return returnVal
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
