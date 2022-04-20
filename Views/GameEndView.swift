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
    /// The state of the app's currently running game, passed in from the Game View.
    @State var game: GameState
    
    var body: some View {
        ZStack {
            SpriteView(scene: SKScene(fileNamed: "Game End View Graphics")!)
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                Text("You win!")
                    .foregroundColor(.gold)
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
//                            Image(uiImage: getImageFromDocuments("\(game.task.object).\(game.currentRound).png")!)
//                                .resizable()
//                                .aspectRatio(1.0, contentMode: .fit)
//                                .frame(width: 175)
//                                .padding(.trailing)
                            Rectangle()
                                .aspectRatio(1.0, contentMode: .fit)
                                .frame(width: 175)
                                .padding(.trailing)
                            
                            PercentCircle(percent: 100.0)
                        }
                        
                        Text("View Previous Scores")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .modifier(RectangleWrapper(fixedHeight: 60, color: .blue, opacity: 1.0))
                            .frame(width: 425)
                            .padding(.top, 100)
                    }
                    
                    Spacer()
                    
                    Rectangle()
                        .foregroundColor(.white)
                        .frame(width: 7)
                        .cornerRadius(10)
                        .padding(.vertical, 70)
                    
                    Spacer()
                    
                    VStack {
                        Text("\"Witty AI response!\"")
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
                            
                            PercentCircle(percent: 100.0)
                        }
                        
                        Text("View AI Training Data")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .modifier(RectangleWrapper(fixedHeight: 60, color: .blue, opacity: 1.0))
                            .frame(width: 425)
                            .padding(.top, 100)
                    }
                    
                    Spacer()
                }
            }
            .padding(.top)
        }
        
        // MARK: Navigation Bar Settings
        .navigationBarBackButtonHidden(true)
    }
}

struct GameEndView_Previews: PreviewProvider {
    static var previews: some View {
        GameEndView(game: GameState())
            .previewInterfaceOrientation(.landscapeLeft)
    }
}

struct PercentCircle: View {
    
    // Variables
    var percent: Double
    
    var body: some View {
        HStack(spacing: 50) {
            ZStack {
                Circle()
                    .foregroundColor(.green)
                    .frame(width: 150, height: 150)
                
                Text("\(percent.description)%")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
            }
        }
    }
}
