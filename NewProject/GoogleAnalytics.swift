//
//  GoogleAnalytics.swift
//  NewProject
//
//  Created by Shashank Tiwari on 15/09/17.
//  Copyright © 2017 Shashank Tiwari. All rights reserved.
//

import Foundation

class GoogleAnalytics
{
    
    static let shared:GoogleAnalytics=GoogleAnalytics()
    var gai:GAI!
    var tracker:GAITracker!
    //var builder:GAIDictionaryBuilder!
    
    private init()
    {
        guard let gai = GAI.sharedInstance() else {
            assert(false, "Google Analytics not configured correctly")
            return
        }
        
        self.gai = gai
        gai.tracker(withTrackingId: "UA-106507340-1")
        // Optional: automatically report uncaught exceptions.
        gai.trackUncaughtExceptions = true
        
        // Optional: set Logger to VERBOSE for debug information.
        // Remove before app release.
        gai.logger.logLevel = .verbose;
        
        guard let tracker = gai.defaultTracker else { return }
        self.tracker=tracker
        
    }
    
    
    func sendScreenTracking(screenName : String)
    {
        guard let builder = GAIDictionaryBuilder.createScreenView() else {
            print("Unable to create ScreenView Builder")
            return }
        tracker.set(kGAIScreenName, value: screenName)
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        print("ProjectGoogleAnalyticsScreenTracking : ",screenName)
    }
    
    
    func sendEvent(category : String, action : String, label : String)
    {
        guard let builder = GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: nil) else {
            print("Unable to create Event Builder")
            return }
   
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        print("ProjectGoogleAnalyticsEventTracking -> Category : \(category) Action : \(action)  Label : \(label) ")
    }
    
    func sendEvent(category : String, action : String, label : String, value : NSNumber)
    {
        guard let builder = GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: value) else {
            print("Unable to create Event Builder")
            return }
        
        tracker.send(builder.build() as [NSObject : AnyObject])
        
         print("ProjectGoogleAnalyticsEventTracking -> Category : \(category)  Action : \(action)  Label : \(label)  value : \(value) ")
    }
    
    
    func signInGoogleAnalytics(custDimKey : Int, custDimVal : String) {
        
        tracker?.send(GAIDictionaryBuilder.createScreenView().set(custDimVal, forKey: GAIFields.customDimension(for : UInt(custDimKey))).build() as NSDictionary as [NSObject : AnyObject])
    }
    
    
}
