//
//  JoinTimerViewModel.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 9/11/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import Foundation

import FocusMotion
import SwiftyJSON

final class JoinTimerViewModel {
    let challenge: Challenge
    var metrics: TimerChallengeMetrics
    
    var currentRoundIndex: Int = 0
    var currentRoundRepIndex: Int = 0
    var currentExerciseIndex: Int = 0
    var isCurrentWork = true
    
    init(challenge: Challenge) {
        self.challenge = challenge
        self.metrics = TimerChallengeMetrics(with: challenge)
    }
    
    func next() -> JoinTimer.State? {
        guard currentRoundIndex < challenge.rounds.count else { return nil }
        
        let round = challenge.rounds[currentRoundIndex]
        let roundTitle = round.title
        let exercise = round.exercises[currentExerciseIndex]
        let title = "Round: " + roundTitle + " - " + String(currentRoundRepIndex + 1) + " rep" + "\n" + exercise.name
        let time = isCurrentWork ? exercise.executionNumber : exercise.rest
        let color = isCurrentWork ? UIColor.blue : UIColor.green
        let mov: FMMovement? = isCurrentWork ? FMMovement.findSdkMovement(exercise.movement) : nil
        debugPrint("exercise: ", exercise.movement)
        
        let state = JoinTimer.State(title: title, time: time, color: color, isWork: isCurrentWork, exerciseName: exercise.name, movement: mov)
        
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
    
    func storeMetrics(result: FMAnalyzerResult?) {
        guard let res = result else { return }
        metrics
            .rounds[currentRoundIndex]
            .exercise[currentExerciseIndex]
            .append(result: res)
        
//        sendMetrics(res: res)
    }
    
    func sendMetrics(res: FMAnalyzerResult) {
        let exercise = challenge.rounds[currentRoundIndex].exercises[currentExerciseIndex]
        let params: [String : Any] = [
            "title" : exercise.name,
            "duration" : res.duration,
            "repetition" : res.repCount,
            "meanAngularRange" : res.meanAngle,
            "meanRepTime" : res.meanRepDuration,
            "variationBetweenReps" : res.internalVariation,
            "variationFromReference" : res.idealVariation,
            "exercises" : Array([
                "movementName" : exercise.movement,
                "name" : exercise.name,
                "rest" : exercise.rest,
                "work" : exercise.executionNumber
            ])
        ]
        
//        API.submitChallenge(with: <#T##String#>, and: <#T##String#>, params: <#T##Parameters#>, availability: <#T##Bool#>)
    }
}

struct JoinTimer {
    struct State {
        let title: String
        let time: Int
        let color: UIColor
        
        let isWork: Bool
        let exerciseName: String
        
        let movement: FMMovement?
    }
}

struct TimerChallengeMetrics {
    struct Round {
        struct Exercise {
            let title: String
            var repetition: Int = 0
            var duration: Float = 0
            var meanAngularRange: Float = 0
            var meanRepTime: Float = 0
            var variationBetweenReps: Float = 0
            var variationFromReference: Float = 0
            
            init(with title: String) {
                self.title = title
            }
            
            mutating func append(result: FMAnalyzerResult) {
                repetition += result.repCount
                duration += result.duration
                meanAngularRange = (result.meanAngle + meanAngularRange) / 2
                meanRepTime = (result.meanRepDuration + meanRepTime) / 2
                variationBetweenReps = (result.internalVariation + variationBetweenReps) / 2
                variationFromReference = (result.idealVariation + variationFromReference) / 2
            }
        }
        
        var exercise: [Round.Exercise] = []
    }
    
    var rounds: [TimerChallengeMetrics.Round] = []
    
    init(with challenge: Challenge) {
        for (roundIndex, round) in challenge.rounds.enumerated() {
            rounds.append(TimerChallengeMetrics.Round())
            for exercise in round.exercises {
                rounds[roundIndex].exercise.append(TimerChallengeMetrics.Round.Exercise(with: exercise.name))
            }
        }
    }
}
