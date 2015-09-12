//
//  CoreDataStack.swift
//  Coffee Timer
//
//  Created by Nanci Frank on 8/24/15.
//  Copyright (c) 2015 Wildcat Productions. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack: Printable {
    
    var modelName : String
    var storeName : String
    var options: [NSObject: AnyObject]?
    var storeURL: NSURL?
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let moc = NSManagedObjectContext()
        moc.persistentStoreCoordinator = self.persistentStoreCoordinator
        return moc
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource(self.modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        self.storeURL = self.applicationDocumentsDirectory().URLByAppendingPathComponent("\(self.storeName).sqlite")
        
        let errorPointer = NSErrorPointer()
        if coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: self.storeURL, options: nil, error: errorPointer) == nil {
            println("Unresolved error adding persistent store: \(errorPointer.memory)")
        }
        
        return coordinator
    }()
    
    var description : String
    {
            return "context: \(managedObjectContext)\n" +
                "modelName: \(modelName)\n" +
                "model: \(managedObjectModel.entityVersionHashesByName)\n" +
                "coordinator: \(persistentStoreCoordinator)\n" +
                "storeURL: \(storeURL)\n"
    }

    init(modelName:String, storeName:String, options: [NSObject: AnyObject]? = nil) {
        self.modelName = modelName
        self.storeName = storeName
        self.options = options
    }
    
    func loadDefaultDataIfFirstLaunch() {
        let key = "hasLaunchedBefore"
        let launchedBefore = NSUserDefaults.standardUserDefaults().boolForKey(key)
        
        if launchedBefore == false {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: key)
            
            for i in 0..<5 {
                let model = NSEntityDescription.insertNewObjectForEntityForName("TimerModel", inManagedObjectContext: managedObjectContext) as! TimerModel
                
                switch i {
                case 0:
                    model.name = NSLocalizedString("Colombian", comment: "Columbian coffee name")
                    model.duration = 240
                    model.type = .Coffee
                case 1:
                    model.name = NSLocalizedString("Mexican", comment: "Mexian coffee name")
                    model.duration = 200
                    model.type = .Coffee
                case 2:
                    model.name = NSLocalizedString("Green Tea", comment: "Green tea name")
                    model.duration = 400
                    model.type = .Tea
                case 3:
                    model.name = NSLocalizedString("Oolong", comment: "Oolong tea name")
                    model.duration = 400
                    model.type = .Tea
                default: // case 4:
                    model.name = NSLocalizedString("Rooibos", comment: "Rooibos tea name")
                    model.duration = 480
                    model.type = .Tea
                }
                
                model.displayOrder = Int32(i)
            }
            let error = NSErrorPointer()
            if !managedObjectContext.save(error) {
                println("Error saving context: \(error)")
            }

        }
    }
    
    private func applicationDocumentsDirectory() -> NSURL {
        return NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first as! NSURL
    }

}
