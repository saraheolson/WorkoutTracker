//
//  InterfaceController.swift
//  WorkoutTracker WatchKit Extension
//
//  Created by Sarah Olson on 2/18/17.
//  Copyright © 2017 HPlus. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet var heartImage: WKInterfaceImage!
    @IBOutlet var heartRateLabel: WKInterfaceLabel!
    @IBOutlet var workoutButton: WKInterfaceButton!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    @IBAction func startOrStopWorkout() {
        print("Start or Stop Workout")
    }
}
