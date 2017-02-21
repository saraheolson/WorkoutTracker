//
//  HeartRateTableViewController.swift
//  WorkoutTracker
//
//  Created by Sarah Olson on 2/19/17.
//  Copyright © 2017 HPlus. All rights reserved.
//

import UIKit
import HealthKit

class HeartRateTableViewController: UITableViewController {

    let healthKitManager = HealthKitManager.sharedInstance

    var heartRateData: [HKQuantitySample] = []
    
    var heartRateQuery : HKQuery?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        healthKitManager.authorizeHealthKitAccess { [weak self] (success, error) in
            print("HealthKit authorized? \(success)")
            self?.retrieveHeartRateData()
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
        
        let heartRate = heartRateData[indexPath.row].quantity
        cell.textLabel?.text = "\(heartRate)"
        return cell
    }
    
    func retrieveHeartRateData() {
        
        if let query = healthKitManager.createHeartRateStreamingQuery(Date()) {
            self.heartRateQuery = query
            healthKitManager.heartRateDelegate = self
            healthKitManager.healthStore.execute(query)
        } else {
            print("Cannot create heart rate query.")
        }
    }
}

extension HeartRateTableViewController: HeartRateDelegate {
    
    func heartRateUpdated(heartRateSamples: [HKSample]) {
        
        guard let heartRateSamples = heartRateSamples as? [HKQuantitySample] else {
            return
        }
        
        DispatchQueue.main.async {
            
            for sample in heartRateSamples {
                self.heartRateData.append(sample)
            }
            print("Heart rate data: \(self.heartRateData)")
            self.tableView.reloadData()
        }
    }
}
