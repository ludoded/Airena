//
//  JoinCongratulationsViewController.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 10/2/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import UIKit

final class JoinCongratulationsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction(_:)))
        navigationController?.navigationItem.backBarButtonItem = done
    }
    
    @objc func doneAction(_: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: true)
    }
}
