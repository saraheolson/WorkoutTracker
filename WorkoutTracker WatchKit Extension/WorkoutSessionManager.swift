//
//  WorkoutSessionManager.swift
//  WorkoutTracker
//
//  Created by Sarah Olson on 11/24/16.
//  Copyright © 2016 SarahEOlson. All rights reserved.
//

import Foundation
import HealthKit

class WorkoutSessionManager {
    
    class var sharedInstance: WorkoutSessionManager {
        struct Singleton {
            static let instance = WorkoutSessionManager()
        }
        return Singleton.instance
    }

    var workoutSession: HKWorkoutSession? = nil
}
