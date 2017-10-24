//
//  ReviewTableViewCell.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 10/12/17.
//  Copyright © 2017 challengeme llc. All rights reserved.
//

import UIKit

final class ReviewTableViewCell: UITableViewCell {
    @IBOutlet weak var review: UILabel!
    
    func setup(with exercise: TimerChallengeMetrics.Round.Exercise) {
        review.text = """
        \(exercise.title)
        
        duration: \(exercise.duration)
        repetition: \(exercise.repetition)
        mean angular range: \(exercise.meanAngularRange)
        mean repetition time: \(exercise.meanRepTime)
        variation between reps: \(exercise.variationBetweenReps)
        variation from reference: \(exercise.variationFromReference)
        """
    }
}
