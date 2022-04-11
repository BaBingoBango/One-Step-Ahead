//
//  GameState.swift
//  
//
//  Created by Ethan Marshall on 4/7/22.
//

import Foundation
import CoreML
import PencilKit

/// The state of a currently running game.
struct GameState {
    
    // Game Configuration Variables
    /// The task the player must complete for the game.
    var task: Task = Task.taskList[0]
    /// The user-set difficulty level for the game.
    var difficulty: Difficulty = .normal
    /// Whether or not the task's object should be revealed.
    var shouldDemystify: Bool = false
    
    // Game State Variables
    /// The number of the game's current round.
    var currentRound: Int = 1
    /// The player's score for each game round.
    var playerScores: [Double] = []
    /// The AI's score for each game round.
    var AIscores: [Double] = []
    /// The time left on the game's current timer.
    var timeLeft: Double = 9.9
    /// Whether or not the on-screen timer should decrease.
    var shouldRunTimer: Bool = true
    
    // ML Model Variable
    /// The current model for the AI, trained on the player's task attempts.
    var AImodel: MLModel = MLModel()
    
    // Enumerations
    /// The possible difficulties of a game: easy, normal, or hard.
    enum Difficulty {
        case easy
        case normal
        case hard
    }
}
