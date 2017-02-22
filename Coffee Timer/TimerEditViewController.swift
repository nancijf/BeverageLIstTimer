//
//  TimerEditViewController.swift
//  Coffee Timer
//
//  Created by Nanci Frank on 8/9/15.
//  Copyright (c) 2015 Wildcat Productions. All rights reserved.
//

import UIKit
import Foundation

@objc protocol TimerEditViewControllerDelegate {
    func timerEditViewControllerDidCancel(_ viewController: TimerEditViewController)
    func timerEditViewControllerDidSave(_ viewController: TimerEditViewController)
}

class TimerEditViewController: UIViewController, UITextFieldDelegate {
    
    var creatingNewTimer = false
    var coffeeTimers: [TimerModel]!
    var teaTimers: [TimerModel]!
    var timerModel: TimerModel!
    weak var delegate: TimerEditViewControllerDelegate?

    @IBOutlet weak var timerTypeSegmentedControl: UISegmentedControl!
    
    @IBAction func cancelWasPressed(_ sender: UIBarButtonItem) {
        timerModel.managedObjectContext?.rollback()
        delegate?.timerEditViewControllerDidCancel(self)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneWasPressed(_ sender: UIBarButtonItem) {
        timerModel.favorite = favoriteButton.isSelected
        timerModel.name = nameField.text
        timerModel.duration = Int32(Int(minutesSlider.value) * 60 + Int(secondsSlider.value))
        if timerTypeSegmentedControl.selectedSegmentIndex == 0 {
            timerModel.type = .coffee
        }
        else { // Must be 1
            timerModel.type = .tea
        }
        delegate?.timerEditViewControllerDidSave(self)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let numberOfMinutes = Int(minutesSlider.value)
        let numberOfSeconds = Int(secondsSlider.value)
        updateLabelsWithMinutes(numberOfMinutes, seconds: numberOfSeconds)
    }
    
    @IBAction func tapFavoriteButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var brandField: UITextField!
    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var minutesSlider: UISlider!
    @IBOutlet weak var secondsLabel: UILabel!
    @IBOutlet weak var secondsSlider: UISlider!
    
    func updateLabelsWithMinutes(_ minutes: Int, seconds: Int) {
        func pluralize(_ value: Int, singular: String, plural: String) -> String {
            switch value {
            case 1: return "1 \(singular)"
            case let pluralValue: return "\(pluralValue) \(plural)"
            }
        }
        minutesLabel.text = pluralize(minutes, singular: "minute", plural: "minutes")
        secondsLabel.text = pluralize(seconds, singular: "second", plural: "seconds")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch timerModel.type {
            case .coffee: timerTypeSegmentedControl.selectedSegmentIndex = 0
            case .tea: timerTypeSegmentedControl.selectedSegmentIndex = 1
        }
        let numberOfMinutes = Int(timerModel.duration / 60)
        let numberOfSeconds = Int(timerModel.duration % 60)
        nameField.text = timerModel.name
        if let brand = timerModel.brand as BrandModel? {
            brandField.text = brand.name
        }
        favoriteButton.isSelected = timerModel.favorite
        
        updateLabelsWithMinutes(numberOfMinutes, seconds: numberOfSeconds)
        minutesSlider.value = Float(numberOfMinutes)
        secondsSlider.value = Float(numberOfSeconds)
        favoriteButton.setImage(UIImage(named: "checked"), for: UIControlState.selected)
        nameField.delegate = self
        brandField.delegate = self
    }
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        startObservingKeyboardEvents()
//    }
//    
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//        stopObservingKeyboardEvents()
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BrandSelection" {
            let brandsTableViewController: BrandsTableViewController = segue.destination as! BrandsTableViewController
            brandsTableViewController.brandCompletion = {(brand: BrandModel) -> () in self
                self.timerModel.brand = brand
                self.brandField.text = brand.name
            }
            
            brandsTableViewController.brandSelected = sender as? BrandModel
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Keyboard observer convenience
    
//    private func startObservingKeyboardEvents() {
//        NSNotificationCenter.defaultCenter().addObserver(self,
//            selector:Selector("keyboardWillShow:"),
//            name:UIKeyboardWillShowNotification,
//            object:nil)
//        NSNotificationCenter.defaultCenter().addObserver(self,
//            selector:Selector("keyboardWillHide:"),
//            name:UIKeyboardWillHideNotification,
//            object:nil)
//    }
//    
//    private func stopObservingKeyboardEvents() {
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
//    }
//    
//    func keyboardWillShow(notification: NSNotification) {
//        
//    }
//    
//    func keyboardWillHide(notification: NSNotification) {
//        
//    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 1 {
            self.view.endEditing(true)
//            textField.resignFirstResponder()
            self.performSegue(withIdentifier: "BrandSelection", sender: timerModel.brand)
            return false
        }
        return true
    }
    
}

/// MARK: - BrandsTableViewControllerDelegate

extension TimerEditViewController: BrandsTableViewControllerDelegate
{
    func brandsTableViewControllerDidFinishSelectingBrand(_ viewController: BrandsTableViewController, brand: BrandModel) {
        timerModel.brand = brand
        brandField.text = brand.name
    }
}
