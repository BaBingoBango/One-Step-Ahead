//
//  GameMode.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 5/26/22.
//

import Foundation

/// The possible modes for a game; they describe the level of hints the player should receive.
enum GameMode: Codable {
    case flyingBlind
    case cluedIn
    case batch
    case demystify
}
