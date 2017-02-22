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

    override func viewDidLoad() {
        super.viewDidLoad()
        let error: NSErrorPointer = nil
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error?.pointee = error1
            print("Error fetching: \(error)")
        }
        title = "Shopping List"
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44.0, 0)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coffees = _coffees
        teas = _teas
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return TableSection.numberOfSections.rawValue
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == TableSection.coffee.rawValue {
            return "Coffee"
        } else {
            return "Teas"
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        switch section {
            case TableSection.coffee.rawValue: return coffees!.count
            case TableSection.tea.rawValue: return teas!.count
            default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShopListCell", for: indexPath)
        if let timerModel: TimerModel = timerModelForIndexPath(indexPath) {
            cell.textLabel?.text = timerModel.name
            if timerModel.selected {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryType.none
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let headerView: UITableViewHeaderFooterView = (view as? UITableViewHeaderFooterView)!
        headerView.contentView.backgroundColor = UIColor(red: 0.8, green: 0.95, blue: 1, alpha: 0.5)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShopListCell", for: indexPath) 
        let timerModel = timerModelForIndexPath(indexPath)
        timerModel!.selected = !timerModel!.selected
        appDelegate().saveCoreData()
        
        if timerModel!.selected {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
    }
}

extension ListTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    {
        switch type {
        case .insert:
            return
//            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .delete:
            return
//            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .move:
            return
//            tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        }
    }
}

