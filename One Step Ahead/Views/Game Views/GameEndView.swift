//
//  GameEndView.swift
//  
//
//  Created by Ethan Marshall on 4/19/22.
//

import SwiftUI
import SpriteKit

/// The screen displayed when a game finishes.
struct GameEndView: View {
    
    // Variables
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    /// Whether or not the game sequence is being presented as a full screen modal.
    @Binding var isShowingGameSequence: Bool
    /// The state of the app's currently running game, passed in from the Game View.
    @State var game: GameState
    /// Whether or not the victory/defeat jingle has played.
    @State var hasPlayedJingle = false
    
    // Computed Properties
    /// The player score from the last round of play.
    var lastPlayerScore: Double {
        game.playerScores.last!
    }
    /// The AI score from the last round of play.
    var lastAIscore: Double {
        game.AIscores.last!
    }
    var winner: Combatant {
        if lastPlayerScore >= lastAIscore && lastPlayerScore >= Double(game.playerWinThreshold) {
            return .player
        } else {
            return .AI
        }
    }
    
    // Enumeration
    /// The types of combatants in a game, that is, the player and the AI.
    enum Combatant {
        case player
        case AI
    }
    
    var body: some View {
        ZStack {
            SpriteView(scene: SKScene(fileNamed: "Game End View Graphics")!)
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                Text(winner == .player ? "You win!" : "You lose...")
                    .foregroundColor(winner == .player ? .gold : .red)
                    .font(.system(size: 70))
                    .fontWeight(.black)
                    .padding(.top)
                
                Text("Correct Drawing: \(game.task.object)")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .padding(.top, 3)
                
                Text("\(game.gameScore) pts.")
                    .foregroundColor(.gold)
                    .font(.system(size: 40))
                    .fontWeight(.heavy)
                    .padding(.top)
                
                HStack(alignment: .center) {
                    Spacer()
                    
                    VStack {
                        Text("Your Beautiful Artwork:")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.bottom)
                        
                        HStack(alignment: .center, spacing: 0) {
                            Image(uiImage: getImageFromDocuments("\(game.task.object).\(game.currentRound).png")!)
                                .resizable()
                                .aspectRatio(1.0, contentMode: .fit)
                                .frame(width: 175)
                                .cornerRadius(25)
                                .padding(.trailing)
                            
                            PercentCircle(percent: lastPlayerScore.truncate(places: 1))
                        }
                    }
                    
                    Spacer()
                    
                    Rectangle()
                        .foregroundColor(.white)
                        .frame(width: 7)
                        .cornerRadius(10)
                        .padding(.vertical, 70)
                    
                    Spacer()
                    
                    VStack {
                        Text(winner == .player ? "\"My plans are foiled!\"" : "\"Ha, ha! I win!\"")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.bottom)
                        
                        HStack(alignment: .center, spacing: 0) {
                            ZStack {
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            gradient: .init(colors: [.gray.opacity(0.6), .gray]),
                                            startPoint: .init(x: 0.25, y: 0.25),
                                        endPoint: .init(x: 0.5, y: 1)
                                        
                                    ))
                                    .aspectRatio(1.0, contentMode: .fit)
                                    .frame(width: 175)
                                    .cornerRadius(25)
                                
                                Image("robot")
                                    .scaleEffect(0.8)
                            }
                            .padding(.trailing)
                            
                            PercentCircle(percent: lastAIscore.truncate(places: 1), color: .red)
                        }
                    }
                    
                    Spacer()
                }
                
                HStack(spacing: 30) {
                    NavigationLink(destination: PlayerScoresView(game: game)) {
                        Text("View Round History")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        .modifier(RectangleWrapper(fixedHeight: 60, color: .gray, opacity: 1.0))
                        .frame(width: 375)
                    }
                    
                    Button(action: {
                        playAudio(fileName: "The Big Beat 80s (Spaced)", type: "wav")
                        isShowingGameSequence = false
                    }) {
                        Text("Return To Menu")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .modifier(RectangleWrapper(fixedHeight: 60, color: .blue, opacity: 1.0))
                            .frame(width: 375)
                    }
                }
                .padding(.bottom, 50)
            }
            .padding(.top)
        }
        .onAppear {
            // MARK: View Launch Code
            // Adjust the music
            stopAudio()
            if !hasPlayedJingle {
                playAudioOnce(fileName: winner == .player ? "Victory Jingle" : "Defeat Jingle", type: "mp3")
                hasPlayedJingle = true
            }
            
            // Award game-end achievements
            if winner == .player && game.difficulty == .easy && game.gameMode == .demystify {
                reportAchievementProgress("A_Minor_Test_of_Strength")
            }
            if winner == .player && game.difficulty == .lunatic && game.gameMode == .flyingBlind {
                reportAchievementProgress("A_Major_Test_of_Strength")
            }
            if winner == .player && game.currentRound == 1 {
                reportAchievementProgress("Formula_Won")
            }
            if winner == .AI && game.currentRound == 1 {
                reportAchievementProgress("Formula_Lost")
            }
            if game.currentRound >= 10 {
                reportAchievementProgress("The_Long_Haul")
            }
            if game.currentRound >= 20 {
                reportAchievementProgress("The_Really_Long_Haul")
            }
        }
        
        // MARK: Navigation Bar Settings
        .navigationBarBackButtonHidden(true)
    }
}

struct GameEndView_Previews: PreviewProvider {
    static var previews: some View {
        GameEndView(isShowingGameSequence: .constant(true), game: GameState(playerScores: [99.9], AIscores: [69.4]))
            .previewInterfaceOrientation(.landscapeLeft)
    }
}

struct PercentCircle: View {
    
    // Variables
    var percent: Double
    var circleWidth: CGFloat = 150
    var circleHeight: CGFloat = 150
    var color: Color = .green
    var font: Font = .largeTitle
    
    var body: some View {
        HStack(spacing: 50) {
            ZStack {
                Circle()
                    .foregroundColor(color)
                    .frame(width: circleWidth, height: circleHeight)
                
                Text("\(percent.description)%")
                    .font(font)
                    .fontWeight(.heavy)
            }
        }
    }
}
