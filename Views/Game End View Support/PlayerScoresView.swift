//
//  PlayerScoresView.swift
//  
//
//  Created by Ethan Marshall on 4/20/22.
//

import SwiftUI
import SpriteKit

/// The view displaying the history of the player's scores for the current round. It is avaliable after a game has finished.
struct PlayerScoresView: View {
    
    // Variables
    /// The state of the app's currently running game, passed in from the Game End View.
    @State var game: GameState
    
    var body: some View {
        ZStack {
            SpriteView(scene: SKScene(fileNamed: "Game End View Graphics")!)
                .edgesIgnoringSafeArea(.all)
            
            RoundScoreCard()
        }
    }
}

struct PlayerScoresView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerScoresView(game: GameState())
            .previewInterfaceOrientation(.landscapeLeft)
    }
}

struct RoundScoreCard: View {
    var body: some View {
        ZStack {
            Rectangle()
                .cornerRadius(30)
            
            VStack {
                Text("- Round 1 -")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.vertical)
                
                Rectangle()
                    .foregroundColor(.gray)
                    .opacity(0.3)
                    .frame(width: 200, height: 200)
                    .cornerRadius(10)
                
                HStack(spacing: 30) {
                    VStack(spacing: 0) {
                        Text("You")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        PercentCircle(percent: 100.0, circleWidth: 100, circleHeight: 100, font: .title2)
                            .padding(.top, 5)
                    }
                    
                    VStack(spacing: 0) {
                        Text("AI")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        
                        PercentCircle(percent: 100.0, circleWidth: 100, circleHeight: 100, color: .red, font: .title2)
                            .padding(.top, 5)
                    }
                }
                
                Spacer()
            }
        }
        .frame(width: 350, height: 450)
    }
}
