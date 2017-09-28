//
//  JoinDescriptionViewController.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 9/12/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import UIKit

final class JoinDescriptionViewController: UIViewController {
    var challenge: Challenge!
    var viewModel: JoinDescriptionViewModel!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = JoinDescriptionViewModel(challenge: challenge)
        setupTableView()
        
        let start = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(startTimer))
        navigationItem.rightBarButtonItem = start
    }
    
    func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        
        tableView.register(ExerciseTableViewCell.nib, forCellReuseIdentifier: ExerciseTableViewCell.cellId)
        tableView.register(JoinDescriptionHeaderCell.nib, forCellReuseIdentifier: JoinDescriptionHeaderCell.cellId)
    }
    
    @objc func startTimer() {
        performSegue(withIdentifier: "showJoinTimer", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showJoinTimer" {
            if let vc = segue.destination as? JoinTimerViewController {
                vc.challenge = viewModel.challenge
            }
        }
    }
}

extension JoinDescriptionViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.challenge.rounds.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: JoinDescriptionHeaderCell.cellId, for: indexPath) as? JoinDescriptionHeaderCell else { fatalError() }
            
            cell.start.text = viewModel.challenge.startDate?.toChallengeFormat()
            cell.end.text = viewModel.challenge.endDate?.toChallengeFormat()
            cell.participants.text = String(viewModel.challenge.peers.count)
            
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ExerciseTableViewCell.cellId, for: indexPath) as? ExerciseTableViewCell else { fatalError() }
            
            let exercise = viewModel.challenge.rounds[indexPath.section - 1].exercises[indexPath.row]
            cell.name.text = exercise.name
            cell.work.text = String(exercise.executionNumber)
            cell.rest.text = String(exercise.rest)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.0 : 20.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section != 0 else { return nil }
        
        let round = viewModel.challenge.rounds[section - 1]
        return round.title
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
