//
//  DateFormatter.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 9/6/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import Foundation

extension Date {
    init?(fromISO8601: String) {
        guard fromISO8601.characters.count > 5 else { return nil }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        guard let date = formatter.date(from: fromISO8601) else { return nil }
        self = date
    }
    
    func toJsonFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        return formatter.string(from: self)
    }
    
    func toChallengeFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        return formatter.string(from: self)
    }
}
