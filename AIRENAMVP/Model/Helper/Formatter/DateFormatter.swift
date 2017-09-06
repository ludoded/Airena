//
//  DateFormatter.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 9/6/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import Foundation

extension Date {
    func toChallengeFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        return formatter.string(from: self)
    }
}
