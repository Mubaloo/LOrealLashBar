//
//  AppDelegate.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 16/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit
import CoreData
import HockeySDK

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var navigator: UINavigationController!
    private var transitions = SelfDrivenTransition()
    
    private static let HockeyAppID = "06c9bf1f7d044616861bc3e8b17c95ab"

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Prepare Hockey for crash reporting
        BITHockeyManager.sharedHockeyManager().configureWithIdentifier(AppDelegate.HockeyAppID)
        BITHockeyManager.sharedHockeyManager().startManager()
        BITHockeyManager.sharedHockeyManager().authenticator.authenticateInstallation()
        
        // The app delegate is responsible for forwarding transition animations to the transitions object.
        // To this end, it delegates for various navigation and tab bar controllers to determine when new
        // parent view controllers appear and thus need animation support. It is also used to determine
        // when attract mode is on show in order to activate and deactivate the timeout.
        window?.backgroundColor = UIColor.lightBG
        navigator = window?.rootViewController as? UINavigationController
        navigator.delegate = self
        
        // App timeout support
        let noteCenter = NSNotificationCenter.defaultCenter()
        noteCenter.addObserver(self, selector: #selector(AppDelegate.appDidTimeOut),
                               name: TimeOutApplication.ApplicationDidTimeOutNotification,
                               object: nil)
        
        return true
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        NSNotificationCenter.defaultCenter().postNotificationName("applicationDidBecomeActive", object: nil)
    }
    
    func appDidTimeOut() {
        // When the app times out we purge the playlist and pop to the attract mode view controller.
        CoreDataStack.shared.purgePlaylist()
        navigator.topViewController?.dismissViewControllerAnimated(true, completion: nil)
        navigator.popToRootViewControllerAnimated(true)
    }

    func applicationWillTerminate(application: UIApplication) {
        CoreDataStack.shared.saveContext()
    }

}

extension AppDelegate: UINavigationControllerDelegate {
    
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        guard let app = UIApplication.sharedApplication() as? TimeOutApplication else { return }
        if viewController is AttractModeViewController {
            app.cancelTimeout()
        } else {
            app.beginTimeout()
        }
    }
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transitions
    }
    
}

extension AppDelegate: UITabBarControllerDelegate {
    
    func tabBarController(tabBarController: UITabBarController, animationControllerForTransitionFromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transitions
    }
    
}

extension AppDelegate: UIViewControllerTransitioningDelegate {
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transitions
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transitions
    }
    
}