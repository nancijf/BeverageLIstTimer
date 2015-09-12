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

class TimerEditViewController: UIViewController {
    
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
        timerModel.brand = brandField.text
        timerModel.duration = Int32(Int(minutesSlider.value) * 60 + Int(secondsSlider.value))
        println("favorite = \(favoriteButton.selected)")
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
//        println("button pressed")
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
        minutesLabel.text = pluralize(minutes, "minute", "minutes")
        secondsLabel.text = pluralize(seconds, "second", "seconds")
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
        brandField.text = timerModel.brand
        favoriteButton.selected = timerModel.favorite
        
        updateLabelsWithMinutes(numberOfMinutes, seconds: numberOfSeconds)
        minutesSlider.value = Float(numberOfMinutes)
        secondsSlider.value = Float(numberOfSeconds)
        favoriteButton.setImage(UIImage(named: "checked"), forState: UIControlState.Selected)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
