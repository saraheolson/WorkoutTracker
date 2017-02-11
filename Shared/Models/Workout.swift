//
//  Workout.swift
//  WorkoutTracker
//
//  Created by Sarah Olson on 11/27/16.
//  Copyright © 2016 SarahEOlson. All rights reserved.
//

import Foundation

class Workout {
    
    var name: String
    var activeTime: TimeInterval
    var restTime: TimeInterval
    
    fileprivate let nameKey = "com.saraheolson.workout.exerciseType"
    fileprivate let activeTimeKey = "com.saraheolson.workout.activeTime"
    fileprivate let restTimeKey = "com.saraheolson.workout.restTime"
    
    init(name: String, activeTime: TimeInterval = 120, restTime: TimeInterval = 30) {
        self.name = name
        self.activeTime = activeTime
        self.restTime = restTime
    }
    
    init(withDictionary rawDictionary:[String : Any]) {
        
        if let name = rawDictionary[nameKey] as? String {
            self.name = name
        } else {
            self.name = "Unnamed Excercise"
        }
        
        if let active = rawDictionary[activeTimeKey] as? TimeInterval {
            self.activeTime = active
        } else {
            self.activeTime = 120
        }
        
        if let rest = rawDictionary[restTimeKey] as? TimeInterval {
            self.restTime = rest
        } else {
            self.restTime = 30
        }
    }
    
    func intervalDuration() -> TimeInterval {
        return activeTime + restTime
    }
    
    func dictionaryRepresentation() -> [String : Any] {
        return [
            nameKey : name,
            activeTimeKey : activeTime,
            restTimeKey : restTime,
        ]
    }
}
