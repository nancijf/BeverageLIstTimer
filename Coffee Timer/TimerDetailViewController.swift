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
        case cancelled
        case completed
        case paused
    }
    
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var favoriteButton: NFCheckboxButton!
    @IBOutlet weak var resetTimer: UIButton!
    @IBOutlet weak var coffeeTeaName: UILabel!
    @IBOutlet weak var brandField: UILabel!
    
    var timerModel: TimerModel!
    weak var timer: Timer?
    var pauseTime: NSInteger = 0
    var notification: UILocalNotification?
    var timeRemaining: NSInteger {
        if let fireDate = notification?.fireDate {
            let now = Date()
            let timeInterval = fireDate.timeIntervalSince(now)
            let roundedTimeInterval = round(timeInterval)
            return NSInteger(roundedTimeInterval)
        } else {
            return 0
        }
    }
    
    @IBAction func tapFavoriteButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        timerModel.favorite = favoriteButton.isSelected
        appDelegate().saveCoreData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Timer"
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "duration" {
            countdownLabel.text = timerModel.durationText
        } else if keyPath == "name" {
            title = timerModel.name
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coffeeTeaName.text = timerModel.name
        coffeeTeaName.isEnabled = false
        brandField.text = timerModel.brand.name
        brandField.isEnabled = false
        countdownLabel.text = timerModel.durationText
        timerModel.addObserver(self, forKeyPath: "duration", options: .new, context: nil)
        timerModel.addObserver(self, forKeyPath: "name", options: .new, context: nil)
        self.favoriteButton.isSelected = timerModel.favorite
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Request local notifications and set up local notification
        let settings = UIUserNotificationSettings(types: ([.alert, .sound]), categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timerModel.removeObserver(self, forKeyPath: "duration")
        timerModel.removeObserver(self, forKeyPath: "name")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopTimer(.cancelled)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func timerFired() {
        if timeRemaining > 0 {
            updateTimer()
        } else {
            stopTimer(.completed)
        }
    }

    func updateTimer() {
        countdownLabel.text = String(format: "%d:%02d", timeRemaining / 60, timeRemaining % 60)
    }

    func startTimer() {
        navigationItem.rightBarButtonItem?.isEnabled = true
        navigationItem.setHidesBackButton(true, animated: true)
        startStopButton.setTitle("Stop", for: UIControlState())
        startStopButton.setTitleColor(UIColor.red, for: UIControlState())
        timer = Timer.scheduledTimer(timeInterval: 1,
            target: self,
            selector: #selector(TimerDetailViewController.timerFired),
            userInfo: nil,
            repeats: true)
        // Set up local notification
        let localNotification = UILocalNotification()
        localNotification.alertBody = "Timer Completed!"
        if (pauseTime > 0) {
            localNotification.fireDate = Date().addingTimeInterval(TimeInterval(pauseTime))
        }
        else {
            localNotification.fireDate = Date().addingTimeInterval(TimeInterval(timerModel.duration))
        }
        localNotification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.shared.scheduleLocalNotification(localNotification)
        notification = localNotification
        updateTimer()
    }
    
    func stopTimer(_ reason: StopTimerReason) {
        navigationItem.setHidesBackButton(false, animated: true)
        pauseTime = timeRemaining
        startStopButton.setTitle("Start", for: UIControlState())
        startStopButton.setTitleColor(UIColor.black, for: UIControlState())
        timer?.invalidate()
        
        if reason == .cancelled {
            UIApplication.shared.cancelAllLocalNotifications()
            countdownLabel.text = timerModel.durationText
            notification = nil
            pauseTime = 0
        } else if reason == .completed {
            pauseTime = 0
        }
    }
    
    @IBAction func buttonWasPressed(_ sender: AnyObject) {
        if let _ = timer {
            // Timer is running and button was pressed. Stop timer.
            stopTimer(.paused)
        } else {
            // Timer is not running and button is pressed. Start timer.
            startTimer()
        }
    }
    
    @IBAction func resetWasPressed(_ sender: AnyObject) {
        stopTimer(.cancelled)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editDetail" {
            let navigationController = segue.destination as! UINavigationController
            let editViewController = navigationController.topViewController as! TimerEditViewController
            editViewController.timerModel = timerModel
            let listViewController = (parent as! UINavigationController).viewControllers.first as! TimerListTableViewController
            editViewController.delegate = listViewController
        }
    }
}

extension TimerModel {
    var durationText: String {
        return String(format: "%d:%02d", duration/60, duration % 60)
    }
}
