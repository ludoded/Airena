//
//  JoinViewModel.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 9/11/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import Foundation

final class JoinViewModel {
    var challenges: [Challenge] = []
    
    func fetchChallenges(callback: @escaping (String?) -> Void) {
        Challenge.load(request: API.fetchChallenge(availability: false)) { [unowned self] (chal, error) in
            if error == nil {
                self.challenges = chal!
            }
            
            callback(error)
        }
    }
}
