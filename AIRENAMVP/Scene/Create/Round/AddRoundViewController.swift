//
//  AddRoundViewController.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 9/6/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import UIKit
import FocusMotion
import FocusMotionAppleWatch

final class AddRoundViewController: UIViewController {
    fileprivate var exercises: [String]!
    fileprivate var movements: [String]!
    
    var viewModel: AddChallengeViewModel!
    var exercisePicker: UIPickerView!
    var toolbar: UIToolbar!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func cancel(_ sender: Any) {
        viewModel.deinitializeCurrentRound()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func save(_ sender: Any) {
        viewModel.saveCurrentRound()
        viewModel.deinitializeCurrentRound()
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupExercises()
        viewModel.initializeCurrentRound()
        setupTableView()
        setupPickers()
    }
    
    /// MARK: - Setup handling
    func setupExercises() {
        exercises = []
        movements = []
        
        /// Load Jay's exercises
        movements.append(contentsOf: ["jumpingjacks", "pushups", "situps", "barbellsquat"])
        
        for movement in movements {
            if let displayName = FMMovement.findSdkMovement(movement)?.displayName { exercises.append(displayName) }
        }
    }
    
    func setupPickers() {
        toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = false
        toolbar.isUserInteractionEnabled = true
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done(toolbar:)))
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel(toolbar:)))
        toolbar.items = [done, cancel]
        
        exercisePicker = UIPickerView()
        exercisePicker.dataSource = self
        exercisePicker.delegate = self
        
        toolbar.sizeToFit()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    func setupTableView() {
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.register(AddChallengeTextFieldCell.nib, forCellReuseIdentifier: AddChallengeTextFieldCell.cellId)
        tableView.register(ExerciseTableViewCell.nib, forCellReuseIdentifier: ExerciseTableViewCell.cellId)
        tableView.register(FullTextFieldTableViewCell.nib, forCellReuseIdentifier: FullTextFieldTableViewCell.cellId)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddExercise" {
            guard let vc = segue.destination as? AddExerciseViewController else { fatalError() }
            vc.viewModel = viewModel
        }
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
            return viewModel.numberOfExercise()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AddChallengeTextFieldCell.cellId, for: indexPath) as? AddChallengeTextFieldCell else { fatalError() }
            
            switch indexPath.row {
            case 0:
                cell.dateTitle.text = "Title"
                cell.date.keyboardType = .default
                cell.textDidChange = { [weak self] str in
                    self?.viewModel.currentRound?.title = str
                }
            case 1:
                cell.dateTitle.text = "Repetition"
                cell.date.keyboardType = .numberPad
                cell.textDidChange = { [weak self] str in
                    self?.viewModel.currentRound?.repetition = Int(str) ?? 0
                }
            default:
                break
            }
            
            return cell
        }
        else {
            if let exercise = viewModel.exercise(for: indexPath) {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ExerciseTableViewCell.cellId, for: indexPath) as? ExerciseTableViewCell else { fatalError() }
                cell.name.text = exercise.name
                cell.work.text = String(exercise.executionNumber)
                cell.rest.text = String(exercise.rest)
                return cell
            }
            else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: FullTextFieldTableViewCell.cellId, for: indexPath) as? FullTextFieldTableViewCell else { fatalError() }
                cell.textField.inputView = exercisePicker
                cell.textField.inputAccessoryView = toolbar
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Parameters"
        }
        else {
            return "Exercises"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 && indexPath.row == (viewModel.currentRound?.exercises.count) ?? 0 {
            performSegue(withIdentifier: "showAddExercise", sender: nil)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

/// MARK: Picker view delegates
extension AddRoundViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 4 /// 4 Exercise types
        }
        else {
            return 60 /// Work and Rest time from 1 to 60 seconds
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return exercises[row]
        }
        else {
            return String(describing: Array(1...60)[row])
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label: UILabel
        if let view = view as? UILabel { label = view }
        else { label = UILabel() }
        
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.numberOfLines = 0
        
        if component == 0 {
            label.text = exercises[row]
        }
        else {
            label.text = String(describing: Array(1...60)[row])
        }
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        let width = UIScreen.main.bounds.width - 20
        
        if component != 0 {
            return 40.0
        }
        
        return width - 80.0
    }
    
    func done(toolbar: UIToolbar) {
        let selectedRow = exercisePicker.selectedRow(inComponent: 0)
        let exerciseName = exercises[selectedRow]
        let movementName = movements[selectedRow]
        
        viewModel.addExercise(for: exerciseName,
                              movement: movementName,
                              workIndex: exercisePicker.selectedRow(inComponent: 1) + 1,
                              restIndex: exercisePicker.selectedRow(inComponent: 2) + 1)
        
        tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.view.endEditing(true)
        }
    }
    
    func cancel(toolbar: UIToolbar) {
        view.endEditing(true)
    }
}
