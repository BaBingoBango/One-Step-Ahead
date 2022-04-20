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
    var playerWinThreshold: Int {
        switch difficulty {
        case .easy:
            return 80
        case .normal:
            return 90
        case .hard:
            return 97
        }
    }
    /// The drawing score required for the AI to win the game.
    var AIwinThreshold: Int {
        switch difficulty {
        case .easy:
            return 90
        case .normal:
            return 90
        case .hard:
            return 80
        }
    }
    /// The command text to display when a round's timer is decreasing.
    var defaultCommandText: String {
        switch gameMode {
        case .flyingBlind:
            return "Draw the mystery object!"
        case .normal:
            // Remove the current object from the task list
            var drawingList = Task.taskList
            drawingList.remove(at: Task.taskList.firstIndex(where: { $0.object == task.object })!)
            
            // Select 3 random objects to use as clues, along with the game task's object
            var clues: [Task] = [task]
            for _ in 1...3 {
                let randomTask = drawingList.randomElement()!
                drawingList.remove(at: drawingList.firstIndex(where: { $0.object == randomTask.object })!)
                clues.append(randomTask)
            }
            
            // Shuffle the clues
            clues.shuffle()
            
            // Return default command text
            return "Posible Drawings: \(clues[0].object), \(clues[1].object), \(clues[2].object), \(clues[3].object)"
        case .demystify:
            return "Draw \(task.commandPhrase)"
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
