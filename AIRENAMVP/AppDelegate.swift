//
//  AppDelegate.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 6/21/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import UIKit
import HealthKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let healthStore = HKHealthStore()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        showHome() /// TODO: remove this and uncomment the line below. 
        showInitial()
        return true
    }
    
    // authorization from watch
    func applicationShouldRequestHealthAuthorization(_ application: UIApplication) {
        healthStore.handleAuthorizationForExtension { success, error in }
    }
}

extension AppDelegate {
    fileprivate func showInitial() {
        let userExists = AppSettings.shared.userExists()
        
        if userExists { showHome() }
        else { showLogin() }
    }
    
    public func showHome() {
        guard let main = UIStoryboard(name: "TabBar", bundle: nil).instantiateInitialViewController() else { return }
        window?.rootViewController = main
    }
    
    public func showLogin() {
        guard let auth = UIStoryboard(name: "Auth", bundle: nil).instantiateInitialViewController() else { return }
        window?.rootViewController = auth
    }
}
