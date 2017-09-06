//
//  ChallengeStruct.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 9/4/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import Foundation

enum ChallengeType {
    enum PublicType {
        case oneOnOne
        case group
    }
    
    case `public`(PublicType)
    case `private`
}

struct Challenge {
    var title: String = ""
    var type: ChallengeType
    var rounds: [Round] = []
    var peers: [Peer] = []
    var startDate: Date?
    var endDate: Date?
    
    init(type: ChallengeType) {
        self.type = type
    }
}

struct Round {
    var title: String
    var repetition: Int
    var exercises: [Exercise]
}

enum ExecutionMeasurment {
    case repetition
    case duration
}

struct Exercise {
    let name: String
    let executionNumber: Int
    let executionMeasurement: ExecutionMeasurment
    let rest: Int
}


/// TODO: users
struct Peer {
    
}
