//
//  ExtensionDelegate.swift
//  AIRENAMVP WatchKit Extension
//
//  Created by Haik Ampardjian on 6/21/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import WatchKit
import FocusMotion
import FocusMotionAppleWatch
import HealthKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    var healthStore: HKHealthStore!
    var session: HKWorkoutSession!
    
    func applicationDidFinishLaunching() {
        let config = FMConfig()
        FMFocusMotion.startup(config, apiKey: "EQZjg7s9xf4Mk83gvCYngxBBTuhZg8eV")
        FMLocalDevice.startup(nil)
        
        healthStore = HKHealthStore()
    }
    
    func handle(_ workoutConfiguration: HKWorkoutConfiguration) {
        do {
            session = try HKWorkoutSession(configuration: workoutConfiguration)
            healthStore.start(session)
        }
        catch let error {
            assertionFailure("Unable to create the workout session: \(error.localizedDescription)")
        }
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

}
