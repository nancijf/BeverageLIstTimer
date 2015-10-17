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

@objc protocol BrandsTableViewControllerDelegate {
    func brandsTableViewControllerDidFinishSelectingBrand(viewController: BrandsTableViewController, brand: BrandModel)
}

class BrandsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate {
    
    weak var delegate: BrandsTableViewControllerDelegate?
    var brandSelected: BrandModel?
    var selectedIndex: NSIndexPath = NSIndexPath(forItem: 0, inSection: 0)
    var savedBackButton: UIBarButtonItem?
    var searchButton: UIBarButtonItem?
    var searchActive: Bool = false
    var filtered:[String] = []
    var brandCompletion: ((brand: BrandModel) -> ())?
    
    lazy var searchBar:UISearchBar = {
        let searchBar = UISearchBar(frame: CGRectMake(0, 0, 200, 20))
        return searchBar
    }()
    
    let cellIdentifier = "brandCell"
    
    @IBAction func showSearchView(sender: UIBarButtonItem)
    {
        self.savedBackButton = self.navigationItem.leftBarButtonItem
        self.searchButton = self.navigationItem.rightBarButtonItem
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "hideSearchView:"), animated: true)
        searchBar.placeholder = "Brand Name"
        searchBar.becomeFirstResponder()
        searchActive = true
    }
    
    func hideSearchView(sender: UIBarButtonItem)
    {
        self.navigationItem.leftBarButtonItem = self.savedBackButton
        self.navigationItem.rightBarButtonItem = self.searchButton
        self.fetchedResultsController.fetchRequest.predicate = nil
        searchActive = false
        let error = NSErrorPointer()
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error.memory = error1
            print("Error fetching: \(error)")
        }
        tableView.reloadData()
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "BrandModel")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true, selector: "caseInsensitiveCompare:")
         ]
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate().coreDataStack.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }()
    
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
        self.title = "Brands"
        let request = NSFetchRequest(entityName: "BrandModel")
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true, selector: "caseInsensitiveCompare:")
        ]
        let results: NSArray = try! appDelegate().coreDataStack.managedObjectContext.executeFetchRequest(request)
        if brandSelected != nil {
            selectedIndex = NSIndexPath(forItem: results.indexOfObject(brandSelected!), inSection: 0)
        }
        searchBar.delegate = self
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        if presentedViewController != nil {
            tableView.reloadData()
        }
    }
    
    override func viewDidAppear(animated: Bool)
    {
        tableView.scrollToRowAtIndexPath(selectedIndex, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let sectionInfo: NSFetchedResultsSectionInfo = (fetchedResultsController.sections?[section])!
        return sectionInfo.numberOfObjects ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) 
        let brandModel = brandModelForIndexPath(indexPath)
        cell.textLabel?.text = brandModel.name
        if brandSelected != nil && !searchActive {
            if brandModel == brandSelected {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
        }
        else if searchActive {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let brand: BrandModel = brandModelForIndexPath(indexPath)
        brandsViewControllerDidFinishSelectingBrand(brand)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func brandModelForIndexPath(indexPath: NSIndexPath) -> BrandModel
    {
        return fetchedResultsController.objectAtIndexPath(indexPath) as! BrandModel
    }
    
    func brandsViewControllerDidFinishSelectingBrand(brand: BrandModel)
    {
//        delegate?.brandsTableViewControllerDidFinishSelectingBrand(self, brand: brand)
        brandCompletion!(brand: brand)
    }

    /// MARK: - Search Bar Delegate 
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
    {
        fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "name BEGINSWITH[cd] %@", searchText)
        let error = NSErrorPointer()
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error.memory = error1
            print("Error fetching: \(error)")
        }
        let sectionInfo: NSFetchedResultsSectionInfo = (fetchedResultsController.sections?[0])!
        tableView.reloadData()
//        print("search results is \(sectionInfo.numberOfObjects)")
    }

}

