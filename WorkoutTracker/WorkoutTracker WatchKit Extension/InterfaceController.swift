//
//  InterfaceController.swift
//  WorkoutTracker WatchKit Extension
//
//  Created by Sarah Olson on 2/18/17.
//  Copyright © 2017 HPlus. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit

class InterfaceController: WKInterfaceController {

    @IBOutlet var heartImage: WKInterfaceImage!
    @IBOutlet var heartRateLabel: WKInterfaceLabel!
    @IBOutlet var workoutButton: WKInterfaceButton!
    
    let healthKitManager = HealthKitManager.sharedInstance

    var workoutSession: HKWorkoutSession?
    var workoutStartDate: Date?
    
    var isWorkoutInProgress = false

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        healthKitManager.authorizeHealthKitAccess { [weak self] (success, error) in
            print("HealthKit authorized? \(success)")
            
            self?.createWorkoutSession()
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    @IBAction func startOrStopWorkout() {

        if isWorkoutInProgress {
            endWorkoutSession()
        } else {
            startWorkoutSession()
        }
        
        isWorkoutInProgress = !isWorkoutInProgress
        self.workoutButton.setTitle(isWorkoutInProgress ? "End Workout" : "Start Workout")
    }
    
    // MARK: - HealthKit
    
    func createWorkoutSession() {
        
        let hkWorkoutConfiguration = HKWorkoutConfiguration()
        hkWorkoutConfiguration.activityType = .other
        hkWorkoutConfiguration.locationType = .indoor
        
        do {
            workoutSession = try HKWorkoutSession(configuration: hkWorkoutConfiguration)
        } catch {
            print("Could not create a session.")
        }
    }
    
    func startWorkoutSession() {
        
        guard let session = workoutSession else {
            print("Cannot create a workout without a session.")
            return
        }
        workoutStartDate = Date()
        healthKitManager.healthStore.start(session)
    }
    
    func endWorkoutSession() {
        guard let session = workoutSession else {
            print("Cannot end a workout without a session.")
            return
        }
        healthKitManager.healthStore.end(session)
    }
}
