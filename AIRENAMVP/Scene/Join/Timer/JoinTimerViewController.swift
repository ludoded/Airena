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
    fileprivate let fm = FMSettings.shared
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = JoinTimerViewModel(challenge: challenge)
        fmSetup()
        initialSetup()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willTerminate), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        destruct()
    }
    
    func destruct() {
        timer?.invalidate()
        analyzerTimer?.invalidate()
        fm.device.stopRecording()
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
    
    func initialSetup() {
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
                fm.device.startRecording()
            }
            else {
                fm.device.stopRecording()
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
        analyzer.analyze(fm.device.output)
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
    
    private func fmSetup() {
        fm.messageReceivedCallback = { [weak self] m in
            DispatchQueue.main.async { [weak self] in
                let hrStr = String(data: m, encoding: String.Encoding.utf8)
                //            self?.avgHR.text = hrStr ?? "No Data"
            }
        }
        
        fm.connectedChangesCallback = { [weak self] c in
            if c {
                self?.fm.device.sendMessage("Full Demo".data(using: .utf8)!)
            }
        }
        
        fm.recordingChangedCallback = { [weak self] recording in
            guard let wSelf = self else { return }
            if recording,
                let state = wSelf.currentState,
                let movement = state.movement {
                
                wSelf.analyzer = FMMovementAnalyzer.newQuantAnalyzer(movement)
                wSelf.analyzer.start()
                wSelf.analyzerTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                     target: wSelf,
                                                     selector: #selector(wSelf.onTimer(aTimer:)),
                                                     userInfo: nil,
                                                     repeats: true)
            }
            else {
                wSelf.biometrics.text = "Resting..."
                wSelf.analyzer?.stop()
                wSelf.analyzerTimer?.invalidate()
            }
        }
    }
}
