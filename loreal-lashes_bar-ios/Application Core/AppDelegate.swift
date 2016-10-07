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
    fileprivate var navigator: UINavigationController!
    fileprivate var transitions = SelfDrivenTransition()
    
    fileprivate static let HockeyAppID = "06c9bf1f7d044616861bc3e8b17c95ab"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Prepare Hockey for crash reporting
        BITHockeyManager.shared().configure(withIdentifier: AppDelegate.HockeyAppID)
        BITHockeyManager.shared().start()
        BITHockeyManager.shared().authenticator.authenticateInstallation()
        
        // The app delegate is responsible for forwarding transition animations to the transitions object.
        // To this end, it delegates for various navigation and tab bar controllers to determine when new
        // parent view controllers appear and thus need animation support. It is also used to determine
        // when attract mode is on show in order to activate and deactivate the timeout.
        window?.backgroundColor = UIColor.lightBG
        navigator = window?.rootViewController as? UINavigationController
        navigator.delegate = self
        
        // App timeout support
        let noteCenter = NotificationCenter.default
        noteCenter.addObserver(self, selector: #selector(AppDelegate.appDidTimeOut),
                               name: NSNotification.Name(rawValue: TimeOutApplication.ApplicationDidTimeOutNotification),
                               object: nil)
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "applicationDidBecomeActive"), object: nil)
    }
    
    func appDidTimeOut() {
        // When the app times out we purge the playlist and pop to the attract mode view controller.
        CoreDataStack.shared.purgePlaylist()
        navigator.topViewController?.dismiss(animated: true, completion: nil)
        navigator.popToRootViewController(animated: true)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataStack.shared.saveContext()
    }

}

extension AppDelegate: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let app = UIApplication.shared as? TimeOutApplication else { return }
        if viewController is AttractModeViewController {
            app.cancelTimeout()
        } else {
            app.beginTimeout()
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transitions
    }
    
}

extension AppDelegate: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transitions
    }
    
}

extension AppDelegate: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transitions
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transitions
    }
    
}
