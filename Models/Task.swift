//
//  Task.swift
//  
//
//  Created by Ethan Marshall on 4/7/22.
//

import Foundation
import CoreML

/// In the context of a game, the action the player must take to score points.
struct Task {
    
    // Variables
    /// The action the player must perform during a game.
    var category: TaskCategory
    /// The specific object the user must perform the action for during a game.
    var object: String
    /// The English phrase that should follow this task's type's verb.
    var commandPhrase: String
    /// The Core ML model trained to assign scores to object task attempts.
    var judgeModel: MLModel
    
    // Computed Properties
    /// An English phrase prompting the user to complete the task.
    var commandPrompt: String {
        var answer = ""
        switch category {
        case .drawing:
            answer += "Draw "
        case .speech:
            answer += "Say "
        case .handPoses:
            answer += "Make "
        }
        answer += commandPhrase
        return answer
    }
    
    // Enumerations
    /// The possible categories of tasks: drawing, speech, and hand poses.
    enum TaskCategory {
        case drawing
        case speech
        case handPoses
    }
    
    // Included App Data
    /// The list of all possible tasks for use in games.
    static var taskList: [Task] = [
        Task(category: .drawing, object: "Circle", commandPhrase: "a perfect circle!", judgeModel: MLModel())
    ]
    
}