//
//  WorkoutManager.swift
//  WorkoutTracker
//
//  Created by Sarah Olson on 11/21/16.
//  Copyright © 2016 SarahEOlson. All rights reserved.
//

import Foundation

struct WorkoutManager {
    
    var exercises: [Exercise] = [ Exercise(exerciseName: "Push-ups", duration: 30),
                                  Exercise(exerciseName: "Squats", duration: 30),
                                  Exercise(exerciseName: "Lunges", duration: 30)]
    var currentWorkout: [Exercise]? = nil
    
    func getWorkout() -> [Exercise] {
        return exercises
    }
}
