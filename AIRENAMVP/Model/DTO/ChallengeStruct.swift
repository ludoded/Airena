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
        self.startDate = Date(timeIntervalSince1970: json["startDate"].doubleValue / 1000)
        self.endDate = Date(timeIntervalSince1970: json["endDate"].doubleValue / 1000) 
        self.rounds = json["rounds"].arrayValue.map(Round.init)
        self.peers = json["participantIds"].arrayValue.map({ $0.stringValue })
    }
    
    init(json: JSON) {
        self.init(with: json, and: .private)
    }
    
    func jsonDict() -> [String : Any] {
        return [
            "ownerAddress" : owner,
            "startDate" : startDate?.toJsonFormat() ?? "",
            "endDate" : endDate?.toJsonFormat() ?? "",
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
    var executionNumber: Int = 0
    var executionMeasurement: ExecutionMeasurment = .duration
    var rest: Int = 0
    
    func jsonDict() -> [String : Any] {
        return [
            "name" : name,
            "work" : executionNumber,
            "rest" : rest
        ]
    }
}

extension Exercise {
    init(with json: JSON) {
        self.name = json["name"].stringValue
        self.executionNumber = json["work"].intValue
        self.executionMeasurement = .duration
        self.rest = json["rest"].intValue
    }
}
