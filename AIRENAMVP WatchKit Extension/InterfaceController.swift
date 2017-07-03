//
//  InterfaceController.swift
//  AIRENAMVP WatchKit Extension
//
//  Created by Haik Ampardjian on 6/21/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import WatchKit
import Foundation
import FocusMotionAppleWatch
import HealthKit

class InterfaceController: WKInterfaceController, FMLocalDeviceDelegate {
    private var wkDelegate: ExtensionDelegate!
    private let heartRateUnit = HKUnit(from: "count/min")
    private var currentQuery: HKQuery?
    private var hrSamples: [HKSample] = []
    
    @IBOutlet weak var recordingSwitch: WKInterfaceSwitch!
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    
    @IBAction func recordingSwitchChanged(on: Bool) {
        if on { FMLocalDevice.instance()?.startRecording() }
        else { FMLocalDevice.instance()?.stopRecording() }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        FMLocalDevice.instance()?.deviceDelegate = self
        wkDelegate = WKExtension.shared().delegate as! ExtensionDelegate
        setupHR()
    }
    
    override func didAppear() {
        super.didAppear()
        updateDisplay()
    }
    
    override func willActivate() {
        super.willActivate()
        updateDisplay()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func setupHR() {
        guard HKHealthStore.isHealthDataAvailable() else {
            debugPrint("Health Data is not available")
            return
        }
        
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
            debugPrint("Heart Rate quantity type is not available")
            return
        }
        
        let dataTypes = Set(arrayLiteral: quantityType)
        wkDelegate.healthStore.requestAuthorization(toShare: nil, read: dataTypes) { (success, error) in
            guard success else {
                debugPrint(error?.localizedDescription ?? "")
                debugPrint("Heart Rate is not authorized")
                return
            }
        }
    }
    
    func createHeartRateStreamingQuery(date: Date) -> HKQuery? {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else { return nil }
        let datePredicate = HKQuery.predicateForSamples(withStart: date, end: nil, options: HKQueryOptions.strictEndDate)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate])
        
        let heartRateQuery = HKAnchoredObjectQuery(type: quantityType, predicate: predicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { [weak self] (query, sampleObjects, deletedObjects, newAnchor, error) in
            if let samples = sampleObjects {
                self?.hrSamples.append(contentsOf: samples)
            }
        }
        
        heartRateQuery.updateHandler = { [weak self] (query, sampleObjects, deleteObjects, newAnchor, error) in
            if let samples = sampleObjects {
                self?.hrSamples.append(contentsOf: samples)
            }
        }
        
        return heartRateQuery
    }
    
    func updateDisplay() {
        let device = FMLocalDevice.instance()!
        
        recordingSwitch.setHidden(!device.connected)
        recordingSwitch.setOn(device.recording)
    }
    
    func sendHR() {
        guard !hrSamples.isEmpty, let samples = hrSamples as? [HKQuantitySample] else { return }
        let doubles = samples.map { $0.quantity.doubleValue(for: heartRateUnit) }
        let min = String(doubles.min() ?? 0)
        let max = String(doubles.max() ?? 0)
        let reduced = doubles.reduce(0, +)
        let average = reduced / Double(samples.count)
        debugPrint("Average: \(average)")
        
        let messageString = "Average Heart Rate: \(average) \n Heart Rate range: min -> \(min) --- max -> \(max)"
        if let messageData = messageString.data(using: String.Encoding.utf8) {
            FMLocalDevice.instance()?.sendMessage(messageData)
        }
        
        /// Remove all samples
        hrSamples.removeAll()
    }
    
    // MARK: - FMLocalDeviceDelegate
    func connectedChanged(_ device: FMLocalDevice, connected: Bool) {
        updateDisplay()
    }
    
    func recordingChanged(_ device: FMLocalDevice, recording: Bool) {
        updateDisplay()
        WKInterfaceDevice.current().play(recording ? .start : .stop)
        
        /// Start or stop observing heart rate
        if recording {
            if let query = createHeartRateStreamingQuery(date: Date()) {
                self.currentQuery = query
                wkDelegate.healthStore.execute(query)
            }
            else {
                debugPrint("Can't start")
            }
        }
        else {
            wkDelegate.healthStore.stop(currentQuery!)
            sendHR()
        }
    }
    
    func messageReceived(_ device: FMLocalDevice, message: Data) {
        let str = String(data: message, encoding: .utf8)
        titleLabel.setText(str)
    }
}
