//
//  ScoreEvaluationStatus.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 7/14/22.
//

import Foundation

/// The different possible statuses of the end-of-round score evaluation process.
enum ScoreEvaluationStatus {
    /// The case in which evaluation has yet to take place.
    case notEvaluating
    
    /// The case in which evaluation is in progress.
    case evaluating
    
    /// The case in which evaluation is complete.
    case evaluationComplete
}
