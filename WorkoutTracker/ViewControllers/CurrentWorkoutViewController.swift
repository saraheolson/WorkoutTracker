//
//  CurrentWorkoutViewController.swift
//  WorkoutTracker
//
//  Created by Floater on 9/25/16.
//  Copyright © 2016 SarahEOlson. All rights reserved.
//

import UIKit
import HealthKit

class CurrentWorkoutViewController: UIViewController {
    
    @IBOutlet var heartRateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Update the label
        heartRateLabel.text = "Gathering data..."
        
        // Authorize access to HealthKit data
        HealthKitManager.sharedInstance.authorizeHealthKit { (success, error) in
            print(success)
        }
        
        // Assign this class as the delegate for data
        HealthKitManager.sharedInstance.heartRateDelegate = self
        HealthKitManager.sharedInstance.workoutDelegate = self

        // NOTE: Don't run this on a device or it will modify your HealthKit data
        HealthKitManager.sharedInstance.createMockData()
        
        // Retrieve the latest heart rate
        HealthKitManager.sharedInstance.retrieveHeartRate()
    }
}
extension CurrentWorkoutViewController: HeartRateDelegate {
    
    func didReceiveNewHeartRate(heartRate: HKQuantitySample) {
        
        // Ensure UI changes happen on the main thread or you'll get an exception
        DispatchQueue.main.async {
            
            // Update the heart rate label with the HealthKit value
            let theValue = heartRate.quantity.doubleValue(for: HKUnit(from: "count/min"))
            self.heartRateLabel.text = "\(Int(theValue))"
        }
    }
}

extension CurrentWorkoutViewController: WorkoutDelegate {
    
    func didReceiveNewWorkout(workout: HKWorkout) {
        let workoutEvents = workout.workoutEvents
        
    }
}
