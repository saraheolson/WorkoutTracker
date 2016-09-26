//
//  AddExerciseViewController.swift
//  WorkoutTracker
//
//  Created by SarahEOlson on 9/25/16.
//  Copyright © 2016 SarahEOlson. All rights reserved.
//

import UIKit

protocol ExerciseDelegate {
    func didReceiveNewExercise(exercise: Exercise)
}

class AddExerciseViewController: UIViewController {

    @IBOutlet var exerciseNameField: UITextField!
    @IBOutlet var exerciseDurationField: UITextField!
    
    var exerciseDelegate: ExerciseDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func tappedSaveButton(_ sender: AnyObject) {
        
        guard let exerciseName = exerciseNameField.text,
            let durationString = exerciseDurationField.text,
            let duration = Int8(durationString) else {
         
            return
        }
        
        let newExercise = Exercise(exerciseName: exerciseName, duration: duration)
        exerciseDelegate?.didReceiveNewExercise(exercise: newExercise)
        
        
        // Underscore tells the compiler to discard this result
        _ = navigationController?.popViewController(animated: true)
    }
}
