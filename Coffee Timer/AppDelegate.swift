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
    return UIApplication.shared.delegate as! AppDelegate            
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    lazy var coreDataStack: CoreDataStack = {
        return CoreDataStack(
            modelName: "CoffeeTimer",
            storeName: "CoffeeTimer",
            options: [NSMigratePersistentStoresAutomaticallyOption as NSObject: true as AnyObject, NSInferMappingModelAutomaticallyOption as NSObject: true as AnyObject])
    }()
    
    func saveCoreData() {
        let error: NSErrorPointer = nil
        do {
            try coreDataStack.managedObjectContext.save()
        } catch let error1 as NSError {
            error?.pointee = error1
            print("Error saving context: \(error)")
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        coreDataStack.loadDefaultDataIfFirstLaunch()
        window?.tintColor = UIColor(red:0.95, green:0.53, blue:0.27, alpha:1)
        return true
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        let alertController = UIAlertController(title: notification.alertTitle, message: notification.alertBody, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        window!.rootViewController!.present(alertController, animated: true, completion: nil)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        self.saveCoreData()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("Application has entered background.")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("Application has entered foreground.")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("Application has become active.")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("Application will terminate.")
    }


}

