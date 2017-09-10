//
//  JSONable.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 9/8/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import SwiftyJSON
import Alamofire

/// Sharable protocol for struct which are constructed from JSON objects
protocol JSONable {
    init(json: JSON)
}

extension JSON {
    func typeArray<A: JSONable>() -> [A] {
        return self.arrayValue.map(A.init)
    }
}

extension JSONable {
    static func load(request: DataRequest, callback: @escaping (_ items: [Self]?, _ message: String?) -> ()) {
        request.responseParsed (callback: { (json, error) in
            guard json != nil else { callback(nil, error!); return }
            
            let items: [Self] = json!.typeArray()
            
            callback(items, nil)
        })
    }
    
    static func loadType(request: DataRequest, callback: @escaping (_ item: Self?, _ message: String?) -> ()) {
        request.responseParsed (callback: { (json, error) in
            guard json != nil else { callback(nil, error!); return }
            
            let item: Self = Self.init(json: json!)
            
            callback(item, nil)
        })
    }
}
