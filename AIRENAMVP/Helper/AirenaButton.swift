//
//  AirenaButton.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 9/28/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import UIKit

final class AirenaButton: UIButton {
    override var isEnabled: Bool {
        didSet(value) {
            self.alpha = value ? 1.0 : 0.5
        }
    }
}
