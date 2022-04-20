//
//  PlayerScoresView.swift
//  
//
//  Created by Ethan Marshall on 4/20/22.
//

import SwiftUI

/// The view displaying the history of the player's scores for the current round. It is avaliable after a game has finished.
struct PlayerScoresView: View {
    
    // Variables
    /// The state of the app's currently running game, passed in from the Game End View.
    @State var game: GameState
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct PlayerScoresView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerScoresView(game: GameState())
    }
}
