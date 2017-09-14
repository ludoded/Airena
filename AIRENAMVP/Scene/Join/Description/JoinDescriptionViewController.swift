//
//  JoinDescriptionViewController.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 9/12/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import UIKit

final class JoinDescriptionViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        
        tableView.register(ExerciseTableViewCell.nib, forCellReuseIdentifier: ExerciseTableViewCell.cellId)
        tableView.register(JoinDescriptionHeaderCell.nib, forCellReuseIdentifier: JoinDescriptionHeaderCell.cellId)
    }
    
    
}

extension JoinDescriptionViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
