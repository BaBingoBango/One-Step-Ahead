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
    var judgeModel: MLModel = MLModel()
    
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
        Task(category: .drawing, object: "Apple", commandPhrase: "an apple!"),
        Task(category: .drawing, object: "Axe", commandPhrase: "an axe!"),
        Task(category: .drawing, object: "Bird", commandPhrase: "a bird!"),
        Task(category: .drawing, object: "Bowtie", commandPhrase: "a bowtie!"),
        Task(category: .drawing, object: "Broom", commandPhrase: "a broom!"),
        Task(category: .drawing, object: "Calculator", commandPhrase: "a calculator!"),
        Task(category: .drawing, object: "Cat", commandPhrase: "a cat!"),
        Task(category: .drawing, object: "Crown", commandPhrase: "a crown!"),
        Task(category: .drawing, object: "Clock", commandPhrase: "a clock!"),
        Task(category: .drawing, object: "Door", commandPhrase: "a door!")
    ]
    
}
