//
//  AddChallengeViewController.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 9/4/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import UIKit
import MBProgressHUD

final class AddChallengeViewController: UIViewController {
    var startDatePicker: UIDatePicker!
    var endDatePicker: UIDatePicker!
    var toolbar: UIToolbar!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func payToInitiate(_ sender: UIButton) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        viewModel.save { [unowned self] (error) in
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                
                let alert: UIAlertController
                if error == nil {
                    alert = UIAlertController(title: "Success", message: "Challenge is created", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] (_) in
                        self?.navigationController?.popViewController(animated: true)
                    }))
                }
                else {
                    alert = UIAlertController(title: "Error!", message: error!, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                }
                
                self.navigationController?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    var type: ChallengeType!
    var viewModel: AddChallengeViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = AddChallengeViewModel(type: type)
        setupTableView()
        setupPickers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60.0
        
        tableView.register(AddChallengeCell.nib, forCellReuseIdentifier: AddChallengeCell.cellId)
        tableView.register(AddChallengeTextFieldCell.nib, forCellReuseIdentifier: AddChallengeTextFieldCell.cellId)
        tableView.register(RoundTableViewCell.nib, forCellReuseIdentifier: RoundTableViewCell.cellId)
    }
    
    func setupPickers() {
        toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = false
        toolbar.isUserInteractionEnabled = true
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action:  #selector(done(toolbar:)))
        toolbar.items = [done]
        
        startDatePicker = UIDatePicker()
        startDatePicker.datePickerMode = .date
        startDatePicker.addTarget(self, action: #selector(datePickerValueChanged(picker:)), for: .valueChanged)
        
        endDatePicker = UIDatePicker()
        endDatePicker.datePickerMode = .date
        endDatePicker.addTarget(self, action: #selector(datePickerValueChanged(picker:)), for: .valueChanged)
        
        toolbar.sizeToFit()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddRound" {
            guard let vc = segue.destination as? AddRoundViewController else { fatalError() }
            vc.viewModel = viewModel
        }
    }
}

/// MARK: - Date Picker
extension AddChallengeViewController {
    func datePickerValueChanged(picker: UIDatePicker) {
        switch picker {
        case startDatePicker:
            viewModel.challenge.startDate = picker.date
        case endDatePicker:
            viewModel.challenge.endDate = picker.date
        default: break
        }
    }
    
    func done(toolbar: UIToolbar) {
        tableView.reloadRows(at: [IndexPath(row: 0, section: 1),
                                  IndexPath(row: 1, section: 1)],
                             with: .none)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.view.endEditing(true)
        }
    }
}

extension AddChallengeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Rounds"
        }
        else {
            return "Parameters"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 && indexPath.row == viewModel.challenge.rounds.count {
            performSegue(withIdentifier: "showAddRound", sender: nil)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

extension AddChallengeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return viewModel.numberOfRounds()
        }
        else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let round = viewModel.round(for: indexPath) {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: RoundTableViewCell.cellId, for: indexPath) as? RoundTableViewCell else { fatalError() }
                cell.name.text = round.title
                cell.reps.text = String(round.repetition)
                cell.exercises.text = round.exercises.map({ $0.name }).joined(separator: ", ")
                return cell
            }
            else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: AddChallengeCell.cellId, for: indexPath) as? AddChallengeCell else { fatalError() }
                return cell
            }
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AddChallengeTextFieldCell.cellId, for: indexPath) as? AddChallengeTextFieldCell else { fatalError() }
            let row = indexPath.row
            
            switch row {
            /// Start Date
            case 0:
                cell.date.inputAccessoryView = toolbar
                cell.date.inputView = startDatePicker
                cell.date.text = viewModel.title(for: indexPath)
                cell.dateTitle.text = "Start Date:"
            /// End Date
            case 1:
                cell.date.inputAccessoryView = toolbar
                cell.date.inputView = endDatePicker
                cell.date.text = viewModel.title(for: indexPath)
                cell.dateTitle.text = "End Date:"
            /// Fee
            default:
                cell.date.inputAccessoryView = nil
                cell.date.inputView = nil
                cell.dateTitle.text = "Fee:"
            }
            
            return cell
        }
    }
}
