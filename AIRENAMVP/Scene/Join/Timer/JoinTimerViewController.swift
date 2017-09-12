//
//  JoinTimerViewController.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 9/11/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import UIKit
import AVFoundation

final class JoinTimerViewController: UIViewController {
    var viewModel = JoinTimerViewModel()
    var timer: Timer!
    
    let synthesizer = AVSpeechSynthesizer()
    
    /// Vars for timers
    var initTimerCount = 3
    var timerCount = 0
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var initCountdown: UILabel!
    @IBOutlet weak var initBackgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
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
            synthesizerSetup(for: state)
            timerCount = state.time
            bgView.backgroundColor = state.color
            name.text = state.title
            time.text = String(state.time)
            dump(state)
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerHandler(timer:)), userInfo: nil, repeats: true)
        }
        else {
            pronounce(text: "Congratulations! You've done it!")
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
}
