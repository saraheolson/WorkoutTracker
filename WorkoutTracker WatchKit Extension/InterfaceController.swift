//
//  InterfaceController.swift
//  WorkoutTracker WatchKit Extension
//
//  Created by SarahEOlson on 9/25/16.
//  Copyright © 2016 SarahEOlson. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit

class InterfaceController: WKInterfaceController {

    @IBOutlet var heartRateLabel: WKInterfaceLabel!
    @IBOutlet var activityTimer: WKInterfaceTimer!
    @IBOutlet var pauseButton: WKInterfaceButton!
    
    let countdownSeconds: TimeInterval = 30
    var timer: Timer? = nil
    
    let healthStore = HKHealthStore()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        // Authorize access to HealthKit data
        HealthKitManager.sharedInstance.authorizeHealthKit { (success, error) in
            print(success)
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func onPauseButton() {
        print("Start")
        
        timer = Timer.scheduledTimer(withTimeInterval: countdownSeconds, repeats: false) { (timer) in
            
            if let workoutSession = WorkoutSessionManager.sharedInstance.workoutSession {
                
                self.healthStore.end(workoutSession)
                
                self.healthStore.save(workoutSession) { (success, error) in
                    print("Workout saved")
                }
            }
        }
        activityTimer.setDate(Date(timeIntervalSinceNow: countdownSeconds))
        activityTimer.start()
    }
}
