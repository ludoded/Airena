//
//  JoinTimerViewModel.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 9/11/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import Foundation
import SwiftyJSON

final class JoinTimerViewModel {
    let challenge: Challenge
    
    var currentRoundIndex: Int = 0
    var currentRoundRepIndex: Int = 0
    var currentExerciseIndex: Int = 0
    var isCurrentWork = true
    
    init(challenge: Challenge) {
        self.challenge = challenge
    }
    
    func next() -> JoinTimer.State? {
        guard currentRoundIndex < challenge.rounds.count else { return nil }
        
        let round = challenge.rounds[currentRoundIndex]
        let roundTitle = round.title
        let exercise = round.exercises[currentExerciseIndex]
        let title = "Round: " + roundTitle + " - " + String(currentRoundRepIndex + 1) + " rep" + "\n" + exercise.name
        let time = isCurrentWork ? exercise.executionNumber : exercise.rest
        let color = isCurrentWork ? UIColor.blue : UIColor.green
        
        let state = JoinTimer.State(title: title, time: time, color: color, isWork: isCurrentWork, exerciseName: exercise.name)
        
        /// Post setup
        
        /// Change the isWork State
        isCurrentWork = !isCurrentWork
        
        /// If current isWork == true, then check if there is next exercise within the Round
        if isCurrentWork {
            currentExerciseIndex += 1
            
            if currentExerciseIndex >= challenge.rounds[currentRoundIndex].exercises.count {
                currentExerciseIndex = 0 /// Reset to first exercise in the round
                currentRoundRepIndex += 1 /// Check if there is more reps for the round
                
                if currentRoundRepIndex >= challenge.rounds[currentRoundIndex].repetition {
                    currentRoundRepIndex = 0 /// Reset to first rep in the round
                    currentRoundIndex += 1 /// Increase the counter to the next round
                }
            }
        }
        
        return state
    }
}

struct JoinTimer {
    struct State {
        let title: String
        let time: Int
        let color: UIColor
        
        let isWork: Bool
        let exerciseName: String
    }
}
