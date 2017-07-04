//
//  JoinViewController.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 7/4/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import UIKit

final class JoinViewController: UIViewController {
    fileprivate let viewModel = JoinViewModel()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCell()
        setupTableView()
    }
    
    private func registerCell() {
        tableView.register(JoinCell.nib, forCellReuseIdentifier: JoinCell.cellId)
    }
    
    private func setupTableView() {
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
    }
}

extension JoinViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: JoinCell.cellId, for: indexPath) as? JoinCell else { fatalError("Can't load the cell") }
        let join = viewModel.existingChallenge(for: indexPath.row)
        cell.setup(with: join)
        
        return cell
    }
}

extension JoinViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
