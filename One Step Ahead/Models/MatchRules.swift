//
//  GameRules.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 5/26/22.
//

import Foundation

/// A structure used in Versus to transmit and receive rules for a match.
struct MatchRules: Codable {
    
    /// The task the player must complete for the game.
    ///
    /// By default, the task will be randomly selected from the task list.
    var task: Task = Task.taskList.randomElement()!
    /// The selected game mode for the game.
    var gameMode: GameMode = .cluedIn
    /// The user-set difficulty level for the game.
    var difficulty: Difficulty = .normal
    /// The command text to display when a round's timer is decreasing.
    var defaultCommandText: String = "Default Command Text"
    
}
