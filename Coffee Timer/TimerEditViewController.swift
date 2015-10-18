//
//  TimerEditViewController.swift
//  Coffee Timer
//
//  Created by Nanci Frank on 8/9/15.
//  Copyright (c) 2015 Wildcat Productions. All rights reserved.
//

import UIKit

@objc protocol TimerEditViewControllerDelegate {
    func timerEditViewControllerDidCancel(viewController: TimerEditViewController)
    func timerEditViewControllerDidSave(viewController: TimerEditViewController)
}

class TimerEditViewController: UIViewController, UITextFieldDelegate {
    
    var creatingNewTimer = false
    var coffeeTimers: [TimerModel]!
    var teaTimers: [TimerModel]!
    var timerModel: TimerModel!
    weak var delegate: TimerEditViewControllerDelegate?

    @IBOutlet weak var timerTypeSegmentedControl: UISegmentedControl!
    
    @IBAction func cancelWasPressed(sender: UIBarButtonItem) {
        delegate?.timerEditViewControllerDidCancel(self)
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneWasPressed(sender: UIBarButtonItem) {
        timerModel.favorite = favoriteButton.selected
        timerModel.name = nameField.text
        timerModel.brand.name = brandField.text!
        timerModel.duration = Int32(Int(minutesSlider.value) * 60 + Int(secondsSlider.value))
        if timerTypeSegmentedControl.selectedSegmentIndex == 0 {
            timerModel.type = .Coffee
        } else { // Must be 1
            timerModel.type = .Tea
        }
        delegate?.timerEditViewControllerDidSave(self)
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        let numberOfMinutes = Int(minutesSlider.value)
        let numberOfSeconds = Int(secondsSlider.value)
        updateLabelsWithMinutes(numberOfMinutes, seconds: numberOfSeconds)
    }
    
    @IBAction func tapFavoriteButton(sender: UIButton) {
        sender.selected = !sender.selected
    }
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var brandField: UITextField!
    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var minutesSlider: UISlider!
    @IBOutlet weak var secondsLabel: UILabel!
    @IBOutlet weak var secondsSlider: UISlider!
    
    func updateLabelsWithMinutes(minutes: Int, seconds: Int) {
        func pluralize(value: Int, singular: String, plural: String) -> String {
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
            case .Coffee: timerTypeSegmentedControl.selectedSegmentIndex = 0
            case .Tea: timerTypeSegmentedControl.selectedSegmentIndex = 1
        }
        let numberOfMinutes = Int(timerModel.duration / 60)
        let numberOfSeconds = Int(timerModel.duration % 60)
        nameField.text = timerModel.name
        if let brand = timerModel.brand as BrandModel? {
            brandField.text = brand.name
        }
        favoriteButton.selected = timerModel.favorite
        
        updateLabelsWithMinutes(numberOfMinutes, seconds: numberOfSeconds)
        minutesSlider.value = Float(numberOfMinutes)
        secondsSlider.value = Float(numberOfSeconds)
        favoriteButton.setImage(UIImage(named: "checked"), forState: UIControlState.Selected)
        nameField.delegate = self
        brandField.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        startObservingKeyboardEvents()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        stopObservingKeyboardEvents()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "BrandSelection" {
            let brandsTableViewController: BrandsTableViewController = segue.destinationViewController as! BrandsTableViewController
            brandsTableViewController.brandCompletion = {(brand: BrandModel) -> () in self
                self.timerModel.brand = brand
                self.brandField.text = brand.name
            }
            
            brandsTableViewController.brandSelected = sender as? BrandModel
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Keyboard observer convenience
    
    private func startObservingKeyboardEvents() {
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:Selector("keyboardWillShow:"),
            name:UIKeyboardWillShowNotification,
            object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:Selector("keyboardWillHide:"),
            name:UIKeyboardWillHideNotification,
            object:nil)
    }
    
    private func stopObservingKeyboardEvents() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size {
                let contentInset = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let contentInset = UIEdgeInsetsZero;
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField.tag == 1 {
            textField.resignFirstResponder()
            self.performSegueWithIdentifier("BrandSelection", sender: timerModel.brand)
            return false
        }
        return true
    }
    
}

/// MARK: - BrandsTableViewControllerDelegate

extension TimerEditViewController: BrandsTableViewControllerDelegate
{
    func brandsTableViewControllerDidFinishSelectingBrand(viewController: BrandsTableViewController, brand: BrandModel) {
        timerModel.brand = brand
        brandField.text = brand.name
    }
}
