//
//  FavoritesTableViewController.swift
//  Coffee Timer
//
//  Created by Nanci Frank on 9/19/15.
//  Copyright (c) 2015 Wildcat Productions. All rights reserved.
//

import UIKit
import CoreData

class FavoritesTableViewController: UITableViewController {
    
    var cellIdentifier = "FavoriteCell"
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "TimerModel")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "type", ascending: true),
            NSSortDescriptor(key: "displayOrder", ascending: true)
        ]
        fetchRequest.predicate = NSPredicate(format: "favorite == true")
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate().coreDataStack.managedObjectContext, sectionNameKeyPath: "type", cacheName: nil)
        controller.delegate = self
        
        return controller
    }()
    
    lazy var noFavoritesLabel: UILabel? = {
        let noFavoritesView = UILabel(frame: CGRectZero)
        let noFavoritesMessage: String = "You do not have any favorites selected."
        noFavoritesView.text = noFavoritesMessage
        noFavoritesView.font = UIFont.boldSystemFontOfSize(15.0)
        noFavoritesView.textColor = UIColor.lightTextColor()
        noFavoritesView.textAlignment = NSTextAlignment.Center
        
        return noFavoritesView
    }()

    enum TableSection: Int {
        case Coffee = 0
        case Tea
        case NumberOfSections
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Favorites"
        self.tableView.contentInset = UIEdgeInsetsMake(44.0, 0, 44.0, 0)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let error = NSErrorPointer()
        if !fetchedResultsController.performFetch(error) {
            println("Error fetching: \(error)")
        }
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let numberOfSections = count(fetchedResultsController.sections ?? [])
        if numberOfSections == 0 {
            noFavoritesLabel!.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)
            
            self.tableView.backgroundView = noFavoritesLabel!
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        }
        else {
            self.tableView.backgroundView = nil
        }
        
        return numberOfSections
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == TableSection.Coffee.rawValue {
            return "Coffee"
        } else {
            return "Teas"
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections?[section] as? NSFetchedResultsSectionInfo
        
        return sectionInfo?.numberOfObjects ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        let timerModel = timerModelForIndexPath(indexPath)
        cell.textLabel?.text = timerModel.name
        if let brand = timerModel.brand as BrandModel? {
            cell.detailTextLabel?.text = brand.name
        }
        
        return cell
    }
    
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        if tableView.editing {
//            let cell = tableView.cellForRowAtIndexPath(indexPath)
//        }
//    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView: UITableViewHeaderFooterView = (view as? UITableViewHeaderFooterView)!
        headerView.contentView.backgroundColor = UIColor(red: 0.8, green: 0.95, blue: 1, alpha: 0.5)
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    func timerModelForIndexPath(indexPath: NSIndexPath) -> TimerModel {
        return fetchedResultsController.objectAtIndexPath(indexPath) as! TimerModel
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
}

extension FavoritesTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
}