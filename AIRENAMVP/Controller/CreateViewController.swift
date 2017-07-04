//
//  ViewController.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 6/21/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import AudioToolbox
import UIKit
import FocusMotion
import FocusMotionAppleWatch

enum AnalysisType: Int {
    case quant
    case freestyle
    case freestypePlus
    case activityPlus
}

class CreateViewController: UIViewController, FMDeviceDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    private var device: FMDevice!
    private var freestyleModel: FMFreestyleModel!
    private var activityPlusModel: FMActivityPlusModel!
    private var analyzer: FMMovementAnalyzer!
    private var timer: Timer!
    private var recordTimer: Timer?
    private var countdownTimer: Timer?
    private var quantMovements: [FMMovement] = []
    private var prevResults: Int = 0
    private var prevReps: Int = 0
    private var currentCountdownValue: Int = 0
    
    @IBOutlet weak var analyzerPicker: UIPickerView!
    @IBOutlet weak var timerPicker: UIPickerView!
    @IBOutlet weak var movementPicker: UIPickerView!
    @IBOutlet weak var analyzerLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var movementLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var resultsLabel: UILabel!
    @IBOutlet weak var avgHR: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    
    @IBAction func connectPressed(_ sender: UIButton) {
        if device != nil {
            if device.connected {
                device.disconnect()
            }
            else {
                device.connect()
            }
        }
        
        updateConnectButton()
    }
    
    @IBAction func startPressed(_ sender: UIButton) {
        if device != nil {
            if device.recording {
                device.stopRecording()
            }
            else {
                device.startRecording()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Init FocusMotion SDK
        let config = FMConfig()
        
        // Setup the secret API key
        guard FMFocusMotion.startup(config, apiKey: "EQZjg7s9xf4Mk83gvCYngxBBTuhZg8eV") else { fatalError("Could not initialize the Focus Motion") }
        
        /// Init general device support
        FMDevice.startup()
        FMDevice.add(self)
        
        /// Init Apple Watch support
        FMAppleWatchDevice.startup(nil)
        
        /// Load freestyle model
        freestyleModel = FMFreestyleModel()
        freestyleModel.load()
        
        /// Load Activity+ model
        activityPlusModel = FMActivityPlusModel()
        activityPlusModel.load()
        
        /// Load Jay's exercises 
        if let jumpingJack = FMMovement.findSdkMovement("jumpingjacks") { quantMovements.append(jumpingJack) }
        if let pushups = FMMovement.findSdkMovement("pushups") { quantMovements.append(pushups) }
        if let situps = FMMovement.findSdkMovement("situps") { quantMovements.append(situps) }
        if let barbellsquat = FMMovement.findSdkMovement("barbellsquat") { quantMovements.append(barbellsquat) }
        
        resultsLabel.text = ""
        countdownLabel.text = ""
        updateStatusLabel()
        updateConnectButton()
        updateStartButton()
        updatePickers()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willTerminate), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
    }
    
    @objc private func willTerminate(notification: Notification) {
        FMFocusMotion.shutdown()
    }
    
    private func updateStatusLabel() {
        if device != nil {
            let status = device.connected ? "connected" : "disconnected"
            let name = device.name ?? "No Name"
            statusLabel.text = "\(name): \(status)"
        }
        else {
            statusLabel.text = "No available devices"
        }
    }
    
    private func updateConnectButton() {
        if device != nil {
            if device.connected {
                connectButton.setTitle("Disconnect", for: .normal)
                connectButton.isEnabled = true
            }
            else if device.connecting {
                connectButton.setTitle("Connecting...", for: .normal)
                connectButton.isEnabled = false
            }
            else {
                connectButton.setTitle("Connect", for: .normal)
                connectButton.isEnabled = true
            }
        }
        else {
            connectButton.setTitle("Connect", for: .normal)
            connectButton.isEnabled = false
        }
    }
    
    private func updateStartButton() {
        if device != nil && device.connected {
            let title = device.recording ? "Stop" : "Start"
            startButton.isEnabled = true
            startButton.setTitle(title, for: .normal)
        }
        else {
            startButton.isEnabled = false
        }
    }
    
    private func analysisType() -> AnalysisType {
        guard let type = AnalysisType(rawValue: analyzerPicker.selectedRow(inComponent: 0)) else { return .quant }
        return type
    }
    
    private func updatePickers() {
        /// Disable picker movement when using Quant or when recording
        let movementPickerEnabled = analysisType() == .quant && analyzer == nil
        movementPicker.isUserInteractionEnabled = movementPickerEnabled
        movementPicker.alpha = movementPickerEnabled ? 1.0 : 0.2
        movementLabel.alpha = movementPickerEnabled ? 1.0 : 0.2
        
        /// Disable analyzer picker when recording
        let analyzerPickerEnabled = analyzer == nil
        analyzerPicker.isUserInteractionEnabled = analyzerPickerEnabled
        analyzerPicker.alpha = analyzerPickerEnabled ? 1.0 : 0.2
        analyzerLabel.alpha = analyzerPickerEnabled ? 1.0 : 0.2
        
        /// Disable analyzer picker when recording
        let timerPickerEnabled = analyzer == nil
        timerPicker.isUserInteractionEnabled = timerPickerEnabled
        timerPicker.alpha = timerPickerEnabled ? 1.0 : 0.2
        timerLabel.alpha = timerPickerEnabled ? 1.0 : 0.2
    }
    
    private func showQuantOrFreestyleResults() {
        if let results = analyzer?.results, !results.isEmpty {
            let result = results.first!
            
            resultsLabel.text = "\n"
                + "\(result.movement.displayName) \n"
                + "\(result.repCount) reps \n"
                + "duration: \(result.duration) \n"
                + "mean rep time: \(result.meanRepDuration) \n"
                + "variation between reps: \(result.internalVariation) \n"
                + "variation from reference: \(result.idealVariation) \n"
                + "mean angular range: \(result.meanAngle)"
            
            if result.repCount > prevReps {
                AudioServicesPlaySystemSound(1057)
                prevReps = result.repCount
            }
        }
        else {
            resultsLabel.text = "analyzing..."
        }
    }
    
    private func showFreestylePlusResults() {
        if let results = analyzer?.results, !results.isEmpty {
            var fullText = ""
            
            for result in results {
                fullText.append("\(result.movement.displayName), \(result.repCount) reps, \(result.duration) \n")
            }
            
            resultsLabel.text = fullText
            
            if results.count > prevResults {
                prevResults = results.count
                prevReps = 0
            }
            else {
                let lastResult = results.last!
                if lastResult.repCount > prevReps {
                    AudioServicesPlaySystemSound(1057)
                    prevReps = lastResult.repCount
                }
            }
        }
        else {
            resultsLabel.text = "analyzing..."
        }
    }
    
    private func showActivityPlusResults() {
        if let results = analyzer?.results, !results.isEmpty {
            var fullText = ""
            
            for result in results {
                fullText.append("\(result.movement.displayName), \(result.duration) \n")
            }
            
            resultsLabel.text = fullText
            
            if results.count > prevResults {
                AudioServicesPlaySystemSound(1057)
                prevResults = results.count
            }
        }
        else {
            resultsLabel.text = "analyzing..."
        }
    }
    
    private func nextDevice(dev: FMDevice) {
        let availableDevices = FMDevice.availableDevices()
        guard !availableDevices.isEmpty else { device = nil; return }
        
        var index = availableDevices.index(where: { ($0.identifier ?? "") == (dev.identifier ?? "") }) ?? 0
        
        /// next devices index
        index = index.advanced(by: 1)
        index = index % availableDevices.count
        
        /// Setup device as next one
        device = availableDevices[index]
    }
    
    private func createRecordTimer() {
        let pickedTimerRow = timerPicker.selectedRow(inComponent: 0)
        guard pickedTimerRow != 0 else { return }
        let deadline: TimeInterval = Double(pickedTimerRow * 10)
        self.currentCountdownValue = pickedTimerRow * 10
        
        recordTimer = Timer.scheduledTimer(timeInterval: deadline, target: self, selector: #selector(completeRecord), userInfo: nil, repeats: false)
        countdownTimer = Timer.init(timeInterval: 1, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
        RunLoop.main.add(countdownTimer!, forMode: .defaultRunLoopMode)
    }
    
    @objc private func onTimer(aTimer: Timer) {
        analyzer.analyze(device.output)
        
        switch analysisType() {
        case .quant, .freestyle: showQuantOrFreestyleResults()
        case .freestypePlus: showFreestylePlusResults()
        case .activityPlus: showActivityPlusResults()
        }
    }
    
    @objc private func completeRecord() {
        if device != nil, device.recording {
            device.stopRecording()
        }
    }
    
    @objc private func updateCountdown() {
        currentCountdownValue = currentCountdownValue.advanced(by: -1)
        
        if currentCountdownValue < 1 {
            countdownLabel.text = "Done"
        }
        else {
            countdownLabel.text = String(currentCountdownValue)
        }
    }
    
    // MARK: FMDeviceDelegate
    func messageReceived(_ device: FMDevice, message: Data) {
        DispatchQueue.main.async { [weak self] in
            let hrStr = String(data: message, encoding: String.Encoding.utf8)
            self?.avgHR.text = hrStr ?? "No Data"
        }
    }
    
    func availableChanged(_ device: FMDevice, available: Bool) {
        if available && self.device == nil {
            self.device = device
        }
        
        if !available && self.device == device {
            self.device = FMDevice.availableDevices().first
        }
        
        updateConnectButton()
        updateStatusLabel()
    }
    
    func connectedChanged(_ device: FMDevice, connected: Bool) {
        if connected {
            device.sendMessage("Full Demo".data(using: .utf8)!)
        }
        else {
            nextDevice(dev: device)
        }
        
        updateConnectButton()
        updateStartButton()
        updateStatusLabel()
        resultsLabel.text = ""
    }
    
    func recordingChanged(_ device: FMDevice, recording: Bool) {
        updateStartButton()
        
        if recording {
            resultsLabel.text = ""
            avgHR.text = ""
            prevReps = 0
            prevResults = 0
            
            let movementRow = movementPicker.selectedRow(inComponent: 0)
            let movement = quantMovements[movementRow]
            
            createRecordTimer()
            
            switch analysisType() {
            case .quant: analyzer = FMMovementAnalyzer.newQuantAnalyzer(movement)
            case .freestyle: analyzer = FMMovementAnalyzer.newFreestyleAnalyzer(freestyleModel)
            case .freestypePlus: analyzer = FMMovementAnalyzer.newFreestylePlusAnalyzer(freestyleModel)
            case .activityPlus: analyzer = FMMovementAnalyzer.newActivityPlusAnalyzer(activityPlusModel)
            }
            
            analyzer.start()
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(onTimer(aTimer:)), userInfo: nil, repeats: true)
        }
        else {
            timer?.invalidate()
            recordTimer?.invalidate()
            countdownTimer?.invalidate()
            analyzer?.stop()
            
            if let results = analyzer?.results, results.isEmpty {
                resultsLabel.text = ""
                avgHR.text = ""
            }
            
            analyzer = nil
        }
        
        updatePickers()
    }
    
    func connectionFailed(_ device: FMDevice, error: Error) {
        nextDevice(dev: device)
        
        updateConnectButton()
        updateStatusLabel()
        
        let alert = UIAlertController(title: "Connection Failed", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    /// MARK: - UIPickerViewDelegate & Datasource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == movementPicker { return quantMovements.count }
        else if pickerView == timerPicker { return 7 }
        else { return 4 }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let labelView: UILabel
        
        if view is UILabel {
            labelView = view as! UILabel
        }
        else {
            labelView = UILabel()
            labelView.font = UIFont.systemFont(ofSize: 12)
            labelView.textAlignment = .center
        }
        
        let title: String
        
        if pickerView == movementPicker {
            title = quantMovements[row].displayName
        }
        else if pickerView == timerPicker {
            title = timerPickerTitle(for: row)
        }
        else {
            title = analyzerPickerTitle(for: row)
        }
        
        labelView.text = title
        labelView.sizeToFit()
        
        return labelView
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == analyzerPicker {
            updatePickers()
        }
    }
    
    private func analyzerPickerTitle(for row: Int) -> String {
        let type = AnalysisType(rawValue: row) ?? .quant
        switch type {
        case .quant: return "Quant"
        case .freestyle: return "Freestyle"
        case .freestypePlus: return "FreestylePlus"
        case .activityPlus: return "ActivityPlus"
        }
    }
    
    private func timerPickerTitle(for row: Int) -> String {
        switch row {
        case 0: return "No Time"
        case 1: return "10 Seconds"
        case 2: return "20 Seconds"
        case 3: return "30 Seconds"
        case 4: return "40 Seconds"
        case 5: return "50 Seconds"
        default: return "60 Seconds"
        }
    }
}
