//
//  Router.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 9/8/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import Foundation
import Alamofire

protocol BaseRouter: URLRequestConvertible {
    static var baseURLString: String? { get }
}

enum Router: BaseRouter {
    static var baseURLString: String?
//    static var OAuthToken: String?
    
    enum Etherium {
        case balance(params: Parameters)
        case receiveFree(params: Parameters)
        case walletCreate
    }
    
    enum Challenge{
        case create(params: Parameters)
        case fetchList
        case list(challengeAddress: String)
        case reward(challengeAddress: String)
        case submit(challengeAddress: String, participantAddress: String, params: Parameters)
    }
    
    enum ChallengeAvailability {
        case `public`(Challenge)
        case `private`(Challenge)
    }
    
    case challenge(ChallengeAvailability)
    case etherium(Etherium)
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .challenge(.private(.fetchList)),
             .challenge(.private(.list)),
             .challenge(.public(.fetchList)),
             .challenge(.public(.list)),
             .etherium(.balance):
            return .get
            
        case .challenge(.private(.create)),
             .challenge(.private(.reward)),
             .challenge(.private(.submit)),
             .challenge(.public(.create)),
             .challenge(.public(.reward)),
             .challenge(.public(.submit)),
             .etherium(.receiveFree),
             .etherium(.walletCreate):
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .challenge(.private(.create)):
            return "/challenge/private/create"
        case .challenge(.private(.fetchList)):
            return "/challenge/private/list"
        case .challenge(.private(.list(let address))):
            return "/challenge/private/list/\(address)"
        case .challenge(.private(.reward(let address))):
            return "/challenge/private/reward/\(address)"
        case .challenge(.private(.submit(let challengeAddress, let participantAddress, _))):
            return "/challenge/private/submit/\(challengeAddress)/\(participantAddress)"
        case .challenge(.public(.create)):
            return "/challenge/public/create"
        case .challenge(.public(.fetchList)):
            return "/challenge/public/list"
        case .challenge(.public(.list(let address))):
            return "/challenge/public/list/\(address)"
        case .challenge(.public(.reward(let address))):
            return "/challenge/public/reward/\(address)"
        case .challenge(.public(.submit(let challengeAddress, let participantAddress, _))):
            return "/challenge/public/submit/\(challengeAddress)/\(participantAddress)"
        case .etherium(.balance):
            return "/ethereum/balance"
        case .etherium(.receiveFree):
            return "/ethereum/coin/receive-free"
        case .etherium(.walletCreate):
            return "/ethereum/wallet/create"
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = Foundation.URL(string: Router.baseURLString!)!
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        let urlEncoder = URLEncoding.default
        let jsonEncoder = JSONEncoding.default
        
        switch self {
        case .challenge(.public(.create(let params))),
             .challenge(.private(.create(let params))),
             .challenge(.public(.submit(_, _, let params))),
             .challenge(.private(.submit(_, _, let params))),
             .etherium(.balance(let params)),
             .etherium(.receiveFree(let params)):
            return try jsonEncoder.encode(urlRequest, with: params)
        default:
            return try urlEncoder.encode(urlRequest, with: nil)
        }
    }
}

