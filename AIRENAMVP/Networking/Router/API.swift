//
//  API.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 9/8/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import Foundation
import Alamofire

private var router: Router.Type {
    Router.baseURLString = API.baseURL
    return Router.self
}

struct API {
    static var baseURL: String {
        return "http://ec2-54-85-102-92.compute-1.amazonaws.com:8080"
    }
}

/// MARK: Challenge
extension API {
    static func createChallenge(with params: Parameters, availability isPrivate: Bool) -> DataRequest {
        if isPrivate {
            return Alamofire.request(router.challenge(.private(.create(params: params))))
        }
        else {
            return Alamofire.request(router.challenge(.public(.create(params: params))))
        }
    }
    
    static func fetchChallenge(availability isPrivate: Bool) -> DataRequest {
        if isPrivate {
            return Alamofire.request(router.challenge(.private(.fetchList)))
        }
        else {
            return Alamofire.request(router.challenge(.public(.fetchList)))
        }
    }
    
    static func listChallenge(with challengeAddress: String, availability isPrivate: Bool) -> DataRequest {
        if isPrivate {
            return Alamofire.request(router.challenge(.private(.list(challengeAddress: challengeAddress))))
        }
        else {
            return Alamofire.request(router.challenge(.public(.list(challengeAddress: challengeAddress))))
        }
    }
    
    static func rewardChallenge(with challengeAddress: String, availability isPrivate: Bool) -> DataRequest {
        if isPrivate {
            return Alamofire.request(router.challenge(.private(.reward(challengeAddress: challengeAddress))))
        }
        else {
            return Alamofire.request(router.challenge(.public(.reward(challengeAddress: challengeAddress))))
        }
    }
    
    static func submitChallenge(with challengeAddress: String, and participantAddress: String, params: Parameters, availability isPrivate: Bool) -> DataRequest {
        if isPrivate {
            return Alamofire.request(router.challenge(.private(.submit(challengeAddress: challengeAddress, participantAddress: participantAddress, params: params))))
        }
        else {
            return Alamofire.request(router.challenge(.public(.submit(challengeAddress: challengeAddress, participantAddress: participantAddress, params: params))))
        }
    }
}

/// MARK: Etherium
extension API {
    static func etheriumBalance(with params: Parameters) -> DataRequest {
        return Alamofire.request(router.etherium(.balance(params: params)))
    }
    
    static func etheriumReceiveFree(with params: Parameters) -> DataRequest {
        return Alamofire.request(router.etherium(.receiveFree(params: params)))
    }
    
    static func etheriumCreateWallet(with params: Parameters) -> DataRequest {
        return Alamofire.request(router.etherium(.walletCreate))
    }
}

