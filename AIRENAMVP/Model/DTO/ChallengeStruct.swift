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

struct Challenge: JSONable {
    var owner: String = ""
    var title: String = ""
    var description: String = ""
    var type: ChallengeType
    var rounds: [Round] = []
    var peers: [String] = []
    var startDate: Date?
    var endDate: Date?
    
    init(type: ChallengeType) {
        self.type = type
        self.owner = AppSettings.shared.address()
    }
    
    init(with json: JSON, and type: ChallengeType) {
        self.owner = json["ownerAddress"].stringValue
        self.type = type
        self.title = json["title"].stringValue
        self.description = json["description"].stringValue
        self.startDate = Date(timeIntervalSince1970: json["startDate"].doubleValue)
        self.endDate = Date(timeIntervalSince1970: json["endDate"].doubleValue)
        self.rounds = json["rounds"].arrayValue.map(Round.init)
        self.peers = json["participantIds"].arrayValue.map({ $0.stringValue })
    }
    
    init(json: JSON) {
        self.init(with: json, and: .private)
    }
    
    func jsonDict() -> [String : Any] {
        return [
            "ownerAddress" : owner,
            "title" : title,
            "description" : description,
            "startDate" : startDate?.timeIntervalSince1970 ?? 0,
            "endDate" : endDate?.timeIntervalSince1970 ?? 0,
            "rounds" : rounds.map({ $0.jsonDict() })
        ]
    }
}

struct Round {
    var title: String = ""
    var repetition: Int = 0
    var exercises: [Exercise] = []
    
    func jsonDict() -> [String : Any] {
        return [
            "title" : title,
            "repetition" : repetition,
            "exercises" : exercises.map({ $0.jsonDict() })
        ]
    }
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
    var movement: String = ""
    var executionNumber: Int = 0
    var executionMeasurement: ExecutionMeasurment = .duration
    var rest: Int = 0
    
    func jsonDict() -> [String : Any] {
        return [
            "name" : name,
            "movementName" : movement,
            "work" : executionNumber,
            "rest" : rest
        ]
    }
}

extension Exercise {
    init(with json: JSON) {
        self.name = json["name"].stringValue
        self.movement = json["movementName"].stringValue
        self.executionNumber = json["work"].intValue
        self.executionMeasurement = .duration
        self.rest = json["rest"].intValue
    }
}
