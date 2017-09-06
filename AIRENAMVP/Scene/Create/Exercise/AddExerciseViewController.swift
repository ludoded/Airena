//
//  AddExerciseViewController.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 9/6/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import UIKit

final class AddExerciseViewController: UITableViewController {
    var viewModel: AddChallengeViewModel!
    
    @IBOutlet weak var type: UITextField!
    @IBOutlet weak var work: UITextField!
    @IBOutlet weak var workType: UISegmentedControl!
    @IBOutlet weak var restTime: UITextField!
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        viewModel.deinitializeCurrentExercise()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func save(_ sender: Any) {
        viewModel.currentExercise?.name = type.text ?? ""
        viewModel.currentExercise?.executionNumber = Int(work.text ?? "") ?? 0
        viewModel.currentExercise?.executionMeasurement = ExecutionMeasurment(with: workType.selectedSegmentIndex)
        viewModel.currentExercise?.rest = Int(restTime.text ?? "") ?? 0
        
        viewModel.saveCurrentExercise()
        viewModel.deinitializeCurrentExercise()
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// init exercise
        viewModel.initializeCurrentExercise()
    }
}
