//
//  Difficulty.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 5/26/22.
//

import Foundation

/// The possible difficulties of a game: easy, normal, hard, or lunatic.
enum Difficulty: Codable {
    /// The difficulty where the player needs 80% and the AI needs 90% to win.
    case easy
    
    /// The difficulty where the player needs 90% and the AI needs 90% to win.
    case normal
    
    /// The difficulty where the player needs 97% and the AI needs 80% to win.
    case hard
    
    /// The difficulty where the player needs 99% and the AI needs 50% to win.
    case lunatic
}
