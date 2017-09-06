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
