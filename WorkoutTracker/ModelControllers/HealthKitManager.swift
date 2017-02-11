//
//  HealthKitManager.swift
//  WorkoutTracker
//
//  Created by SarahEOlson on 9/25/16.
//  Copyright © 2016 SarahEOlson. All rights reserved.
//

import Foundation
import HealthKit

protocol HeartRateDelegate {
    func didReceiveNewHeartRate(heartRate: HKQuantitySample)
}

protocol WorkoutDelegate {
    func didReceiveNewWorkout(workout: HKWorkout)
}

let hrUnit = HKUnit(from: "count/min")

let hrType:HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!

/**
 *  Interface for retrieving and saving health data.
 */
class HealthKitManager {
    
    class var sharedInstance: HealthKitManager {
        struct Singleton {
            static let instance = HealthKitManager()
        }
        return Singleton.instance
    }
    
    let healthStore: HKHealthStore? = {
        if HKHealthStore.isHealthDataAvailable() {
            return HKHealthStore()
        } else {
            return nil
        }
    }()
    
    let workoutType = HKObjectType.workoutType()
    let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)
    
    var isAuthorized = false
    
    var heartRateDelegate: HeartRateDelegate?
    var workoutDelegate: WorkoutDelegate?
    //var workoutSession: HKWorkoutSession? = nil
    
    func authorizeHealthKit(completion: ((_ wasSuccessful: Bool, _ wasError: NSError?) -> Void)!) {
        
        let healthKitTypesToRead: Set<HKObjectType>
        let healthKitTypesToWrite: Set<HKSampleType>
        
        if let heartRateType = heartRateType {
            healthKitTypesToRead = [workoutType, heartRateType]
            healthKitTypesToWrite = [workoutType, heartRateType]
        } else {
            healthKitTypesToRead = [workoutType]
            healthKitTypesToWrite = [workoutType]
        }
        
        healthStore?.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead, completion: { [weak self] (success, error) in
            
            if success {
                self?.isAuthorized = true
                print("SUCCESS")
            } else {
                print(error?.localizedDescription)
            }
            })
    }
    
    func createMockData() {
        
        // Generate a random number between 80 and 100
        let heartRateQuantity = HKQuantity(unit: HKUnit(from: "count/min") , doubleValue: Double(arc4random_uniform(80) + 100))
        
        // Create the sample
        if let heartRateQuantityType = HKQuantityType.quantityType(forIdentifier: .heartRate) {
            let heartSample = HKQuantitySample(type: heartRateQuantityType, quantity: heartRateQuantity, start: Date(), end: Date())
            
            // save the sample
            healthStore?.save(heartSample, withCompletion: { (success, error) in
                if let error = error {
                    print("Error saving heart rate sample: \(error.localizedDescription)")
                }
            })
        }
    }
    
    func retrieveHeartRate() {
        
        if let heartRate = HKQuantityType.quantityType(forIdentifier: .heartRate) {
            
            let heartRateQuery = HKSampleQuery(sampleType: heartRate, predicate: nil, limit: 1, sortDescriptors: nil) { [weak self] (query, results, error) in
                
                if let results = results as? [HKQuantitySample] {
                    print("Results: \(results)")
                    
                    if results.count > 0 {
                        self?.heartRateDelegate?.didReceiveNewHeartRate(heartRate: results[0])
                    }
                } else {
                    print("ERROR")
                }
            }
            healthStore?.execute(heartRateQuery)
        }
    }
    
    /// This function gets HKWorkouts from the Health Store that were created by this app
    func readWorkouts(_ completion: @escaping (_ success: Bool, _ workouts:[HKWorkout], _ error: Error?) -> Void) {
        
        // Predicate indicating "this app"
        let sourcePredicate = HKQuery.predicateForObjects(from: HKSource.default())
        
        // Get workouts that took some amount of time
        let workoutsPredicate = HKQuery.predicateForWorkouts(with: .greaterThan, duration: 0)
        
        // AND the two predicates together
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [sourcePredicate, workoutsPredicate])
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        
        let sampleQuery = HKSampleQuery(sampleType: HKWorkoutType.workoutType(), predicate: predicate, limit: 0, sortDescriptors: [sortDescriptor])
        { (sampleQuery, results, error ) -> Void in
            
            guard let samples = results as? [HKWorkout] else {
                completion(false, [HKWorkout](), error)
                return
            }
            
            completion(error == nil, samples, error)
        }
        healthStore?.execute(sampleQuery)
    }
    
    /// This function gets samples of a certain type from the workout passed in
    func samplesForWorkout(_ workout: HKWorkout,
                           intervalStart: Date,
                           intervalEnd: Date,
                           type: HKQuantityType,
                           completion: @escaping (_ samples: [HKSample], _ error: Error?) -> Void) {
        
        // Start with the workout
        let workoutPredicate = HKQuery.predicateForObjects(from: workout)
        
        // Just get samples within the timeframe of a certain interval
        let datePredicate = HKQuery.predicateForSamples(withStart: intervalStart, end: intervalEnd, options: HKQueryOptions())
        
        // AND the two predicates
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [workoutPredicate, datePredicate])
        let startDateSort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 0, sortDescriptors: [startDateSort]) { (query, samples, error) -> Void in
            completion(samples!, error)
        }
        healthStore?.execute(query)
    }
    
    /// This function gets statistics of a certain type from the workout passed in
    func statisticsForWorkout(_ workout: HKWorkout,
                              intervalStart: Date,
                              intervalEnd: Date,
                              type: HKQuantityType,
                              options: HKStatisticsOptions,
                              completion: @escaping (_ statistics: HKStatistics, _ error: Error?) -> Void) {
        
        // Start with the workout
        let workoutPredicate = HKQuery.predicateForObjects(from: workout)
        
        // Just get stats within the timeframe of a certain interval
        let datePredicate = HKQuery.predicateForSamples(withStart: intervalStart, end: intervalEnd, options: HKQueryOptions())
        
        // AND the two predicates
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [workoutPredicate, datePredicate])
        
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: options) { (query, stats, error) -> Void in
            completion(stats!, error)
        }
        healthStore?.execute(query)
    }
}
