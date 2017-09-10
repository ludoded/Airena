//
//  WalletResponse.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 9/8/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import Foundation
import SwiftyJSON

struct WalletResponse: JSONable {
    let address: String
    let privateKey: String
    
    init(json: JSON) {
        self.address = json["address"].stringValue
        self.privateKey = json["privateKey"].stringValue
    }
}
