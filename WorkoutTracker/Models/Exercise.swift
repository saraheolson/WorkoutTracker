//
//  Exercise.swift
//  WorkoutTracker
//
//  Created by SarahEOlson on 9/25/16.
//  Copyright © 2016 SarahEOlson. All rights reserved.
//

import Foundation

struct Exercise {
    
    var exerciseName: String
    var duration: Int8
    
    init(exerciseName: String, duration: Int8) {
        self.exerciseName = exerciseName
        self.duration = duration
    }
}
