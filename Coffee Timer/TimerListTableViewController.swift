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
        mutating func moveFrom(_ source: Int, toDestination destination: Int) {
            let object = remove(at: source)
            insert(object, at: destination)
        }
}

class TimerListTableViewController: UITableViewController {
    
    var userReorderingCells = false
    let cellIdentifier = "Cell"
    var creatingNewTimer = false
    
    var _coffees: [TimerModel] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TimerModel")
        request.predicate = NSPredicate(format: "type == %d", TableSection.coffee.rawValue)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))]
        let coffees: [TimerModel] = try! appDelegate().coreDataStack.managedObjectContext.fetch(request) as! [TimerModel]
        
        return coffees
    }
    
    var _teas: [TimerModel] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TimerModel")
        request.predicate = NSPredicate(format: "type == %d", TableSection.tea.rawValue)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))]
        let teas: [TimerModel] = try! appDelegate().coreDataStack.managedObjectContext.fetch(request) as! [TimerModel]
        
        return teas
    }
    
    var coffees: [TimerModel]?
    var teas: [TimerModel]?
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TimerModel")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "type", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)
        ]
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate().coreDataStack.managedObjectContext, sectionNameKeyPath: "type", cacheName: nil)
        controller.delegate = self
        return controller
    }()
    
    enum TableSection: Int {
        case coffee = 0
        case tea
        case numberOfSections
    }
    
    func timerModelForIndexPath(_ indexPath: IndexPath) -> TimerModel? {
        var timerModel: TimerModel?
        
        switch indexPath.section {
            case TableSection.coffee.rawValue:
                if self.coffees!.count > 0 {
                    timerModel = coffees![indexPath.row]
                }
            case TableSection.tea.rawValue:
                if self.teas!.count > 0 {
                    timerModel = teas![indexPath.row]
                }
            default: return timerModel
        }
        
        return timerModel
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let cell = sender as? UITableViewCell {
            let indexPath = tableView.indexPath(for: cell)!
            let timerModel = timerModelForIndexPath(indexPath)
            
            if segue.identifier == "pushDetail" {
                let detailViewController = segue.destination as! TimerDetailViewController
                
                detailViewController.timerModel = timerModel
            }
            else if segue.identifier == "editDetail" {
                print("editDetail prepareForSegue")
                let navigationController = segue.destination as! UINavigationController
                let editViewController = navigationController.topViewController as! TimerEditViewController
                
                editViewController.timerModel = timerModel
                editViewController.delegate = self
            }
        }
        else if segue.identifier == "newTimer" {
            let navigationController = segue.destination as! UINavigationController
            let editViewController = navigationController.topViewController as! TimerEditViewController
            
            editViewController.creatingNewTimer = true
            creatingNewTimer = true
            editViewController.timerModel = NSEntityDescription.insertNewObject(forEntityName: "TimerModel", into: appDelegate().coreDataStack.managedObjectContext) as! TimerModel
            editViewController.delegate = self
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool
    {
        print("editDetail shouldPerformSegueWithIdentifier")
        if identifier == "pushDetail" {
            if tableView.isEditing {
                return false
            }
        }
        return true
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        let error: NSErrorPointer = nil
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error?.pointee = error1
            print("Error fetching: \(error)")
        }
        title = "Drinks"
        navigationItem.leftBarButtonItem = editButtonItem
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44.0, 0)
        
        coffees = _coffees
        teas = _teas
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        tableView.reloadData()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool)
    {
        super.setEditing(editing, animated: animated)
        navigationItem.rightBarButtonItem?.isEnabled = !editing
        self.shouldDisableBarButtonItems(!editing)
    }
    
    func shouldDisableBarButtonItems(_ enabled: Bool) {
        for item in self.tabBarController!.tabBar.items! {
            item.isEnabled = enabled
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        // Return the number of sections we're displaying
        return TableSection.numberOfSections.rawValue
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch section {
            case TableSection.coffee.rawValue: return coffees!.count
            case TableSection.tea.rawValue: return teas!.count
            default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("in didSelectRowAtIndexPath")
        if tableView.isEditing {
            let cell = tableView.cellForRow(at: indexPath)
            performSegue(withIdentifier: "editDetail", sender: cell)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if let timerModel: TimerModel = timerModelForIndexPath(indexPath) {
            cell.textLabel?.text = timerModel.name
            if let brand = timerModel.brand as BrandModel? {
                cell.detailTextLabel?.text = brand.name
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView: UITableViewHeaderFooterView = (view as? UITableViewHeaderFooterView)!
        headerView.contentView.backgroundColor = UIColor(red: 0.8, green: 0.95, blue: 1, alpha: 0.5)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
            case TableSection.coffee.rawValue: return coffees!.count > 0 ? 44 : 0
            case TableSection.tea.rawValue: return teas!.count > 0 ? 44 : 0
            default: return 0
        }
//        if section < fetchedResultsController.sections?.count {
//            let sectionInfo: NSFetchedResultsSectionInfo = (fetchedResultsController.sections?[section])!
//            return sectionInfo.numberOfObjects > 0 ? 44 : 0
//        }
//        return 0
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let timer = timerModelForIndexPath(indexPath) {
                removeItemFromDataSource(indexPath)
                timer.managedObjectContext?.delete(timer)
                appDelegate().saveCoreData()
            }
        }
    }
    
    func removeItemFromDataSource(_ atIndexPath: IndexPath) {
        switch atIndexPath.section {
            case TableSection.coffee.rawValue:
                if coffees!.count > 0 {
                    coffees!.remove(at: atIndexPath.row)
                }
            case TableSection.tea.rawValue:
                if teas!.count > 0 {
                    teas!.remove(at: atIndexPath.row)
                }
            default: return
        }
    }
        
    override func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.copy(_:)) {
            return true
        }
        
        return false
    }

    override func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        if let timerModel = timerModelForIndexPath(indexPath) {
            let pasteboard = UIPasteboard.general
            pasteboard.string = timerModel.name
        }
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        // If the source and destination index paths are the same section,
        // then return the proposed index path
        if sourceIndexPath.section == proposedDestinationIndexPath.section {
            return proposedDestinationIndexPath
        }
        
        // The sections are different, which we want to disallow.
        if sourceIndexPath.section == TableSection.coffee.rawValue {
            // This is coming from the coffee section, so return
            // the last index path in that section.
            
            let sectionInfo: NSFetchedResultsSectionInfo = (fetchedResultsController.sections?[TableSection.coffee.rawValue])!
            
            let numberOfCoffeeTimers = sectionInfo.numberOfObjects ?? 0
            
            return IndexPath(item: numberOfCoffeeTimers - 1, section: 0)
        } else { // Must be TableSection.Tea
            // This is coming from the tea section, so return
            // the first index path in that section.
            
            return IndexPath(item: 0, section: 1)
        }
    }
    
//    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath)
//    {
//        userReorderingCells = true
//        
//        // Grab the section and the TimerModels in the section
//        let sectionInfo: NSFetchedResultsSectionInfo = (fetchedResultsController.sections?[sourceIndexPath.section])!
//        
//        var objectsInSection = sectionInfo.objects ?? []
//        
//        // Rearrange the order to match the user's actions
//        // Note: this doesn't move anything in Core Data, just our objectsInSection array
//        objectsInSection.moveFrom(sourceIndexPath.row, toDestination: destinationIndexPath.row)
//        
//        // The models are now in the correct order.
//        // Update their displayOrder to match the new order.
//        for i in 0..<objectsInSection.count {
//            let model = objectsInSection[i] as? TimerModel
//            model?.displayOrder = Int32(i)
//        }
//        
//        userReorderingCells = false
//        do {
//            try appDelegate().coreDataStack.managedObjectContext.save()
//        } catch _ {
//        }
//    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if section == TableSection.coffee.rawValue {
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
    
//    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?)
//    {
//        if userReorderingCells {
//            return
//        }
//        
//        switch type {
//        case .Insert:
//            return
//            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
//        case .Delete:
//            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
//        case .Move:
//            return
//            tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
//        case .Update:
//            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
//        }
//
//        tableView.reloadData()
//    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        if userReorderingCells {
            return
        }

        switch type {
        case .delete:
            if !creatingNewTimer {
//                switch indexPath!.section {
//                case TableSection.Coffee.rawValue:
//                    coffees?.removeAtIndex(indexPath!.row)
//                case TableSection.Tea.rawValue:
//                    teas?.removeAtIndex(indexPath!.row)
//                default:
//                    return
//                }
                tableView.deleteRows(at: [indexPath!], with: .automatic)
                tableView.reloadData()
            }
        default:
            return
        }
    }
}

extension TimerListTableViewController: TimerEditViewControllerDelegate {
    func timerEditViewControllerDidCancel(_ viewController: TimerEditViewController)
    {
        coffees = _coffees
        teas = _teas
        tableView.reloadData()
        creatingNewTimer = false
    }
    
    func timerEditViewControllerDidSave(_ viewController: TimerEditViewController) {
        appDelegate().saveCoreData()
        coffees = _coffees
        teas = _teas
        tableView.reloadData()
        creatingNewTimer = false
    }
}
