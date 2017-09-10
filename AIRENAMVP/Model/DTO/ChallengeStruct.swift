//
//  ChallengeStruct.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 9/4/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import Foundation
import SwiftyJSON

enum ChallengeType {
    enum PublicType {
        case oneOnOne
        case group
    }
    
    case `public`(PublicType)
    case `private`
}

struct Challenge {
    var owner: String = ""
    var title: String = ""
    var type: ChallengeType
    var rounds: [Round] = []
    var peers: [String] = []
    var startDate: Date?
    var endDate: Date?
    
    init(type: ChallengeType) {
        self.type = type
    }
    
    init(with json: JSON, and type: ChallengeType) {
        self.owner = json["ownerAddress"].stringValue
        self.type = type
        self.startDate = Date() /// TODO:
        self.endDate = Date() /// TODO:
        self.rounds = json["rounds"].arrayValue.map(Round.init)
        self.peers = json["participantIds"].arrayValue.map({ $0.stringValue })
    }
}

struct Round {
    var title: String = ""
    var repetition: Int = 0
    var exercises: [Exercise] = []
}

extension Round {
    init(with json: JSON) {
        self.title = json["title"].stringValue
        self.repetition = json["repetition"].intValue
        self.exercises = json["exercises"].arrayValue.map(Exercise.init)
    }
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

extension Exercise {
    init(with json: JSON) {
        self.name = json["name"].stringValue
        self.executionNumber = json["rest"].intValue
        self.executionMeasurement = .duration
        self.rest = json["work"].intValue
    }
}
