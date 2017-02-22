//
//  AppDelegate.swift
//  Coffee Timer
//
//  Created by Nanci Frank on 8/6/15.
//  Copyright (c) 2015 Wildcat Productions. All rights reserved.
//

import UIKit
import CoreData

func appDelegate() -> AppDelegate {
    return UIApplication.sharedApplication().delegate as! AppDelegate            
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    lazy var coreDataStack: CoreDataStack = {
        return CoreDataStack(
            modelName: "CoffeeTimer",
            storeName: "CoffeeTimer",
            options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
    }()
    
    func saveCoreData() {
        let error = NSErrorPointer()
        do {
            try coreDataStack.managedObjectContext.save()
        } catch let error1 as NSError {
            error.memory = error1
            print("Error saving context: \(error)")
        }
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        coreDataStack.loadDefaultDataIfFirstLaunch()
        window?.tintColor = UIColor(red:0.95, green:0.53, blue:0.27, alpha:1)
        return true
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        let alertController = UIAlertController(title: notification.alertTitle, message: notification.alertBody, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(okAction)
        window!.rootViewController!.presentViewController(alertController, animated: true, completion: nil)
    }

    func applicationWillResignActive(application: UIApplication) {
        self.saveCoreData()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        print("Application has entered background.")
    }

    func applicationWillEnterForeground(application: UIApplication) {
        print("Application has entered foreground.")
    }

    func applicationDidBecomeActive(application: UIApplication) {
        print("Application has become active.")
    }

    func applicationWillTerminate(application: UIApplication) {
        print("Application will terminate.")
    }


}

