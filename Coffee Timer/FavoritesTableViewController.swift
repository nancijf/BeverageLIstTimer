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
            NSSortDescriptor(key: "favorite", ascending: true)
        ]
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate().coreDataStack.managedObjectContext, sectionNameKeyPath: "type", cacheName: nil)
//        controller.delegate = self
        return controller
        }()

    override func viewDidLoad() {
        super.viewDidLoad()
        let error = NSErrorPointer()
        if !fetchedResultsController.performFetch(error) {
            println("Error fetching: \(error)")
        }
        title = "My Favorites"
//        navigationItem.leftBarButtonItem = editButtonItem()
        self.tableView.contentInset = UIEdgeInsetsMake(44.0, 0, 44.0, 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return count(fetchedResultsController.sections ?? [])
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections?[section] as? NSFetchedResultsSectionInfo
        return sectionInfo?.numberOfObjects ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        let timerModel = timerModelForIndexPath(indexPath)
        cell.textLabel?.text = timerModel.name
        return cell
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
