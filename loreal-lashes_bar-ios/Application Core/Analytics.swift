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
    
    
    enum Action: String {
        case ProductDetail = "Lashes Product Detail"
        case TechniqueDetails = "Lashes Technique details"
        case EmailConversions = "Lashes Email Conversion"
        case VideoPlays = "Lashes Video Plays"
        case AddToPlaylist = "Add to Lashes playlist"
    }
    
    
    enum Category: String {
        case Technique = "Lashes Technique"
        case Lashes = "Lashes"
        case Email = "Lashes Email"
        case VideoPlayback = "Lashes Video playback Started"
    }
    
    static func initialise() {
        var configureError:NSError?
        Analytics.context?.configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
    }
    
    static func dispatch() {
        GAI.sharedInstance().dispatch()
    }
    
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

