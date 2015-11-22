//
//  TimerDetailViewController.swift
//  Coffee Timer
//
//  Created by Nanci Frank on 8/9/15.
//  Copyright (c) 2015 Wildcat Productions. All rights reserved.
//

import UIKit
import CoreData


class TimerDetailViewController: UIViewController {
    
    enum StopTimerReason {
        case Cancelled
        case Completed
        case Paused
    }
    
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var favoriteButton: NFCheckboxButton!
    @IBOutlet weak var resetTimer: UIButton!
    @IBOutlet weak var coffeeTeaName: UILabel!
    @IBOutlet weak var brandField: UILabel!
    
    var timerModel: TimerModel!
    weak var timer: NSTimer?
    var pauseTime: NSInteger = 0
    var notification: UILocalNotification?
    var timeRemaining: NSInteger {
        if let fireDate = notification?.fireDate {
            let now = NSDate()
            let timeInterval = fireDate.timeIntervalSinceDate(now)
            let roundedTimeInterval = round(timeInterval)
            return NSInteger(roundedTimeInterval)
        } else {
            return 0
        }
    }
    
    @IBAction func tapFavoriteButton(sender: UIButton) {
        sender.selected = !sender.selected
        timerModel.favorite = favoriteButton.selected
        appDelegate().saveCoreData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Timer"
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "duration" {
            countdownLabel.text = timerModel.durationText
        } else if keyPath == "name" {
            title = timerModel.name
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        coffeeTeaName.text = timerModel.name
        coffeeTeaName.enabled = false
        brandField.text = timerModel.brand.name
        brandField.enabled = false
        countdownLabel.text = timerModel.durationText
        timerModel.addObserver(self, forKeyPath: "duration", options: .New, context: nil)
        timerModel.addObserver(self, forKeyPath: "name", options: .New, context: nil)
        self.favoriteButton.selected = timerModel.favorite
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Request local notifications and set up local notification
        let settings = UIUserNotificationSettings(forTypes: ([.Alert, .Sound]), categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
    
    override func viewWillDisappear(animated: Bool) {
        timerModel.removeObserver(self, forKeyPath: "duration")
        timerModel.removeObserver(self, forKeyPath: "name")
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        stopTimer(.Cancelled)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func timerFired() {
        if timeRemaining > 0 {
            updateTimer()
        } else {
            stopTimer(.Completed)
        }
    }

    func updateTimer() {
        countdownLabel.text = String(format: "%d:%02d", timeRemaining / 60, timeRemaining % 60)
    }

    func startTimer() {
        navigationItem.rightBarButtonItem?.enabled = true
        navigationItem.setHidesBackButton(true, animated: true)
        startStopButton.setTitle("Stop", forState: .Normal)
        startStopButton.setTitleColor(UIColor.redColor(), forState: .Normal)
        timer = NSTimer.scheduledTimerWithTimeInterval(1,
            target: self,
            selector: "timerFired",
            userInfo: nil,
            repeats: true)
        // Set up local notification
        let localNotification = UILocalNotification()
        localNotification.alertBody = "Timer Completed!"
        if (pauseTime > 0) {
            localNotification.fireDate = NSDate().dateByAddingTimeInterval(NSTimeInterval(pauseTime))
        }
        else {
            localNotification.fireDate = NSDate().dateByAddingTimeInterval(NSTimeInterval(timerModel.duration))
        }
        localNotification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        notification = localNotification
        updateTimer()
    }
    
    func stopTimer(reason: StopTimerReason) {
        navigationItem.setHidesBackButton(false, animated: true)
        pauseTime = timeRemaining
        startStopButton.setTitle("Start", forState: .Normal)
        startStopButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        timer?.invalidate()
        
        if reason == .Cancelled {
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            countdownLabel.text = timerModel.durationText
            notification = nil
            pauseTime = 0
        } else if reason == .Completed {
            pauseTime = 0
        }
    }
    
    @IBAction func buttonWasPressed(sender: AnyObject) {
        if let _ = timer {
            // Timer is running and button was pressed. Stop timer.
            stopTimer(.Paused)
        } else {
            // Timer is not running and button is pressed. Start timer.
            startTimer()
        }
    }
    
    @IBAction func resetWasPressed(sender: AnyObject) {
        stopTimer(.Cancelled)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editDetail" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let editViewController = navigationController.topViewController as! TimerEditViewController
            editViewController.timerModel = timerModel
            let listViewController = (parentViewController as! UINavigationController).viewControllers.first as! TimerListTableViewController
            editViewController.delegate = listViewController
        }
    }
}

extension TimerModel {
    var durationText: String {
        return String(format: "%d:%02d", duration/60, duration % 60)
    }
}
