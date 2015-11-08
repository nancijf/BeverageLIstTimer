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

@objc protocol BrandsTableViewControllerDelegate
{
    func brandsTableViewControllerDidFinishSelectingBrand(viewController: BrandsTableViewController, brand: BrandModel)
}

class BrandsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate
{
    
    weak var delegate: BrandsTableViewControllerDelegate?
    var brandSelected: BrandModel?
    var selectedIndex: NSIndexPath = NSIndexPath(forItem: 0, inSection: 0)
    var savedBackButton: UIBarButtonItem?
    var searchButton: UIBarButtonItem?
    var searchActive: Bool = false
    var filtered:[String] = []
    var brandCompletion: ((brand: BrandModel) -> ())?
    
    lazy var searchBar:UISearchBar =
    {
        let searchBarWidth = self.view.frame.width * 0.5
        let searchBar = UISearchBar(frame: CGRectMake(0, 0, searchBarWidth, 20))
        return searchBar
    }()
    
    lazy var addBrandButton: UIBarButtonItem = {
        let addBrandButton = UIBarButtonItem(title: "Add Brand to List", style: UIBarButtonItemStyle.Plain, target: self, action: "addNewBrand:")
        addBrandButton.enabled = false
        
        return addBrandButton
    }()
    
    let cellIdentifier = "brandCell"
    
    @IBAction func showSearchView(sender: UIBarButtonItem)
    {
        self.savedBackButton = self.navigationItem.leftBarButtonItem
        self.searchButton = self.navigationItem.rightBarButtonItem
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "hideSearchView:"), animated: true)
        searchBar.placeholder = "Brand Name"
        searchActive = true
        
        print("width = \(self.view.bounds.size)")
        let viewWidth = self.view.frame.width
        let navBar = UINavigationBar(frame: CGRectMake(0, 0, viewWidth, 44))
        navBar.backgroundColor = UIColor.grayColor();
        navBar.alpha = 0.9;
        let navItem = UINavigationItem()
        navItem.rightBarButtonItem = addBrandButton
        
        navBar.pushNavigationItem(navItem, animated: false)
        
        searchBar.inputAccessoryView = navBar
        searchBar.becomeFirstResponder()
    }
    
    func hideSearchView(sender: UIBarButtonItem) {
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
    
    func addNewBrand(sender: UIBarButtonItem) {
        let brand = NSEntityDescription.insertNewObjectForEntityForName("BrandModel", inManagedObjectContext: appDelegate().coreDataStack.managedObjectContext) as! BrandModel
        brand.name = searchBar.text!
        appDelegate().saveCoreData()
        self.brandSelected = brand
        searchBar.text = ""
        searchBar.resignFirstResponder()
        hideSearchView(sender)
        tableView.reloadData()
        selectedIndex = findSelectedIndexForBrand(self.brandSelected)!
        tableView.scrollToRowAtIndexPath(selectedIndex, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        brandsViewControllerDidFinishSelectingBrand(brand)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func findSelectedIndexForBrand(brandSelected: BrandModel?) -> NSIndexPath? {
        var selectedIndex: NSIndexPath?
        let request = NSFetchRequest(entityName: "BrandModel")
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true, selector: "caseInsensitiveCompare:")
        ]
        let results: NSArray = try! appDelegate().coreDataStack.managedObjectContext.executeFetchRequest(request)
        
        if brandSelected != nil {
            selectedIndex = NSIndexPath(forItem: results.indexOfObject(brandSelected!), inSection: 0)
        }
        
        return selectedIndex
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
        
        self.title = "Brands"
        let error = NSErrorPointer()
        searchBar.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error.memory = error1
            print("Error fetching: \(error)")
        }

        if self.brandSelected != nil {
            selectedIndex = findSelectedIndexForBrand(self.brandSelected)!
        }
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
        brandCompletion!(brand: brand)
    }

    /// MARK: - Search Bar Delegate 
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar)
    {
        print("in searchBarDidBeginEditing")
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar)
    {
        print("in searchBarDidEndEditing: \(searchBar.text)")
        searchActive = false
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar)
    {
        print("in searchBarCancelButtonClicked")
        searchActive = false
        searchBar.text = ""
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        print("in searchBarSearchButtonClicked")
        searchActive = false
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
        print("in searchBar function")
        let sectionInfo: NSFetchedResultsSectionInfo = (fetchedResultsController.sections?[0])!
        if sectionInfo.numberOfObjects == 0 {
            addBrandButton.enabled = true
        }
        else {
            addBrandButton.enabled = false
        }
        tableView.reloadData()
    }

}

