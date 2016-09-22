//
//  NSUserDefaults+Custom.swift
//  NYXPaletteBuilder
//
//  Created by Jonathan Gwilliams on 05/09/2016.
//  Copyright © 2016 Mubaloo. All rights reserved.
//

import Foundation

private let kAccessToken = "ACCESS_TOKEN"
private let kVideoMuted = "VIDEO_MUTED"

extension NSUserDefaults {
    
    /** The access token to be used in transactions with the back end */
    static var accessToken: String? {
        get { return standardUserDefaults().stringForKey(kAccessToken) }
        set { standardUserDefaults().setObject(newValue, forKey: kAccessToken) }
    }
    
    /** Records whether videos are currently muted or not. This value is shared by all videos. */
    static var videoMuted: Bool {
        get { return standardUserDefaults().boolForKey(kVideoMuted) }
        set { standardUserDefaults().setBool(newValue, forKey: kVideoMuted) }
    }
    
}
