//
//  JoinTimerViewController.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 9/11/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import UIKit
import AVFoundation
import FocusMotion
import FocusMotionAppleWatch

final class JoinTimerViewController: UIViewController {
    fileprivate var device: FMDevice!
    fileprivate var analyzer: FMMovementAnalyzer!
    fileprivate var analyzerTimer: Timer!
    
    fileprivate var currentState: JoinTimer.State?
    
    var challenge: Challenge!
    var viewModel: JoinTimerViewModel!
    var timer: Timer!
    
    let synthesizer = AVSpeechSynthesizer()
    
    /// Vars for timers
    var initTimerCount = 3
    var timerCount = 0
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var biometrics: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var initCountdown: UILabel!
    @IBOutlet weak var initBackgroundView: UIView!
    
    @IBOutlet weak var onboardingView: UIView!
    @IBOutlet weak var connectButton: AirenaButton!
    @IBOutlet weak var startButton: AirenaButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBAction func connect(_ sender: UIButton) {
        
    }
    
    @IBAction func start(_ sender: UIButton) {
        initialSetup()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = JoinTimerViewModel(challenge: challenge)
        fmSetup()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willTerminate), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        destruct()
    }
    
    func destruct() {
        timer?.invalidate()
        analyzerTimer?.invalidate()
        device.stopRecording()
    }
    
    func synthesizerSetup(for state: JoinTimer.State) {
        var str = ""
        if !state.isWork {
            str = "Rest for \(state.time) seconds"
        }
        else {
            str = "Do \(state.exerciseName) for \(state.time) seconds"
        }
        
        pronounce(text: str)
    }
    
    func pronounce(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        synthesizer.speak(utterance)
    }
    
    func fmSetup() {
        FMDevice.add(self)
    }
    
    func initialSetup() {
        onboardingView.isHidden = true
        bgView.backgroundColor = .lightGray
        initCountdown.text = String(initTimerCount)
        pronounce(text: "Get Ready")
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerHandlerInit(timer:)), userInfo: nil, repeats: true)
    }
    
    func nextStep() {
        if let state = viewModel.next() {
            currentState = state
            synthesizerSetup(for: state)
            timerCount = state.time
            bgView.backgroundColor = state.color
            name.text = state.title
            time.text = String(state.time)
            dump(state)
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerHandler(timer:)), userInfo: nil, repeats: true)
            
            if state.isWork {
                device.startRecording()
            }
            else {
                device.stopRecording()
            }
        }
        else {
            currentState = nil
            pronounce(text: "Congratulations! You've done it!")
            performSegue(withIdentifier: "showCongratulations", sender: nil)
        }
    }
    
    @objc
    func timerHandlerInit(timer: Timer) {
        let nextTimerCount = initTimerCount - 1
        initCountdown.text = String(nextTimerCount)
        initTimerCount = nextTimerCount
        
        if nextTimerCount == 0 {
            timer.invalidate()
            initBackgroundView.isHidden = true
            nextStep()
        }
    }
    
    @objc
    func timerHandler(timer: Timer) {
        let nextTimerCount = timerCount - 1
        time.text = String(nextTimerCount)
        timerCount = nextTimerCount
        
        if nextTimerCount == 0 {
            timer.invalidate()
            nextStep()
        }
    }
    
    @objc private func onTimer(aTimer: Timer) {
        analyzer.analyze(device.output)
        showQuantOrFreestyleResults()
    }
    
    @objc private func willTerminate(notification: Notification) {
        destruct()
    }
    
    private func showQuantOrFreestyleResults() {
        if let results = analyzer?.results, !results.isEmpty {
            let result = results.first!
            
            biometrics.text = """
            \n
            \(result.repCount) reps \n
            duration: \(result.duration) \n
            mean rep time: \(result.meanRepDuration) \n
            variation between reps: \(result.internalVariation) \n
            variation from reference: \(result.idealVariation) \n
            mean angular range: \(result.meanAngle)
            """
            
//            if result.repCount > prevReps {
//                AudioServicesPlaySystemSound(1057)
//                prevReps = result.repCount
//            }
        }
        else {
            biometrics.text = "analyzing..."
        }
    }
    
    /// Focus Motion related methods
    
    fileprivate func updateStatusLabel() {
        if device != nil {
            let status = device.connected ? "connected" : "disconnected"
            let name = device.name ?? "No Name"
            statusLabel.text = "\(name): \(status)"
        }
        else {
            statusLabel.text = "No available devices"
        }
    }
    
    fileprivate func updateConnectButton() {
        if device != nil {
            startButton.isEnabled = false
            if device.connected {
                connectButton.setTitle("Disconnect", for: .normal)
                connectButton.isEnabled = true
                startButton.isEnabled = true
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
            startButton.isEnabled = false
        }
    }
    
    fileprivate func updateStartButton() {
        if device != nil && device.connected {
            let title = device.recording ? "Stop" : "Start"
            startButton.isEnabled = true
            startButton.setTitle(title, for: .normal)
        }
        else {
            startButton.isEnabled = false
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

extension JoinTimerViewController: FMDeviceDelegate {
    /// Is used when Heart Rate is sent
    func messageReceived(_ device: FMDevice, message: Data) {
        DispatchQueue.main.async { [weak self] in
            let hrStr = String(data: message, encoding: String.Encoding.utf8)
//            self?.avgHR.text = hrStr ?? "No Data"
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
    }
    
    func recordingChanged(_ device: FMDevice, recording: Bool) {
        if recording,
            let state = currentState,
            let movement = state.movement {
            
            analyzer = FMMovementAnalyzer.newQuantAnalyzer(movement)
            analyzer.start()
            analyzerTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                 target: self,
                                                 selector: #selector(onTimer(aTimer:)),
                                                 userInfo: nil,
                                                 repeats: true)
        }
        else {
            biometrics.text = "Resting..."
            analyzer?.stop()
            analyzerTimer?.invalidate()
        }
    }
    
    func connectionFailed(_ device: FMDevice, error: Error) {
        nextDevice(dev: device)
        
        updateConnectButton()
        updateStatusLabel()
        
        let alert = UIAlertController(title: "Connection Failed", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
