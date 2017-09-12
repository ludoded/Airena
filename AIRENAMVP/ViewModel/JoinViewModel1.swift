//
//  JoinViewModel.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 7/4/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import Foundation

final class JoinViewModel1 {
    func existingChallenge(for row: Int) -> JoinModel {
        switch row {
        case 0:
            return JoinModel(name: "Pushup challenge",
                             description: "Do as many pushups as you can within 30 seconds.",
                             numberOfParticipants: 376)
        case 1:
            return JoinModel(name: "Jumping Jack challenge",
                             description: "Do as many jacks as you can within 60 seconds.",
                             numberOfParticipants: 205)
        case 2:
            return JoinModel(name: "Burpie challenge",
                             description: "Do as many burpies as you can within 40 seconds.",
                             numberOfParticipants: 769)
        default:
            return JoinModel(name: "25 min HIIT challenge",
                             description: "Complete 25 mins of this HIIT challenge to unlock your reward.",
                             numberOfParticipants: 650)
        }
    }
}

struct JoinModel {
    let name: String
    let description: String
    let numberOfParticipants: Int
}
