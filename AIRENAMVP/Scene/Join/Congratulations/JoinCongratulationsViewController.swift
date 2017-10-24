//
//  JoinCongratulationsViewController.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 10/2/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import UIKit

final class JoinCongratulationsViewController: UIViewController {
    var viewModel: JoinTimerViewModel!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction(_:)))
        navigationItem.backBarButtonItem = done
        
        tableView.register(ReviewTableViewCell.nib, forCellReuseIdentifier: ReviewTableViewCell.cellId)
    }
    
    @objc func doneAction(_: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: true)
    }
}

extension JoinCongratulationsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.metrics.rounds.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.metrics.rounds[section].exercise.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReviewTableViewCell.cellId, for: indexPath) as? ReviewTableViewCell else { fatalError() }
        cell.setup(with: viewModel.metrics.rounds[indexPath.section].exercise[indexPath.row])
        return cell
    }
}
