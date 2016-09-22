//
//  TimeOutApplication.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 16/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

/**
 This class manages a timer used to determine when a certain amount of time has passed without
 the user interacting with the application in general. Any user interaction is picked up in the
 sendEvent() function, causing the timer to be reset.
 */
class TimeOutApplication: UIApplication {
    
    static let ApplicationDidTimeOutNotification = "ApplicationDidTimeOutNotification"
    static let timeout: NSTimeInterval = 60 // Timeout measured in seconds of inactivity
    
    private var timer: NSTimer?
    private var pauseCount = 0
    
    var timeoutIsActive: Bool { get { return timer != nil } }
    
    /**
     Initialises the timeout session, if one is not already in progress.
     */
    func beginTimeout() {
        if timer != nil { return }
        pauseCount = 0
        refreshTimer()
    }
    
    /**
     Cancels timeout, if necessary, and resets the number of pause requests to zero.
    */
    func cancelTimeout() {
        guard let timer = timer else { return }
        timer.invalidate()
        pauseCount = 0
        self.timer = nil
    }
    
    /**
     Requests that the capacity to time out be paused temporarily. This is reference counted,
     so if multiple objects all request a pause they must all indicate that they are ready
     before the timeout is reinstated. Must be paired with a call to `resumeTimeout()`
     */
    func pauseTimeout() {
        if pauseCount == 0 { cancelTimeout() }
        pauseCount += 1
    }
    
    /**
     Indicates that an object requesting a pause in the timeout is now ready for that timeout
     to continue. Must be paired with a prior call to `pauseTimeout()`.
     */
    func resumeTimeout() {
        pauseCount -= 1
        if pauseCount == 0 { beginTimeout() }
    }
    
    // Invalidates and restarts the timer.
    private func refreshTimer() {
        if let timer = timer { timer.invalidate() }
        self.timer = NSTimer.scheduledTimerWithTimeInterval(
            TimeOutApplication.timeout,
            target: self,
            selector: #selector(TimeOutApplication.appDidTimeOut),
            userInfo: nil,
            repeats: false
        )
    }
    
    // Overriding this function allows us to reset the timer for every interaction the user
    // makes, regardless of where in the app this occurs.
    override func sendEvent(event: UIEvent) {
        super.sendEvent(event)
        if timeoutIsActive == false { return }
        if event.allTouches()?.filter({ $0.phase == .Began }).count == 0 { return }
        refreshTimer()
    }
    
    // Send a notification upon timeout.
    internal func appDidTimeOut() {
        timer = nil
        NSNotificationCenter.defaultCenter().postNotificationName(
            TimeOutApplication.ApplicationDidTimeOutNotification,
            object: self
        )
    }
    
}