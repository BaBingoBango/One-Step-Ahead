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
    @Environment(\.screenLayout) private var layout
    
    // MARK: - View Variables
    /// The state of the app's currently running game, passed in from the Game End View.
    @State var game: GameState
    /// The SpriteKit scene for the graphics of this view.
    @State var graphicsScene = SKScene(fileNamed: "\(UIDevice.current.userInterfaceIdiom == .phone ? "iOS " : "")Game End View Graphics")!
    
    // MARK: - View Body
    var body: some View {
        ZStack {
            GameBackground(scene: graphicsScene)
            
            VStack {
                Text("")
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(1...game.currentRound, id: \.self) { roundNumber in
                            
                            RoundScoreCard(roundNumber: roundNumber, playerScore: game.playerScores[roundNumber - 1], AIscore: game.AIscores[roundNumber - 1], object: game.task.object)
                                .padding(.horizontal, layout.isRegular ? 15 : 10)
                            
                        }
                    }
                }
            }
        }
        .dynamicTypeSize(.medium).statusBar(hidden: true)
        
        // MARK: Navigation Bar Settings
        .navigationTitle("Round History")
    }
}

#Preview(traits: .landscapeLeft) {
    NavigationStack {
        PlayerScoresView(game: GameState(currentRound: 2, playerScores: [10, 20, 30], AIscores: [5, 30, 25]))
        
            .navigationBarTitleDisplayMode(.inline)
    }
}

/// The view for a round's worth of information on the player scores screen. The information is contained in a visual card-like structure.
struct RoundScoreCard: View {
    @Environment(\.screenLayout) private var layout
    
    // Variables
    var roundNumber: Int
    var playerScore: Double
    var AIscore: Double
    var object: String
    
    var body: some View {
        let viewBody = ZStack {
            Rectangle()
                .clipShape(.rect(cornerRadius: 30))
            
            VStack {
                Spacer()
                
                Text("- Round \(roundNumber) -")
                    .font(layout.isRegular ? .title : .title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                    .padding(.bottom)
                
                if layout.isRegular {
                    Image(uiImage: getImageFromDocuments("\(object).\(roundNumber).png")!)
                        .resizable()
                        .frame(width: 200, height: 200)
                        .clipShape(.rect(cornerRadius: 10))
                } else {
                    Image(uiImage: getImageFromDocuments("\(object).\(roundNumber).png")!)
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .clipShape(.rect(cornerRadius: 10))
                }
                
                HStack(spacing: 30) {
                    VStack(spacing: 0) {
                        Text("You")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                        
                        PercentCircle(percent: playerScore.truncate(places: 1), circleWidth: layout.isRegular ? 95 : 75, circleHeight: layout.isRegular ? 95 : 75, font: .title2)
                            .padding(.top, 5)
                    }
                    
                    VStack(spacing: 0) {
                        Text("AI")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.red)
                        
                        PercentCircle(percent: AIscore.truncate(places: 1), circleWidth: layout.isRegular ? 95 : 75, circleHeight: layout.isRegular ? 95 : 75, color: .red, font: .title2)
                            .padding(.top, 5)
                    }
                }
                .padding(.horizontal, layout.isRegular ? 0 : 15)
                
                Spacer()
            }
        }
        
        if layout.isRegular {
            viewBody
                .dynamicTypeSize(.medium).statusBar(hidden: true)
                .frame(width: 325, height: min(450, max(380, layout.height - 110)))
        } else {
            viewBody
                .dynamicTypeSize(.medium).statusBar(hidden: true)
        }
    }
}
