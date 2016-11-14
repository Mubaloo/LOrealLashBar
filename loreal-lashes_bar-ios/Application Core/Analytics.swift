//
//  Analytics.swift
//  NYXPaletteBuilder
//
//  Created by Jonathan Gwilliams on 15/03/2016.
//  Copyright © 2016 Macoscope. All rights reserved.
//

import Foundation
import Google

struct Analytics {
    
    static var trackingID: String = "UA-62360847-3"
    static let context = GGLContext.sharedInstance()
    static let tracker = GAI.sharedInstance().tracker(withTrackingId: trackingID)
    
    enum Screen: String {
        case BuildIt = "Build It"
        case FeaturedPalettes = "Featured Palettes"
    }
    
    enum TimingName: String {
        case SessionDuration = "Session Duration"
    }
    
    enum Action: String {
        case ProductDetail = "Lashes Product Detail"
        case TechniqueDetails = "Lashes Technique details"
        case EmailConversions = "Lashes Email Conversion"
        case VideoPlays = "Lashes Video Plays"
        case AddToPlaylist = "Add to Lashes playlist"
    }
    
//    enum Label: String {
//        case Technique = "Technique"
//        case Brushes = "Brushes"
//    }
    
    enum Category: String {
        case Technique = "Lashes Technique"
        case Lashes = "Lashes"
        case Email = "Lashes Email"
        case VideoPlayback = "Lashes Video playback Started"
    }
    
    enum Value: Int {
        case BrushBar = 0
    }
    
    static func initialise() {
        var configureError:NSError?
        Analytics.context?.configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
    }
    
    static func dispatch() {
        GAI.sharedInstance().dispatch()
    }
    
    static func trackTime(time: TimeInterval, category: Category, name: TimingName? = nil, label: String? = nil) {
        let parameters = GAIDictionaryBuilder.createTiming(
            withCategory: category.rawValue,
            interval: (time * 1000) as TimeInterval as NSNumber!,
            name: name?.rawValue,
            label: label
        ).build() as [NSObject : AnyObject]
        
        tracker?.send(parameters)
    }
    
    static func trackScreen(screen: Screen) {
        tracker?.set(kGAIScreenName, value: screen.rawValue)
        let data = GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject]
        tracker?.send(data)
        
    }
    
    // Use this for tracking catrgory:lushec or brushes 
    // action from enum like email send or product displayed
    // parameter = value?
    
    static func sendEvent(category: Category, action: Action, label: String, value: Int = 0) {
        let eventParams = GAIDictionaryBuilder.createEvent(
            withCategory: category.rawValue,
            action: action.rawValue,
            label: label,
            value: value as NSNumber!
        ).build() as [NSObject : AnyObject]
        print("***eventParams \(eventParams.debugDescription)")
        
        tracker?.send(eventParams)
    }
    
}

