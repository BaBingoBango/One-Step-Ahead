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
    /// A generic description of the task's object for use in Clued In mode.
    var genericDescription: String
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
        Task(category: .drawing, object: "Apple", commandPhrase: "an apple!", genericDescription: "Draw something round and edible!"),
        Task(category: .drawing, object: "Axe", commandPhrase: "an axe!", genericDescription: "Draw something that chops!"),
        Task(category: .drawing, object: "Bird", commandPhrase: "a bird!", genericDescription: "Draw something that flies!"),
        Task(category: .drawing, object: "Bowtie", commandPhrase: "a bowtie!", genericDescription: "Draw a fancy accessory!"),
        Task(category: .drawing, object: "Broom", commandPhrase: "a broom!", genericDescription: "Draw something that cleans!"),
        Task(category: .drawing, object: "Calculator", commandPhrase: "a calculator!", genericDescription: "Draw a math tool!"),
        Task(category: .drawing, object: "Cat", commandPhrase: "a cat!", genericDescription: "Draw a common pet!"),
        Task(category: .drawing, object: "Crown", commandPhrase: "a crown!", genericDescription: "Draw a piece of expensive headwear!"),
        Task(category: .drawing, object: "Clock", commandPhrase: "a clock!", genericDescription: "Draw something round with hands!"),
        Task(category: .drawing, object: "Door", commandPhrase: "a door!", genericDescription: "Draw something that opens!")
    ]
    
}
