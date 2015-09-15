//
//  BrandsTableViewController.swift
//  Coffee Timer
//
//  Created by Nanci Frank on 9/13/15.
//  Copyright (c) 2015 Wildcat Productions. All rights reserved.
//

import UIKit
import Foundation
import CoreData

protocol BrandsTableViewControllerDelegate {
    func brandsTableViewControllerDidFinishSelectingBrand(viewController: BrandsTableViewController, brand: BrandModel)
}

class BrandsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var delegate:BrandsTableViewControllerDelegate! = nil
    var brandSelected: BrandModel?
    var selectedIndex: NSIndexPath = NSIndexPath(forItem: 0, inSection: 0)
    
    let cellIdentifier = "brandCell"
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "BrandModel")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true, selector: "caseInsensitiveCompare:")
         ]
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate().coreDataStack.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        let error = NSErrorPointer()
        if !fetchedResultsController.performFetch(error) {
            println("Error fetching: \(error)")
        }
        self.title = "Brands"
        let request = NSFetchRequest(entityName: "BrandModel")
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true, selector: "caseInsensitiveCompare:")
        ]
        let results: NSArray = appDelegate().coreDataStack.managedObjectContext.executeFetchRequest(request, error: nil)!
        if brandSelected != nil {
            selectedIndex = NSIndexPath(forItem: results.indexOfObject(brandSelected!), inSection: 0)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if presentedViewController != nil {
            tableView.reloadData()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        tableView.scrollToRowAtIndexPath(selectedIndex, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections?[section] as? NSFetchedResultsSectionInfo
        return sectionInfo?.numberOfObjects ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        let brandModel = brandModelForIndexPath(indexPath)
        cell.textLabel?.text = brandModel.name
        if brandSelected != nil {
            if brandModel == brandSelected {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let brand: BrandModel = brandModelForIndexPath(indexPath)
        brandsViewControllerDidFinishSelectingBrand(brand)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func brandModelForIndexPath(indexPath: NSIndexPath) -> BrandModel {
        return fetchedResultsController.objectAtIndexPath(indexPath) as! BrandModel
    }
    
    func brandsViewControllerDidFinishSelectingBrand(brand: BrandModel) {
        self.delegate!.brandsTableViewControllerDidFinishSelectingBrand(self, brand: brand)
    }

}

