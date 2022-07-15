//
//  Difficulty.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 5/26/22.
//

import Foundation

/// The possible difficulties of a game: easy, normal, hard, or lunatic.
enum Difficulty: Codable {
    /// The difficulty where the player needs 50% and the AI needs 95% to win.
    case easy
    
    /// The difficulty where the player needs 70% and the AI needs 85% to win.
    case normal
    
    /// The difficulty where the player needs 80% and the AI needs 70% to win.
    case hard
    
    /// The difficulty where the player needs 95% and the AI needs 50% to win.
    case lunatic
}
