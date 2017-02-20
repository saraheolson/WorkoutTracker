//
//  HealthKitManager.swift
//  WorkoutTracker
//
//  Created by Sarah Olson on 2/19/17.
//  Copyright © 2017 HPlus. All rights reserved.
//

import Foundation
import HealthKit

// Defines the heart rate type in HealthKit
let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)

protocol HeartRateDelegate {
    func heartRateUpdated(heartRateSamples: [HKSample])
}

// Class for sharing HealthKit resources between watch and phone
class HealthKitManager : NSObject {
    
    // We want a single instance of this class so this is how its methods will be accessed
    static let sharedInstance = HealthKitManager()
    
    // Override the init method so users can't create an instance of this class
    private override init() {}
    
    // Keep a single instance of the healthstore
    let healthStore = HKHealthStore()
    
    // Subscribe to heart rate changes
    var heartRateDelegate: HeartRateDelegate?
    
    // Keep track of last heart rate data received
    var anchor: HKQueryAnchor?
    
    // Requests authorization for health data access
    func authorizeHealthKitAccess(_ completion: ((_ success: Bool, _ error: Error?) -> Void)!) {
        
        let hrType:HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        
        let typesToShare = Set([HKObjectType.workoutType(), hrType])
        let typesToSave = Set([HKObjectType.workoutType(), hrType])
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToSave) { (success, error) in
            print("Was HealthKit authorization successful? \(success)")
            completion(success, error)
        }
    }
    
    func createHeartRateStreamingQuery(_ workoutStartDate: Date) -> HKQuery? {
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
            return nil
        }
        let datePredicate = HKQuery.predicateForSamples(withStart: workoutStartDate, end: nil, options: .strictEndDate )
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates:[datePredicate])
        
        let heartRateQuery = HKAnchoredObjectQuery(type: quantityType,
                                                   predicate: predicate,
                                                   anchor: nil,
                                                   limit: Int(HKObjectQueryNoLimit))
        { (query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
            
            guard let newAnchor = newAnchor, let sampleData = sampleObjects else {
                return
            }
            self.anchor = newAnchor
            
            self.heartRateDelegate?.heartRateUpdated(heartRateSamples: sampleData)
        }
        
        heartRateQuery.updateHandler = {(query, samples, deleteObjects, newAnchor, error) -> Void in
            
            guard let newAnchor = newAnchor, let sampleData = samples else {
                return
            }
            self.anchor = newAnchor
            self.heartRateDelegate?.heartRateUpdated(heartRateSamples: sampleData)
        }
        return heartRateQuery
    }
}
