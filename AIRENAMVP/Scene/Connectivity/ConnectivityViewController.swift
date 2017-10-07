//
//  ConnectivityViewController.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 10/6/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import UIKit

final class ConnectivityViewController: UIViewController {
    fileprivate var fm = FMSettings.shared
    
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var header: UILabel!
    
    @IBAction func connect(_: UIButton!) {
        fm.connect()
        updateConnectButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        status.text = ""
        fmSetup()
    }
    
    fileprivate func fmSetup() {
        fm.availableChangedCallback = { [unowned self] _ in
            self.updateConnectButton()
            self.updateStatusLabel()
        }
        
        fm.connectedChangesCallback = { [unowned self] connected in
            if connected {
                self.fm.device.sendMessage("Full Demo".data(using: .utf8)!)
            }
            
            self.updateConnectButton()
            self.updateStatusLabel()
        }
        
        fm.connectionFailedCallback = { [unowned self] error in
            self.updateConnectButton()
            self.updateStatusLabel()
            
            let alert = UIAlertController(title: "Connection Failed", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    fileprivate func updateConnectButton() {
        if fm.device != nil {
            if fm.device.connected {
                connectButton.setTitle("Disconnect", for: .normal)
                connectButton.isEnabled = true
            }
            else if fm.device.connecting {
                connectButton.setTitle("Connecting...", for: .normal)
                connectButton.isEnabled = false
            }
            else {
                connectButton.setTitle("Connect", for: .normal)
                connectButton.isEnabled = true
            }
        }
        else {
            connectButton.setTitle("Connect", for: .normal)
            connectButton.isEnabled = false
        }
    }
    
    fileprivate func updateStatusLabel() {
        if fm.device != nil {
            let stat = fm.device.connected ? "connected" : "disconnected"
            let name = fm.device.name ?? "No Name"
            status.text = "\(name): \(stat)"
        }
        else {
            status.text = "No available devices"
        }
    }
}
