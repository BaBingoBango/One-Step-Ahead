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
    
    // MARK: - Game Configuration Variables
    /// The task the player must complete for the game.
    ///
    /// By default, the task will be randomly selected from the task list.
    var task: Task = Task.taskList.randomElement()!
    /// The selected game mode for the game.
    var gameMode: GameMode = .normal
    /// The user-set difficulty level for the game.
    var difficulty: Difficulty = .normal
    
    // MARK: - Game State Variables
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
    
    // MARK: - ML Model Variable
    /// The current model for the AI, trained on the player's task attempts.
    var AImodel: MLModel = MLModel()
    
    // MARK: - Computed Properties
    /// The drawing score required for the player to win the game.
    var playerWinThreshold: Double {
        switch difficulty {
        case .easy:
            return 80.0
        case .normal:
            return 90.0
        case .hard:
            return 97.0
        }
    }
    /// The drawing score required for the AI to win the game.
    var AIwinThreshold: Double {
        switch difficulty {
        case .easy:
            return 90
        case .normal:
            return 90.0
        case .hard:
            return 80.0
        }
    }
    
    // MARK: - Enumerations
    /// The possible modes for a game; they describe the level of hints the player should receive.
    enum GameMode {
        case flyingBlind
        case normal
        case demystify
    }
    /// The possible difficulties of a game: easy, normal, or hard.
    enum Difficulty {
        case easy
        case normal
        case hard
    }
    
}
