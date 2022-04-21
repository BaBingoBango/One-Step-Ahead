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
    /// The state of the app's currently running game, passed in from the Game View.
    @State var game: GameState
    
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
        if lastPlayerScore >= lastAIscore {
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
                                .padding(.trailing)
                            
                            PercentCircle(percent: lastPlayerScore)
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
                                
                                Image("robot")
                                    .scaleEffect(0.8)
                            }
                            .padding(.trailing)
                            
                            PercentCircle(percent: lastAIscore, color: .red)
                        }
                    }
                    
                    Spacer()
                }
                
                HStack(spacing: 10) {
                    NavigationLink(destination: PlayerScoresView(game: game)) {
                        Text("View Round History")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .modifier(RectangleWrapper(fixedHeight: 60, color: .gray, opacity: 1.0))
                    .frame(width: 375)
                    
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
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
        
        // MARK: Navigation Bar Settings
        .navigationBarBackButtonHidden(true)
    }
}

struct GameEndView_Previews: PreviewProvider {
    static var previews: some View {
        GameEndView(game: GameState(playerScores: [99.9], AIscores: [69.4]))
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
