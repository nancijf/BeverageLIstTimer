//
//  AppDelegate.swift
//  Coffee Timer
//
//  Created by Nanci Frank on 8/6/15.
//  Copyright (c) 2015 Wildcat Productions. All rights reserved.
//

import UIKit

func appDelegate() -> AppDelegate {
    return UIApplication.sharedApplication().delegate as! AppDelegate
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    lazy var coreDataStack: CoreDataStack = {
        return CoreDataStack()
    }()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        println("Application has launched.")
        coreDataStack.loadDefaultDataIfFirstLaunch()
        window?.tintColor = UIColor(red:0.95, green:0.53, blue:0.27, alpha:1)
        return true
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        println("Application received local notification.")
        let alertController = UIAlertController(title: notification.alertTitle, message: notification.alertBody, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(okAction)
        window!.rootViewController!.presentViewController(alertController, animated: true, completion: nil)
    }

    func applicationWillResignActive(application: UIApplication) {
        println("Application has resigned active.")
        let error = NSErrorPointer()
        if !coreDataStack.managedObjectContext.save(error) {
            println("Error saving context: \(error)")
        }
    }

    func applicationDidEnterBackground(application: UIApplication) {
        println("Application has entered background.")
    }

    func applicationWillEnterForeground(application: UIApplication) {
        println("Application has entered foreground.")
    }

    func applicationDidBecomeActive(application: UIApplication) {
        println("Application has become active.")
    }

    func applicationWillTerminate(application: UIApplication) {
        println("Application will terminate.")
    }


}

