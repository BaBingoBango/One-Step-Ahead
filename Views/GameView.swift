//
//  GameView.swift
//  
//
//  Created by Ethan Marshall on 4/7/22.
//

import SwiftUI

/// The view displaying the elements of the currently running game; originates from the New Game screen.
struct GameView: View {
    
    // Variables
    /// The state of the app's currently running game, passed in from the New Game screen.
    @State var game: GameState = GameState()
    
    var body: some View {
        VStack {
            Text("Round \(game.currentRound)")
                .font(.title)
                .fontWeight(.bold)
            Text(game.task.commandPrompt)
                .font(.title2)
                .fontWeight(.bold)
            Text("\(game.timeLeft)s")
            
            Spacer()
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
