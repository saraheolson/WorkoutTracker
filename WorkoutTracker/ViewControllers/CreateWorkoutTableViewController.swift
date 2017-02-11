//
//  CreateWorkoutTableViewController.swift
//  WorkoutTracker
//
//  Created by SarahEOlson on 9/25/16.
//  Copyright © 2016 SarahEOlson. All rights reserved.
//

import UIKit

class CreateWorkoutTableViewController: UITableViewController {

    var exercises: [Exercise] = WorkoutManager().getWorkout()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "StartWorkout" {
            guard let destinationVC = segue.destination as? CurrentWorkoutViewController else {
                return
            }
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                let selectedExercise = exercises[selectedIndexPath.row]
                destinationVC.currentExercise = selectedExercise
            }
        } else if segue.identifier == "AddExercise" {

            guard let destinationVC = segue.destination as? AddExerciseViewController else {
                return
            }
            destinationVC.exerciseDelegate = self
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseCell", for: indexPath)
        let exercise = exercises[indexPath.row]
        cell.textLabel?.text = exercise.exerciseName
        cell.detailTextLabel?.text = "Duration: \(exercise.duration)"
        return cell
    }
}

extension CreateWorkoutTableViewController: ExerciseDelegate {
    
    func didReceiveNewExercise(exercise: Exercise) {
        exercises.append(exercise)
        
        tableView.reloadData()
    }
}
