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
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "TimerModel")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "type", ascending: true),
            NSSortDescriptor(key: "favorite", ascending: true)
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

    func timerModelForIndexPath(indexPath: NSIndexPath) -> TimerModel {
        return fetchedResultsController.objectAtIndexPath(indexPath) as! TimerModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let error = NSErrorPointer()
        if !fetchedResultsController.performFetch(error) {
            println("Error fetching: \(error)")
        }
        title = "Shopping List"
//        navigationItem.leftBarButtonItem = editButtonItem()
        self.tableView.contentInset = UIEdgeInsetsMake(44.0, 0, 44.0, 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return count(fetchedResultsController.sections ?? [])
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
        let sectionInfo = fetchedResultsController.sections?[section] as? NSFetchedResultsSectionInfo
        return sectionInfo?.numberOfObjects ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ShopListCell", forIndexPath: indexPath) as! UITableViewCell
        let timerModel = timerModelForIndexPath(indexPath)
        cell.textLabel?.text = timerModel.name
//        if let brand = timerModel.brand as BrandModel? {
//            cell.detailTextLabel?.text = brand.name
//        }
        if timerModel.selected {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("ShopListCell", forIndexPath: indexPath) as! UITableViewCell
        let timerModel = timerModelForIndexPath(indexPath)
        timerModel.selected = !timerModel.selected
        appDelegate().saveCoreData()
        
        if timerModel.selected {
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
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
                
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Move:
            tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        }
    }
}

