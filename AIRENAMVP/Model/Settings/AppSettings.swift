//
//  AppSettings.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 8/30/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import Foundation

final class AppSettings {
    static let shared = AppSettings()
    
    fileprivate let ud = UserDefaults.standard
    
    private init() {}
    
    func save(wallet: WalletResponse) {
        ud.set(wallet.address, forKey: "UserAddress")
        ud.set(wallet.privateKey, forKey: "PrivateKey")
    }
    
    func userExists() -> Bool {
        guard let _ = ud.string(forKey: "UserAddress") else { return false }
        return true
    }
    
    func address() -> String {
        return ud.string(forKey: "UserAddress") ?? ""
    }
}
