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
    func brandsTableViewControllerDidFinishSelectingBrand(_ viewController: BrandsTableViewController, brand: BrandModel)
}

class BrandsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate
{
    
    weak var delegate: BrandsTableViewControllerDelegate?
    var brandSelected: BrandModel?
    var selectedIndex: IndexPath = IndexPath(item: 0, section: 0)
    var savedBackButton: UIBarButtonItem?
    var searchButton: UIBarButtonItem?
    var searchActive: Bool = false
    var filtered:[String] = []
    var brandCompletion: ((_ brand: BrandModel) -> ())?
    
    lazy var searchBar:UISearchBar =
    {
        let searchBarWidth = self.view.frame.width * 0.5
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: searchBarWidth, height: 20))
        return searchBar
    }()
    
    lazy var addBrandButton: UIBarButtonItem = {
        let addBrandButton = UIBarButtonItem(title: "Add Brand to List", style: UIBarButtonItemStyle.plain, target: self, action: #selector(BrandsTableViewController.addNewBrand(_:)))
        addBrandButton.isEnabled = false
        
        return addBrandButton
    }()
    
    let cellIdentifier = "brandCell"
    
    @IBAction func showSearchView(_ sender: UIBarButtonItem)
    {
        self.savedBackButton = self.navigationItem.leftBarButtonItem
        self.searchButton = self.navigationItem.rightBarButtonItem
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(BrandsTableViewController.hideSearchView(_:))), animated: true)
        searchBar.placeholder = "Brand Name"
        searchActive = true
        
        let viewWidth = self.view.frame.width
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: viewWidth, height: 44))
        navBar.backgroundColor = UIColor.gray;
        navBar.alpha = 0.9;
        let navItem = UINavigationItem()
        navItem.rightBarButtonItem = addBrandButton
        
        navBar.pushItem(navItem, animated: false)
        
        searchBar.inputAccessoryView = navBar
        searchBar.becomeFirstResponder()
    }
    
    func hideSearchView(_ sender: UIBarButtonItem) {
        self.navigationItem.leftBarButtonItem = self.savedBackButton
        self.navigationItem.rightBarButtonItem = self.searchButton
        self.fetchedResultsController.fetchRequest.predicate = nil
        searchActive = false
        let error: NSErrorPointer = nil
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error?.pointee = error1
            print("Error fetching: \(error)")
        }
        tableView.reloadData()
    }
    
    func addNewBrand(_ sender: UIBarButtonItem) {
        let brand = NSEntityDescription.insertNewObject(forEntityName: "BrandModel", into: appDelegate().coreDataStack.managedObjectContext) as! BrandModel
        brand.name = searchBar.text!
        appDelegate().saveCoreData()
        self.brandSelected = brand
        searchBar.text = ""
        searchBar.resignFirstResponder()
        hideSearchView(sender)
        tableView.reloadData()
        selectedIndex = findSelectedIndexForBrand(self.brandSelected)!
        tableView.scrollToRow(at: selectedIndex, at: UITableViewScrollPosition.top, animated: true)
        brandsViewControllerDidFinishSelectingBrand(brand)
        self.navigationController?.popViewController(animated: true)
    }
    
    func findSelectedIndexForBrand(_ brandSelected: BrandModel?) -> IndexPath? {
        var selectedIndex: IndexPath?
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "BrandModel")
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        ]
        let results: NSArray = try! appDelegate().coreDataStack.managedObjectContext.fetch(request) as NSArray
        
        if brandSelected != nil {
            selectedIndex = IndexPath(item: results.index(of: brandSelected!), section: 0)
        }
        
        return selectedIndex
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BrandModel")
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
        let error: NSErrorPointer = nil
        searchBar.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error?.pointee = error1
            print("Error fetching: \(error)")
        }

        if self.brandSelected != nil {
            selectedIndex = findSelectedIndexForBrand(self.brandSelected)!
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        if presentedViewController != nil {
            tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        tableView.scrollToRow(at: selectedIndex, at: UITableViewScrollPosition.top, animated: true)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let sectionInfo: NSFetchedResultsSectionInfo = (fetchedResultsController.sections?[section])!
        return sectionInfo.numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) 
        let brandModel = brandModelForIndexPath(indexPath)
        cell.textLabel?.text = brandModel.name
        if brandSelected != nil && !searchActive {
            if brandModel == brandSelected {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryType.none
            }
        }
        else if searchActive {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let brand: BrandModel = brandModelForIndexPath(indexPath)
        brandsViewControllerDidFinishSelectingBrand(brand)
        self.navigationController?.popViewController(animated: true)
    }
    
    func brandModelForIndexPath(_ indexPath: IndexPath) -> BrandModel
    {
        return fetchedResultsController.object(at: indexPath) as! BrandModel
    }
    
    func brandsViewControllerDidFinishSelectingBrand(_ brand: BrandModel)
    {
        brandCompletion!(brand)
    }

    /// MARK: - Search Bar Delegate 
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
//        print("in searchBarDidBeginEditing")
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar)
    {
//        print("in searchBarDidEndEditing: \(searchBar.text)")
        searchActive = false
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
//        print("in searchBarCancelButtonClicked")
        searchActive = false
        searchBar.text = ""
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
//        print("in searchBarSearchButtonClicked")
        searchActive = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "name BEGINSWITH[cd] %@", searchText)
        let error: NSErrorPointer = nil
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error?.pointee = error1
            print("Error fetching: \(error)")
        }
//      print("in searchBar function")
        let sectionInfo: NSFetchedResultsSectionInfo = (fetchedResultsController.sections?[0])!
        if sectionInfo.numberOfObjects == 0 {
            addBrandButton.isEnabled = true
        }
        else {
            addBrandButton.isEnabled = false
        }
        tableView.reloadData()
    }

}

