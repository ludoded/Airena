//
//  AddChallengeViewModel.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 9/4/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import Foundation

final class AddChallengeViewModel {
    var challenge: Challenge
    
    var currentRound: Round?
    var currentExercise: Exercise?
    
    init(type: ChallengeType) {
        challenge = Challenge(type: type)
    }
    
    func numberOfRounds() -> Int {
        return challenge.rounds.count + 1
    }
    
    func round(for indexPath: IndexPath) -> Round? {
        let index = indexPath.row
        
        if challenge.rounds.count > index {
            return challenge.rounds[index]
        }
        
        return nil
    }
    
    func title(for indexPath: IndexPath) -> String {
        switch indexPath.row {
        case 0:
            if let date = challenge.startDate {
                return date.toChallengeFormat()
            }
            return ""
        case 1:
            if let date = challenge.endDate {
                return date.toChallengeFormat()
            }
            return ""
        default:
            return ""
        }
    }
}

/// MARK: Round
extension AddChallengeViewModel {
    func initializeCurrentRound() {
        currentRound = Round()
    }
    
    func deinitializeCurrentRound() {
        currentRound = nil
    }
    
    func saveCurrentRound() {
        challenge.rounds.append(currentRound!)
    }
    
    func numberOfExercise() -> Int {
        return (currentRound?.exercises.count ?? 0) + 1
    }
    
    func exercise(for indexPath: IndexPath) -> Exercise? {
        let index = indexPath.row
        
        if currentRound?.exercises.count ?? 0 > index {
            return currentRound?.exercises[index]
        }
        
        return nil
    }
    
    func addExercise(for exerciseName: String, workIndex workTime: Int, restIndex restTime: Int) {
        let exercise = Exercise(name: exerciseName, executionNumber: workTime, executionMeasurement: .duration, rest: restTime)
        currentRound?.exercises.append(exercise)
    }
}

/// MARK: Exercise
extension AddChallengeViewModel {
    func initializeCurrentExercise() {
        currentExercise = Exercise()
    }
    
    func deinitializeCurrentExercise() {
        currentExercise = nil
    }
    
    func saveCurrentExercise() {
        currentRound?.exercises.append(currentExercise!)
    }
}
