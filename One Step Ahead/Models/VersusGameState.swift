//
//  VersusGameState.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 5/22/22.
//

import Foundation

/// The state of the currently running Versus game.
///
/// An object of type `VersusGameState` should not be transmitted to other players. Rather, objects of type ``VersusPlayerState`` should be broadcast to other players.
struct VersusGameState {
    
    /// The maximum number of players this Versus match allows.
    var maxPlayers: Int = 4
    
}
