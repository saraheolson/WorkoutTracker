//
//  CurrentWorkoutViewController.swift
//  WorkoutTracker
//
//  Created by SarahEOlson on 9/25/16.
//  Copyright © 2016 SarahEOlson. All rights reserved.
//

import UIKit
import HealthKit

class CurrentWorkoutViewController: UIViewController {
    
    @IBOutlet var countdownLabel: UILabel!
    @IBOutlet var heartRateLabel: UILabel!
    
    var currentExercise: Exercise?
    var countdown = 0
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Update the label
        heartRateLabel.text = "Gathering data..."
        
        if let exercise = currentExercise {
            
            countdown = Int(exercise.duration)
            countdownLabel.text = "\(countdown)"

            // initiate the countdown
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
        }
        
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
    
    func updateCountdown() {
        if countdown > 0 {
            countdown -= 1
            countdownLabel.text = "\(countdown)"
        } else {
            timer?.invalidate()
        }
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
        print("Workout Events: \(workoutEvents)")
    }
}
