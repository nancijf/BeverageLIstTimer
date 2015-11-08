//
//  ListTableViewController.swift
//  Coffee Timer
//
//  Created by Nanci Frank on 9/11/15.
//  Copyright (c) 2015 Wildcat Productions. All rights reserved.
//

import UIKit
import CoreData

class ListTableViewController: UITableViewController {
    
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
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("in viewDidLoad")
        let error = NSErrorPointer()
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error.memory = error1
            print("Error fetching: \(error)")
        }
        title = "Shopping List"
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44.0, 0)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("in viewWillAppear")
        coffees = _coffees
        teas = _teas
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return TableSection.NumberOfSections.rawValue
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == TableSection.Coffee.rawValue {
            return "Coffee"
        } else {
            return "Teas"
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        switch section {
            case TableSection.Coffee.rawValue: return coffees!.count
            case TableSection.Tea.rawValue: return teas!.count
            default: return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("ShopListCell", forIndexPath: indexPath)
        if let timerModel: TimerModel = timerModelForIndexPath(indexPath) {
            cell.textLabel?.text = timerModel.name
            if timerModel.selected {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let headerView: UITableViewHeaderFooterView = (view as? UITableViewHeaderFooterView)!
        headerView.contentView.backgroundColor = UIColor(red: 0.8, green: 0.95, blue: 1, alpha: 0.5)
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("ShopListCell", forIndexPath: indexPath) 
        let timerModel = timerModelForIndexPath(indexPath)
        timerModel!.selected = !timerModel!.selected
        appDelegate().saveCoreData()
        
        if timerModel!.selected {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
    }
}

extension ListTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?)
    {
        switch type {
        case .Insert:
            return
//            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            return
//            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Move:
            return
//            tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        }
    }
}

