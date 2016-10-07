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

extension UserDefaults {
    
    /** The access token to be used in transactions with the back end */
    static var accessToken: String? {
        get { return standard.string(forKey: kAccessToken) }
        set { standard.set(newValue, forKey: kAccessToken) }
    }
    
    /** Records whether videos are currently muted or not. This value is shared by all videos. */
    static var videoMuted: Bool {
        get { return standard.bool(forKey: kVideoMuted) }
        set { standard.set(newValue, forKey: kVideoMuted) }
    }
    
}
