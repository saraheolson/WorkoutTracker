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

    var heartRateSamples: [HKQuantitySample] = [HKQuantitySample]()
    
    var heartRateQuery : HKQuery?
    
    var anchor: HKQueryAnchor?
    
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
            workoutSession?.delegate = self
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
        
        saveWorkout()
    }
    
    func saveWorkout() {
        
        guard let startDate = self.workoutStartDate else {
            print("Workout start date cannot be nil.")
            return
        }
        
        // Create some basic workout metadata
        let metadata = [HKMetadataKeyIndoorWorkout : true]
        
        // Create a workout object
        let workout = HKWorkout(activityType: .highIntensityIntervalTraining,
                                start: startDate,
                                end: Date(),
                                duration: Date().timeIntervalSince(startDate),
                                totalEnergyBurned: nil,
                                totalDistance: nil,
                                metadata: metadata)
        
        // Save the workout data
        healthKitManager.healthStore.save(workout) { [weak self] (success, error) in
            
            // Error saving our workout
            if !success {
                print("Could not successfully save workout. \(error)")
                return
            }
            
            // Check to see if we've gathered any heart rate data
            guard let samples = self?.heartRateSamples, samples.count > 0 else {
                print("No workout data collected.")
                return
            }
            
            // Save the heart rate data to our health store
            self?.healthKitManager.healthStore.add(samples, to: workout, completion: { (success, error) in
                print("Successfully saved workout data.")
            })
        }
    }
}

extension InterfaceController: HKWorkoutSessionDelegate {
    
    func workoutSession(_ workoutSession: HKWorkoutSession,
                        didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState, date: Date) {
        switch toState {
        case .running:
            self.sessionStarted(date)
        case .ended:
            self.sessionEnded(date)
        default:
            print("Invalid workout state.")
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession,
                        didFailWithError error: Error) {
        print("Workout failed with error: \(error)")
        sessionEnded(Date())
    }
    
    func sessionStarted(_ date: Date) {
        print("Workout started.")
        
        if let query = createHeartRateStreamingQuery(date) {
            self.heartRateQuery = query
            healthKitManager.healthStore.execute(query)
        } else {
            print("cannot start")
        }
    }
    
    func sessionEnded(_ date: Date) {
        print("Workout ended.")
        
        healthKitManager.healthStore.stop(self.heartRateQuery!)
    }
    
    func createHeartRateStreamingQuery(_ workoutStartDate: Date) -> HKQuery? {
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else { return nil }
        let datePredicate = HKQuery.predicateForSamples(withStart: workoutStartDate, end: nil, options: .strictEndDate )
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates:[datePredicate])
        
        
        let heartRateQuery = HKAnchoredObjectQuery(type: quantityType,
                                                   predicate: predicate,
                                                   anchor: nil,
                                                   limit: Int(HKObjectQueryNoLimit))
        { (query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
            
            guard let newAnchor = newAnchor else {return}
            self.anchor = newAnchor
            
            self.updateHeartRate(sampleObjects)
        }
        
        heartRateQuery.updateHandler = {(query, samples, deleteObjects, newAnchor, error) -> Void in
            self.anchor = newAnchor!
            self.updateHeartRate(samples)
        }
        return heartRateQuery
    }
    
    func updateHeartRate(_ samples: [HKSample]?) {
        
        guard let heartRateSamples = samples as? [HKQuantitySample] else {
            return
        }
        
        DispatchQueue.main.async {
            
            self.heartRateSamples += heartRateSamples
            
            guard let sample = heartRateSamples.first else {
                return
            }
            let value = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            print("New heart rate value received: \(value)")
            let heartRateString = String(format: "%.00f", value)
            self.heartRateLabel.setText(heartRateString)
        }
    }
}
