//
//  GameMode.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 5/26/22.
//

import Foundation

/// The possible modes for a game; they describe the level of hints the player should receive.
enum GameMode: Codable {
    /// The game mode in which no information about the solution is provided.
    case flyingBlind
    
    /// The game mode in which a generic solution clue is provided.
    case cluedIn
    
    /// The game mode in which the solution is hidden amongst three fakes.
    case batch
    
    /// The game mode in which the solution is provided.
    case demystify
}
