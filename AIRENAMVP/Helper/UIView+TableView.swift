//
//  UIView+TableView.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 7/4/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import UIKit

extension UIView {
    static var cellId: String {
        return String(describing: self)
    }
    
    static var nib: UINib {
        return UINib(nibName: cellId, bundle: Bundle.main)
    }
}
