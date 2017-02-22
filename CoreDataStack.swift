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
    var options: [AnyHashable: Any]?
    var storeURL: URL?
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.persistentStoreCoordinator = self.persistentStoreCoordinator
        return moc
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        self.storeURL = self.applicationDocumentsDirectory().appendingPathComponent("\(self.storeName).sqlite")
        
        let errorPointer: NSErrorPointer = nil
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                        configurationName: nil,
                        at: self.storeURL,
                        options: nil)
        } catch var error as NSError {
            errorPointer?.pointee = error
            print("Unresolved error adding persistent store: \(errorPointer?.pointee)")
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

    init(modelName:String, storeName:String, options: [AnyHashable: Any]? = nil) {
        self.modelName = modelName
        self.storeName = storeName
        self.options = options
    }

    func loadBrandsFromTextFile(_ name: String) -> [String] {
        let filePath = Bundle.main.path(forResource: name, ofType: "txt")
        let fileContents = try? String(contentsOfFile: filePath!, encoding: String.Encoding.utf8)
        let lines : [String] = fileContents!.components(separatedBy: "\n")
        
        return lines
    }
    
    func loadBrandDataIfNeeded() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "BrandModel")
        let results = try? managedObjectContext.fetch(request)
        let brandCount = results?.count
        if brandCount == 0 {
            let coffeeBrands = loadBrandsFromTextFile("coffeeBrands")
            for brand: String in coffeeBrands {
                let model = NSEntityDescription.insertNewObject(forEntityName: "BrandModel", into: appDelegate().coreDataStack.managedObjectContext) as! BrandModel
                model.name = brand
            }
            appDelegate().saveCoreData()
        }
    }
    
    func loadDefaultDataIfFirstLaunch() {
        let key = "hasLaunchedBefore"
        let launchedBefore = UserDefaults.standard.bool(forKey: key)
        
        loadBrandDataIfNeeded()
        
        if launchedBefore == false {
            UserDefaults.standard.set(true, forKey: key)
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "BrandModel")
            let results: NSArray = try! managedObjectContext.fetch(request) as NSArray
            
            for i in 0..<6 {
                let model = NSEntityDescription.insertNewObject(forEntityName: "TimerModel", into: managedObjectContext) as! TimerModel
                
                switch i {
                case 0:
                    model.name = NSLocalizedString("French Roast", comment: "French Roast coffee name")
                    model.duration = 240
                    model.type = .coffee
                    let brand = (results.filtered(using: NSPredicate(format: "name == 'Starbucks'")) as! [BrandModel]).first
                    model.brand = brand!
                case 1:
                    model.name = NSLocalizedString("Mexican", comment: "Mexian coffee name")
                    model.duration = 200
                    model.type = .coffee
                    let brand = (results.filtered(using: NSPredicate(format: "name == 'Capresso'")) as! [BrandModel]).first
                    model.brand = brand!
                case 2:
                    model.name = NSLocalizedString("Green Tea", comment: "Green tea name")
                    model.duration = 400
                    model.type = .tea
                    let brand = (results.filtered(using: NSPredicate(format: "name == 'Bigelow'")) as! [BrandModel]).first
                    model.brand = brand!
                case 3:
                    model.name = NSLocalizedString("Oolong", comment: "Oolong tea name")
                    model.duration = 400
                    model.type = .tea
                    let brand = (results.filtered(using: NSPredicate(format: "name == 'Teavana'")) as! [BrandModel]).first
                    model.brand = brand!
                case 4:
                    model.name = NSLocalizedString("Veranda", comment: "Veranda coffee name")
                    model.duration = 400
                    model.type = .coffee
                    let brand = (results.filtered(using: NSPredicate(format: "name == 'Starbucks'")) as! [BrandModel]).first
                    model.brand = brand!
                default: // case 4:
                    model.name = NSLocalizedString("Rooibos", comment: "Rooibos tea name")
                    model.duration = 480
                    model.type = .tea
                    let brand = (results.filtered(using: NSPredicate(format: "name == 'Jacobs'")) as! [BrandModel]).first
                    model.brand = brand!
                }
                
                model.displayOrder = Int32(i)
            }
            appDelegate().saveCoreData()
        }
    }
    
    fileprivate func applicationDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first!
    }

}
