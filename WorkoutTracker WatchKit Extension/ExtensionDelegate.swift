//
//  ExtensionDelegate.swift
//  WorkoutTracker WatchKit Extension
//
//  Created by SarahEOlson on 9/25/16.
//  Copyright © 2016 SarahEOlson. All rights reserved.
//

import WatchKit
import WatchConnectivity
import HealthKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompleted()
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompleted()
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompleted()
            default:
                // make sure to complete unhandled task types
                task.setTaskCompleted()
            }
        }
    }
    
    func handle(_ workoutConfiguration: HKWorkoutConfiguration) {
        
        // display workout on watch
        print("Workout Configuration: \(workoutConfiguration.activityType)")
        
        do {
            let session = try HKWorkoutSession(configuration: workoutConfiguration)
            WorkoutSessionManager.sharedInstance.workoutSession = session
            
            HKHealthStore().start(session)
        } catch let error as NSError {
            print("Error creating workout session: \(error.localizedDescription)")
        }
    }
}
//
//// MARK: - Watch Connectivity
//extension ExtensionDelegate: WCSessionDelegate {
//    
//    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
//        if let error = error {
//            print("WC Session activation failed with error: \(error.localizedDescription)")
//            return
//        }
//        print("WC Session activated with state: \(activationState.rawValue)")
//    }
//    
//    func setupWatchConnectivity() {
//        if WCSession.isSupported() {
//            let session  = WCSession.default()
//            session.delegate = self
//            session.activate()
//        }
//    }
//    
//    // 1
//    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
////        // 2
////        if let movies = applicationContext["movies"] as? [String] {
////            // 3
////            TicketOffice.sharedInstance.purchaseTicketsForMovies(movies)
////            // 4
////            DispatchQueue.main.async(execute: {
////                WKInterfaceController.reloadRootControllers(
////                    withNames: ["PurchasedMovieTickets"], contexts: nil)
////            })
////        }
//    }
//    
//    func sendWorkoutToPhone(_ notification:Notification) {
//        if WCSession.isSupported() {
////            if let movies =
////                TicketOffice.sharedInstance.purchasedMovieTicketIDs() {
////                // 3
////                do {
////                    let dictionary = ["movies": movies]
////                    try WCSession.default().updateApplicationContext(dictionary)
////                } catch {
////                    print("ERROR: \(error)")
////                }
////            }
//        }
//    }
//}
