//
//  TimerListTableViewController.swift
//  Coffee Timer
//
//  Created by Nanci Frank on 8/15/15.
//  Copyright (c) 2015 Wildcat Productions. All rights reserved.
//

import UIKit
import CoreData

extension Array {
        mutating func moveFrom(source: Int, toDestination destination: Int) {
            let object = removeAtIndex(source)
            insert(object, atIndex: destination)
        }
}

class TimerListTableViewController: UITableViewController {
    
    var userReorderingCells = false
    let cellIdentifier = "Cell"
    
    var _coffees: [TimerModel] {
        let request = NSFetchRequest(entityName: "TimerModel")
        request.predicate = NSPredicate(format: "type == %d", TableSection.Coffee.rawValue)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: "caseInsensitiveCompare:")]
        let coffees: [TimerModel] = try! appDelegate().coreDataStack.managedObjectContext.executeFetchRequest(request) as! [TimerModel]
        
        return coffees
    }
    
    var _teas: [TimerModel] {
        let request = NSFetchRequest(entityName: "TimerModel")
        request.predicate = NSPredicate(format: "type == %d", TableSection.Tea.rawValue)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: "caseInsensitiveCompare:")]
        let teas: [TimerModel] = try! appDelegate().coreDataStack.managedObjectContext.executeFetchRequest(request) as! [TimerModel]
        
        return teas
    }
    
    var coffees: [TimerModel]?
    var teas: [TimerModel]?
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "TimerModel")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "type", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)
        ]
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate().coreDataStack.managedObjectContext, sectionNameKeyPath: "type", cacheName: nil)
        controller.delegate = self
        return controller
    }()
    
    enum TableSection: Int {
        case Coffee = 0
        case Tea
        case NumberOfSections
    }
    
    func timerModelForIndexPath(indexPath: NSIndexPath) -> TimerModel? {
        var timerModel: TimerModel?
        
        switch indexPath.section {
            case TableSection.Coffee.rawValue:
                if self.coffees!.count > 0 {
                    timerModel = coffees![indexPath.row]
                }
            case TableSection.Tea.rawValue:
                if self.teas!.count > 0 {
                    timerModel = teas![indexPath.row]
                }
            default: return timerModel
        }
        
        return timerModel
//        if indexPath.section >= fetchedResultsController.sections?.count {
//            let sectionInfo: NSFetchedResultsSectionInfo = (fetchedResultsController.sections?[0])!
//            if Int(sectionInfo.name) == TableSection.Tea.rawValue {
//                return fetchedResultsController.objectAtIndexPath(NSIndexPath(forItem: 0, inSection: 0)) as! TimerModel
//            }
//        }
//        
//        return fetchedResultsController.objectAtIndexPath(indexPath) as! TimerModel
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let cell = sender as? UITableViewCell {
            let indexPath = tableView.indexPathForCell(cell)!
            let timerModel = timerModelForIndexPath(indexPath)
            
            if segue.identifier == "pushDetail" {
                let detailViewController = segue.destinationViewController as! TimerDetailViewController
                detailViewController.timerModel = timerModel
            } else if segue.identifier == "editDetail" {
                let navigationController = segue.destinationViewController as! UINavigationController
                let editViewController = navigationController.topViewController as! TimerEditViewController
                
                editViewController.timerModel = timerModel
                editViewController.delegate = self
            }
        } else if segue.identifier == "newTimer" {
                let navigationController = segue.destinationViewController as! UINavigationController
                let editViewController = navigationController.topViewController as! TimerEditViewController
                
                editViewController.creatingNewTimer = true
                editViewController.timerModel = NSEntityDescription.insertNewObjectForEntityForName("TimerModel", inManagedObjectContext: appDelegate().coreDataStack.managedObjectContext) as! TimerModel
                editViewController.delegate = self
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool
    {
        if identifier == "pushDetail" {
            if tableView.editing {
                return false
            }
        }
        return true
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        let error = NSErrorPointer()
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error.memory = error1
            print("Error fetching: \(error)")
        }
        title = "Drinks"
        navigationItem.leftBarButtonItem = editButtonItem()
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44.0, 0)
        
        coffees = _coffees
        teas = _teas
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        if presentedViewController != nil {
            tableView.reloadData()
        }
    }
    
    override func setEditing(editing: Bool, animated: Bool)
    {
        super.setEditing(editing, animated: animated)
        navigationItem.rightBarButtonItem?.enabled = !editing
        self.shouldDisableBarButtonItems(!editing)
    }
    
    func shouldDisableBarButtonItems(enabled: Bool) {
        for item in self.tabBarController!.tabBar.items! {
            item.enabled = enabled
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        // Return the number of sections we're displaying
        return TableSection.NumberOfSections.rawValue
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch section {
            case TableSection.Coffee.rawValue: return coffees!.count
            case TableSection.Tea.rawValue: return teas!.count
            default: return 0
        }
//        var numberOfObjects = 0
//        
//        if fetchedResultsController.sections?.count == 0 {
//            return 0
//        }
//        
//        if section >= fetchedResultsController.sections?.count {
//            guard let sectionInfo: NSFetchedResultsSectionInfo = (fetchedResultsController.sections?[0])! else {
//                numberOfObjects = 0
//            }
//            if sectionInfo.name == "1" {
//                numberOfObjects = sectionInfo.numberOfObjects
//            }
//        }
//        else if section == TableSection.Coffee.rawValue {
//            guard let sectionInfo: NSFetchedResultsSectionInfo = (fetchedResultsController.sections?[section])! else {
//                return 0
//            }
//            if sectionInfo.name == "0" {
//                numberOfObjects = sectionInfo.numberOfObjects
//            } else {
//                numberOfObjects = 0
//            }
//        }
//        else if section == TableSection.Tea.rawValue {
//            guard let sectionInfo: NSFetchedResultsSectionInfo = (fetchedResultsController.sections?[section])! else {
//                return 0
//            }
//            numberOfObjects = sectionInfo.numberOfObjects
//        }
//        
//        print("section: \(section), numberOfObjects: \(numberOfObjects)")
//        return numberOfObjects
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.editing {
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            performSegueWithIdentifier("editDetail", sender: cell)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        if let timerModel: TimerModel = timerModelForIndexPath(indexPath) {
            cell.textLabel?.text = timerModel.name
            if let brand = timerModel.brand as BrandModel? {
                cell.detailTextLabel?.text = brand.name
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView: UITableViewHeaderFooterView = (view as? UITableViewHeaderFooterView)!
        headerView.contentView.backgroundColor = UIColor(red: 0.8, green: 0.95, blue: 1, alpha: 0.5)
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
            case TableSection.Coffee.rawValue: return coffees!.count > 0 ? 44 : 0
            case TableSection.Tea.rawValue: return teas!.count > 0 ? 44 : 0
            default: return 0
        }
//        if section < fetchedResultsController.sections?.count {
//            let sectionInfo: NSFetchedResultsSectionInfo = (fetchedResultsController.sections?[section])!
//            return sectionInfo.numberOfObjects > 0 ? 44 : 0
//        }
//        return 0
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if let timer = timerModelForIndexPath(indexPath) {
                removeItemFromDataSource(indexPath)
                timer.managedObjectContext?.deleteObject(timer)
                appDelegate().saveCoreData()
            }
        }
    }
    
    func removeItemFromDataSource(atIndexPath: NSIndexPath) {
        switch atIndexPath.section {
            case TableSection.Coffee.rawValue:
                if coffees!.count > 0 {
                    coffees!.removeAtIndex(atIndexPath.row)
                }
            case TableSection.Tea.rawValue:
                if teas!.count > 0 {
                    teas!.removeAtIndex(atIndexPath.row)
                }
            default: return
        }
    }
        
    override func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        if action == "copy:" {
            return true
        }
        
        return false
    }

    override func tableView(tableView: UITableView, performAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
        if let timerModel = timerModelForIndexPath(indexPath) {
            let pasteboard = UIPasteboard.generalPasteboard()
            pasteboard.string = timerModel.name
        }
    }
    
    override func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
       // If the source and destination index paths are the same section,
        // then return the proposed index path
        if sourceIndexPath.section == proposedDestinationIndexPath.section {
            return proposedDestinationIndexPath
        }
        
        // The sections are different, which we want to disallow.
        if sourceIndexPath.section == TableSection.Coffee.rawValue {
            // This is coming from the coffee section, so return
            // the last index path in that section.
            
            let sectionInfo: NSFetchedResultsSectionInfo = (fetchedResultsController.sections?[TableSection.Coffee.rawValue])!
            
            let numberOfCoffeeTimers = sectionInfo.numberOfObjects ?? 0
            
            return NSIndexPath(forItem: numberOfCoffeeTimers - 1, inSection: 0)
        } else { // Must be TableSection.Tea
            // This is coming from the tea section, so return
            // the first index path in that section.
            
            return NSIndexPath(forItem: 0, inSection: 1)
        }
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath)
    {
        userReorderingCells = true
        
        // Grab the section and the TimerModels in the section
        let sectionInfo: NSFetchedResultsSectionInfo = (fetchedResultsController.sections?[sourceIndexPath.section])!
        
        var objectsInSection = sectionInfo.objects ?? []
        
        // Rearrange the order to match the user's actions
        // Note: this doesn't move anything in Core Data, just our objectsInSection array
        objectsInSection.moveFrom(sourceIndexPath.row, toDestination: destinationIndexPath.row)
        
        // The models are now in the correct order.
        // Update their displayOrder to match the new order.
        for i in 0..<objectsInSection.count {
            let model = objectsInSection[i] as? TimerModel
            model?.displayOrder = Int32(i)
        }
        
        userReorderingCells = false
        do {
            try appDelegate().coreDataStack.managedObjectContext.save()
        } catch _ {
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if section == TableSection.Coffee.rawValue {
            return "Coffee"
        } else {
            return "Teas"
        }
    }
}

extension TimerListTableViewController: NSFetchedResultsControllerDelegate {
//    func controllerWillChangeContent(controller: NSFetchedResultsController) {
//        tableView.beginUpdates()
//    }
//    
//    func controllerDidChangeContent(controller: NSFetchedResultsController) {
//        tableView.endUpdates()
//    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?)
    {
        if userReorderingCells {
            return
        }
        
        switch type {
        case .Insert:
            return
//            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Move:
            return
//            tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        }

        tableView.reloadData()
    }
}

extension TimerListTableViewController: TimerEditViewControllerDelegate {
    func timerEditViewControllerDidCancel(viewController: TimerEditViewController)
    {
        if viewController.creatingNewTimer {
            appDelegate().coreDataStack.managedObjectContext.deleteObject(viewController.timerModel)
            coffees = _coffees
            teas = _teas
            tableView.reloadData()
        }
    }
    
    func timerEditViewControllerDidSave(viewController: TimerEditViewController) {
        appDelegate().saveCoreData()
        coffees = _coffees
        teas = _teas
        tableView.reloadData()
    }
}