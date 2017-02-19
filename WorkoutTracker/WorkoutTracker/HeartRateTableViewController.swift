//
//  HeartRateTableViewController.swift
//  WorkoutTracker
//
//  Created by Sarah Olson on 2/19/17.
//  Copyright © 2017 HPlus. All rights reserved.
//

import UIKit

class HeartRateTableViewController: UITableViewController {

    let healthKitManager = HealthKitManager.sharedInstance

    var heartRateData: [String] = ["63", "87"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        healthKitManager.authorizeHealthKitAccess { (success, error) in
            print("HealthKit authorized? \(success)")
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return heartRateData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "heartRate", for: indexPath)
        cell.textLabel?.text = heartRateData[indexPath.row]
        return cell
    }
}
