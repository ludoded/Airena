//
//  FMSettings.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 10/6/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import Foundation
import FocusMotion
import FocusMotionAppleWatch

final class FMSettings {
    static let shared = FMSettings()
    
    typealias FMMessageReceived = (_ message: Data) -> Void
    typealias FMAvailableChanged = (_ available: Bool) -> Void
    typealias FMConnectedChanges = (_ connected: Bool) -> Void
    typealias FMRecordingChanged = (_ recording: Bool) -> Void
    typealias FMConnectionFailed = (_ error: Error) -> Void
    
    var device: FMDevice!
    
    var messageReceivedCallback: FMMessageReceived?
    var availableChangedCallback: FMAvailableChanged?
    var connectedChangesCallback: FMConnectedChanges?
    var recordingChangedCallback: FMRecordingChanged?
    var connectionFailedCallback: FMConnectionFailed?
    
    private init() {}
    
    func initSetup() {
        /// Init FocusMotion SDK
        let config = FMConfig()
        
        // Setup the secret API key
        guard FMFocusMotion.startup(config, apiKey: "EQZjg7s9xf4Mk83gvCYngxBBTuhZg8eV") else { fatalError("Could not initialize the Focus Motion") }
        
        /// Init general device support
        FMDevice.startup()
        FMDevice.add(self)
        
        /// TODO: check if initing this in other place is better.
        /// Init Apple Watch support
        FMAppleWatchDevice.startup(nil)
    }
    
    func connect() {
        if device != nil {
            if device.connected {
                device.disconnect()
            }
            else {
                device.connect()
            }
        }
    }
    
    fileprivate func nextDevice(dev: FMDevice) {
        let availableDevices = FMDevice.availableDevices()
        guard !availableDevices.isEmpty else { device = nil; return }
        
        var index = availableDevices.index(where: { ($0.identifier ?? "") == (dev.identifier ?? "") }) ?? 0
        
        /// next devices index
        index = index.advanced(by: 1)
        index = index % availableDevices.count
        
        /// Setup device as next one
        device = availableDevices[index]
    }
}

extension FMSettings: FMDeviceDelegate {
    /// Is used when Heart Rate is sent
    func messageReceived(_ device: FMDevice, message: Data) {
        messageReceivedCallback?(message)
    }
    
    func availableChanged(_ device: FMDevice, available: Bool) {
        if available && self.device == nil {
            self.device = device
        }
        
        if !available && self.device == device {
            self.device = FMDevice.availableDevices().first
        }
        
        availableChangedCallback?(available)
    }
    
    func connectedChanged(_ device: FMDevice, connected: Bool) {
        if !connected { nextDevice(dev: device) }
        connectedChangesCallback?(connected)
    }
    
    func recordingChanged(_ device: FMDevice, recording: Bool) {
        recordingChangedCallback?(recording)
    }
    
    func connectionFailed(_ device: FMDevice, error: Error) {
        nextDevice(dev: device)
        connectionFailedCallback?(error)
    }
}
