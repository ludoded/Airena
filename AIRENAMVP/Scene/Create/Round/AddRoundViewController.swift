//
//  AddRoundViewController.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 9/6/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import UIKit

final class AddRoundViewController: UIViewController {
    var viewModel: AddChallengeViewModel!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setupTableView() {
        tableView.register(AddChallengeTextFieldCell.nib, forCellReuseIdentifier: AddChallengeTextFieldCell.cellId)
    }
}

extension AddRoundViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AddChallengeTextFieldCell.cellId, for: indexPath) as? AddChallengeTextFieldCell else { fatalError() }
            
            switch indexPath.row {
            case 0:
                cell.dateTitle.text = "Title"
                cell.date.keyboardType = .default
            case 1:
                cell.dateTitle.text = "Repetition"
                cell.date.keyboardType = .numberPad
            default:
                break
            }
            
            return cell
        }
        else {
            
        }
    }
}
