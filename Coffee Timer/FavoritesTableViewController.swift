//
//  FavoritesTableViewController.swift
//  Coffee Timer
//
//  Created by Nanci Frank on 9/19/15.
//  Copyright (c) 2015 Wildcat Productions. All rights reserved.
//

import UIKit
import CoreData

class FavoritesTableViewController: UITableViewController
{
    
    var cellIdentifier = "FavoriteCell"
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TimerModel")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "type", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)
        ]
        fetchRequest.predicate = NSPredicate(format: "favorite == true")
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate().coreDataStack.managedObjectContext, sectionNameKeyPath: "type", cacheName: nil)
        controller.delegate = self
        
        return controller
    }()
    
    lazy var noFavoritesLabel: UILabel? = {
        let noFavoritesView = UILabel(frame: CGRect.zero)
        let noFavoritesMessage: String = "You do not have any favorites selected."
        noFavoritesView.text = noFavoritesMessage
        noFavoritesView.font = UIFont.boldSystemFont(ofSize: 15.0)
        noFavoritesView.textColor = UIColor.lightText
        noFavoritesView.textAlignment = NSTextAlignment.center
        
        return noFavoritesView
    }()

    enum TableSection: Int
    {
        case coffee = 0
        case tea
        case numberOfSections
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "My Favorites"
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44.0, 0)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        fetchedResultsController.delegate = self
        let error: NSErrorPointer = nil
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error?.pointee = error1
            print("Error fetching: \(error)")
        }
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        let numberOfSections = (fetchedResultsController.sections ?? []).count
        if numberOfSections == 0 {
            let alert = UIAlertController(title: "Alert", message: "You don't have any favorites listed.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: { () -> Void in
                let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    alert.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        fetchedResultsController.delegate = nil
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        let numberOfSections = (fetchedResultsController.sections ?? []).count
        self.tableView.backgroundView = nil
        
        return numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if section == TableSection.coffee.rawValue {
            return "Coffee"
        } else {
            return "Teas"
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let sectionInfo: NSFetchedResultsSectionInfo = (fetchedResultsController.sections?[section])!
        
        return sectionInfo.numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) 
        let timerModel = timerModelForIndexPath(indexPath)
        cell.textLabel?.text = timerModel.name
        if let brand = timerModel.brand as BrandModel? {
            cell.detailTextLabel?.text = brand.name
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let headerView: UITableViewHeaderFooterView = (view as? UITableViewHeaderFooterView)!
        headerView.contentView.backgroundColor = UIColor(red: 0.8, green: 0.95, blue: 1, alpha: 0.5)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 44.0
    }
    
    func timerModelForIndexPath(_ indexPath: IndexPath) -> TimerModel
    {
        return fetchedResultsController.object(at: indexPath) as! TimerModel
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

extension FavoritesTableViewController: NSFetchedResultsControllerDelegate
{
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        tableView.endUpdates()
    }
}
