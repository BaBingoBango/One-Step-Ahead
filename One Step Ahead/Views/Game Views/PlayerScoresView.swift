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
    
    // MARK: - View Variables
    /// The state of the app's currently running game, passed in from the Game End View.
    @State var game: GameState
    /// The SpriteKit scene for the graphics of this view.
    @State var graphicsScene = SKScene(fileNamed: "\(UIDevice.current.userInterfaceIdiom == .phone ? "iOS " : "")Game End View Graphics")!
    
    // MARK: - View Body
    var body: some View {
        ZStack {
            SpriteView(scene: graphicsScene)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("")
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(1...game.currentRound, id: \.self) { roundNumber in
                            
                            RoundScoreCard(roundNumber: roundNumber, playerScore: game.playerScores[roundNumber - 1], AIscore: game.AIscores[roundNumber - 1], object: game.task.object)
                                .padding(.horizontal, UIDevice.current.userInterfaceIdiom != .phone ? 15 : 10)
                            
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

struct PlayerScoresView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PlayerScoresView(game: GameState(currentRound: 2, playerScores: [10, 20, 30], AIscores: [5, 30, 25]))
            
                .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .previewInterfaceOrientation(.landscapeLeft)
    }
}

/// The view for a round's worth of information on the player scores screen. The information is contained in a visual card-like structure.
struct RoundScoreCard: View {
    
    // Variables
    var roundNumber: Int
    var playerScore: Double
    var AIscore: Double
    var object: String
    
    var body: some View {
        let viewBody = ZStack {
            Rectangle()
                .cornerRadius(30)
            
            VStack {
                Spacer()
                
                Text("- Round \(roundNumber) -")
                    .font(UIDevice.current.userInterfaceIdiom != .phone ? .title : .title3)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.bottom)
                
                if UIDevice.current.userInterfaceIdiom != .phone {
                    Image(uiImage: getImageFromDocuments("\(object).\(roundNumber).png")!)
                        .resizable()
                        .frame(width: 200, height: 200)
                        .cornerRadius(10)
                } else {
                    Image(uiImage: getImageFromDocuments("\(object).\(roundNumber).png")!)
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .cornerRadius(10)
                }
                
                HStack(spacing: 30) {
                    VStack(spacing: 0) {
                        Text("You")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        PercentCircle(percent: playerScore.truncate(places: 1), circleWidth: UIDevice.current.userInterfaceIdiom != .phone ? 95 : 75, circleHeight: UIDevice.current.userInterfaceIdiom != .phone ? 95 : 75, font: .title2)
                            .padding(.top, 5)
                    }
                    
                    VStack(spacing: 0) {
                        Text("AI")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        
                        PercentCircle(percent: AIscore.truncate(places: 1), circleWidth: UIDevice.current.userInterfaceIdiom != .phone ? 95 : 75, circleHeight: UIDevice.current.userInterfaceIdiom != .phone ? 95 : 75, color: .red, font: .title2)
                            .padding(.top, 5)
                    }
                }
                .padding(.horizontal, UIDevice.current.userInterfaceIdiom != .phone ? 0 : 15)
                
                Spacer()
            }
        }
        
        if UIDevice.current.userInterfaceIdiom != .phone {
            viewBody
                .dynamicTypeSize(.medium).statusBar(hidden: true)
                .frame(width: 325, height: 450)
        } else {
            viewBody
                .dynamicTypeSize(.medium).statusBar(hidden: true)
        }
    }
}
