//
//  TimerDetailViewController.swift
//  Coffee Timer
//
//  Created by Nanci Frank on 8/9/15.
//  Copyright (c) 2015 Wildcat Productions. All rights reserved.
//

import UIKit

class TimerDetailViewController: UIViewController {
    
    enum StopTimerReason {
        case Cancelled
        case Completed
    }
    
    @IBOutlet weak var countdownLabel: UILabel!
    
    @IBOutlet weak var startStopButton: UIButton!
    
    var timerModel: TimerModel!
    weak var timer: NSTimer?
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = timerModel.name
        countdownLabel.text = timerModel.durationText
        timerModel.addObserver(self, forKeyPath: "duration", options: .New, context: nil)
        timerModel.addObserver(self, forKeyPath: "name", options: .New, context: nil)
    }
    
    deinit {
        timerModel.removeObserver(self, forKeyPath: "duration")
        timerModel.removeObserver(self, forKeyPath: "name")
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if keyPath == "duration" {
            countdownLabel.text = timerModel.durationText
        } else if keyPath == "name" {
            title = timerModel.name
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Requestlocal notifications and set up local notification
        let settings = UIUserNotificationSettings(forTypes: (.Alert | .Sound), categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
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
        startStopButton.setTitle("Stop Timer", forState: .Normal)
        startStopButton.setTitleColor(UIColor.redColor(), forState: .Normal)
        timer = NSTimer.scheduledTimerWithTimeInterval(1,
            target: self,
            selector: "timerFired",
            userInfo: nil,
            repeats: true)
        // Set up local notification
        let localNotification = UILocalNotification()
        localNotification.alertBody = "Timer Completed!"
        localNotification.fireDate = NSDate().dateByAddingTimeInterval(NSTimeInterval(timerModel.duration))
        localNotification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        notification = localNotification
        updateTimer()
    }
    
    func stopTimer(reason: StopTimerReason) {
        navigationItem.setHidesBackButton(false, animated: true)
        countdownLabel.text = timerModel.durationText
        startStopButton.setTitle("Start Timer", forState: .Normal)
        startStopButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        timer?.invalidate()
        
        if reason == .Cancelled {
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
        notification = nil
    }
    
    @IBAction func buttonWasPressed(sender: AnyObject) {
        println("Button was pressed.")
        if let _ = timer {
            // Timer is running and button was pressed. Stop timer.
            stopTimer(.Cancelled)
        } else {
            // Timer is not running and button is pressed. Start timer.
            startTimer()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editDetail" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let editViewController = navigationController.topViewController as! TimerEditViewController
            editViewController.timerModel = timerModel
        }
    }
}

extension TimerModel {
    var durationText: String {
        return String(format: "%d:%02d", duration/60, duration % 60)
    }
}
