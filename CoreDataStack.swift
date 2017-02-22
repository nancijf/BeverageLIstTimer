//
//  CoreDataStack.swift
//  Coffee Timer
//
//  Created by Nanci Frank on 8/24/15.
//  Copyright (c) 2015 Wildcat Productions. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack: CustomStringConvertible {
    
    var modelName : String
    var storeName : String
    var options: [NSObject: AnyObject]?
    var storeURL: NSURL?
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
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
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType,
                        configuration: nil,
                        URL: self.storeURL,
                        options: nil)
        } catch var error as NSError {
            errorPointer.memory = error
            print("Unresolved error adding persistent store: \(errorPointer.memory)")
        } catch {
            fatalError()
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

    func loadBrandsFromTextFile(name: String) -> [String] {
        let filePath = NSBundle.mainBundle().pathForResource(name, ofType: "txt")
        let fileContents = try? String(contentsOfFile: filePath!, encoding: NSUTF8StringEncoding)
        let lines : [String] = fileContents!.componentsSeparatedByString("\n")
        
        return lines
    }
    
    func loadBrandDataIfNeeded() {
        let request = NSFetchRequest(entityName: "BrandModel")
        let results = try? managedObjectContext.executeFetchRequest(request)
        let brandCount = results?.count
        if brandCount == 0 {
            let coffeeBrands = loadBrandsFromTextFile("coffeeBrands")
            for brand: String in coffeeBrands {
                let model = NSEntityDescription.insertNewObjectForEntityForName("BrandModel", inManagedObjectContext: appDelegate().coreDataStack.managedObjectContext) as! BrandModel
                model.name = brand
            }
            appDelegate().saveCoreData()
        }
    }
    
    func loadDefaultDataIfFirstLaunch() {
        let key = "hasLaunchedBefore"
        let launchedBefore = NSUserDefaults.standardUserDefaults().boolForKey(key)
        
        loadBrandDataIfNeeded()
        
        if launchedBefore == false {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: key)
            let request = NSFetchRequest(entityName: "BrandModel")
            let results: NSArray = try! managedObjectContext.executeFetchRequest(request)
            
            for i in 0..<6 {
                let model = NSEntityDescription.insertNewObjectForEntityForName("TimerModel", inManagedObjectContext: managedObjectContext) as! TimerModel
                
                switch i {
                case 0:
                    model.name = NSLocalizedString("French Roast", comment: "French Roast coffee name")
                    model.duration = 240
                    model.type = .Coffee
                    let brand = (results.filteredArrayUsingPredicate(NSPredicate(format: "name == 'Starbucks'")) as! [BrandModel]).first
                    model.brand = brand!
                case 1:
                    model.name = NSLocalizedString("Mexican", comment: "Mexian coffee name")
                    model.duration = 200
                    model.type = .Coffee
                    let brand = (results.filteredArrayUsingPredicate(NSPredicate(format: "name == 'Capresso'")) as! [BrandModel]).first
                    model.brand = brand!
                case 2:
                    model.name = NSLocalizedString("Green Tea", comment: "Green tea name")
                    model.duration = 400
                    model.type = .Tea
                    let brand = (results.filteredArrayUsingPredicate(NSPredicate(format: "name == 'Bigelow'")) as! [BrandModel]).first
                    model.brand = brand!
                case 3:
                    model.name = NSLocalizedString("Oolong", comment: "Oolong tea name")
                    model.duration = 400
                    model.type = .Tea
                    let brand = (results.filteredArrayUsingPredicate(NSPredicate(format: "name == 'Teavana'")) as! [BrandModel]).first
                    model.brand = brand!
                case 4:
                    model.name = NSLocalizedString("Veranda", comment: "Veranda coffee name")
                    model.duration = 400
                    model.type = .Coffee
                    let brand = (results.filteredArrayUsingPredicate(NSPredicate(format: "name == 'Starbucks'")) as! [BrandModel]).first
                    model.brand = brand!
                default: // case 4:
                    model.name = NSLocalizedString("Rooibos", comment: "Rooibos tea name")
                    model.duration = 480
                    model.type = .Tea
                    let brand = (results.filteredArrayUsingPredicate(NSPredicate(format: "name == 'Jacobs'")) as! [BrandModel]).first
                    model.brand = brand!
                }
                
                model.displayOrder = Int32(i)
            }
            appDelegate().saveCoreData()
        }
    }
    
    private func applicationDocumentsDirectory() -> NSURL {
        return NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first!
    }

}
