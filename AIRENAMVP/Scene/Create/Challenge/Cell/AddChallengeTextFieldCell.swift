//
//  AddChallengeDateCell.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 9/6/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import UIKit

final class AddChallengeTextFieldCell: UITableViewCell {
    @IBOutlet weak var dateTitle: UILabel!
    @IBOutlet weak var date: UITextField!
    
    var textDidChange: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        date.delegate = self
    }
}

extension AddChallengeTextFieldCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let resultString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        
        if let str = resultString {
            textDidChange?(str)
        }
        
        return true
    }
}
