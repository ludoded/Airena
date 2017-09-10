//
//  DataRequest+ParseResponse.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 9/8/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//


import Alamofire
import SwiftyJSON

extension DataRequest {
    typealias RequestCallback = (_ result: JSON?, _ message: String?) -> Void
    
    @discardableResult
    func responseParsed(callback: @escaping RequestCallback) -> Self {
        return self.responseJSON { response in
            guard let JSONRequest = response.result.value else { self.stringRequest(); callback(nil, "Invalid JSON format"); return }
            
            let json = JSON(JSONRequest)
            
            /// If request is failed
            if response.result.isFailure {
                callback(nil, "Request is failed. Try again!")
                return
            }
            
            callback(json, nil)
        }
    }
    
    private func stringRequest() {
        self.responseString { response in
            debugPrint(response.result.value as Any)
        }
    }
}
