//
//  JoinDescriptionViewModel.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 9/12/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import Foundation

final class JoinDescriptionViewModel {
    let challenge: Challenge
    
    init(challenge: Challenge) {
        self.challenge = challenge
    }
    
    func numberOfRows(in section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else {
            return challenge.rounds[section - 1].exercises.count
        }
    }
}
