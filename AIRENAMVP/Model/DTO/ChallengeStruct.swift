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
    var title: String = ""
    var repetition: Int = 0
    var exercises: [Exercise] = []
}

enum ExecutionMeasurment {
    case repetition
    case duration
    
    init(with index: Int) {
        switch index {
        case 0: self = .repetition
        default: self = .duration
        }
    }
}

struct Exercise {
    var name: String = ""
    var executionNumber: Int = 0
    var executionMeasurement: ExecutionMeasurment = .duration
    var rest: Int = 0
}


/// TODO: users
struct Peer {
    
}
