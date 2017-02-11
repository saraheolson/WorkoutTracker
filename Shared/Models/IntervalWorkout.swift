//
//  IntervalWorkout.swift
//  WorkoutTracker
//
//  Created by Sarah Olson on 11/27/16.
//  Copyright © 2016 SarahEOlson. All rights reserved.
//

import Foundation
import HealthKit

// ****** Units and Types
let energyUnit = HKUnit.kilocalorie()
let energyFormatterUnit: EnergyFormatter.Unit = {
    return HKUnit.energyFormatterUnit(from: energyUnit)
} ()

class IntervalWorkout {
    
    // MARK: - Properties
    let workout: HKWorkout
    let configuration: Workout
    let intervals: [Interval]
    
    init(withWorkout workout:HKWorkout, configuration:Workout) {
        self.workout = workout
        self.configuration = configuration
        self.intervals = {
            var ints: [Interval] = [Interval]()
            
            let activeLength = configuration.activeTime
            let restLength = configuration.restTime
            
            var intervalStart = workout.startDate
            
            while intervalStart.compare(workout.endDate) == .orderedAscending {
                let restStart = Date(timeInterval: activeLength, since: intervalStart)
                let interval = Interval(activeStartTime: intervalStart,
                                                       restStartTime: restStart,
                                                       duration: activeLength,
                                                       endTime: Date(timeInterval: restLength, since: restStart)
                )
                ints.append(interval)
                intervalStart = Date(timeInterval: activeLength + restLength, since: intervalStart)
            }
            return ints
        } ()
    }
    
    // MARK: - Read-Only Properties
    
    var startDate: Date {
        return workout.startDate
    }
    
    var endDate: Date {
        return workout.endDate
    }
    
    var duration: TimeInterval {
        return workout.duration
    }
    
    var calories: Double {
        guard let energy = workout.totalEnergyBurned else {return 0.0}
        
        return energy.doubleValue(for: energyUnit)
    }
}

class Interval {
    let activeStartTime: Date
    let duration: TimeInterval
    let restStartTime: Date
    let endTime: Date
    
    init (activeStartTime: Date, restStartTime: Date, duration: TimeInterval, endTime: Date) {
        self.activeStartTime = activeStartTime
        self.restStartTime = restStartTime
        self.duration = duration
        self.endTime = endTime
    }
    
    var hrStats: HKStatistics?
    var caloriesStats: HKStatistics?
    
    var averageHeartRate: Double? {
        guard let hrStats = hrStats else { return nil }
        return hrStats.averageQuantity()?.doubleValue(for: hrUnit)
    }
    
    var calories: Double? {
        guard let caloriesStats = caloriesStats else { return nil }
        return caloriesStats.sumQuantity()?.doubleValue(for: energyUnit)
    }
    
}

