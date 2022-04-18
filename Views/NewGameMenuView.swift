//
//  NewGameMenuView.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 4/7/22.
//

import Foundation
import SwiftUI
import SpriteKit

/// The view for configuring a new game's options; originates from the main menu.
struct NewGameMenuView: View {
    
    // Variables
    /// The state of the app's currently running game.
    @State var game: GameState = GameState()
    
    var body: some View {
        ZStack {
            SpriteView(scene: SKScene(fileNamed: "New Game Menu Graphics")!)
            VStack {
                
                VStack {
                    HStack(alignment: .bottom) {
                        VStack {
                            Text("Game Mode")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.leading, 100)
                            HStack {
                                Button(action: {
                                    game.shouldDemystify = true
                                }) {
                                    IconButtonView(imageName: "wand.and.stars.inverse", text: "Demystify", isBlue: game.shouldDemystify)
                                }
                                .padding(.leading, 100)
                                Button(action: {
                                    game.task.category = .speech
                                }) {
                                    IconButtonView(imageName: "leaf.fill", text: "Normal", isBlue: game.task.category == .speech)
                                }
                                Button(action: {
                                    game.task.category = .drawing
                                }) {
                                    IconButtonView(imageName: "eye.slash.fill", text: "Flying Blind", isBlue: game.task.category == .drawing)
                                }
                            }
                        }
                        Text("The ultimate test of wits; try to draw the mystery object before the AI can with no hints whatsoever!")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.horizontal, 100)
                            .padding(.bottom, 5)
                    }
                }
                
                VStack {
                    HStack(alignment: .bottom) {
                        VStack {
                            Text("Difficulty")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.leading, 100)
                            HStack {
                                Button(action: {
                                    game.difficulty = .easy
                                }) {
                                    IconButtonView(imageName: "sun.max.fill", text: "Easy", isBlue: game.difficulty == .easy)
                                }
                                .padding(.leading, 100)
                                Button(action: {
                                    game.difficulty = .normal
                                }) {
                                    IconButtonView(imageName: "leaf.fill", text: "Normal", isBlue: game.difficulty == .normal)
                                }
                                Button(action: {
                                    game.difficulty = .hard
                                }) {
                                    IconButtonView(imageName: "flame.fill", text: "Hard", isBlue: game.difficulty == .hard)
                                }
                            }
                        }
                        Text("The ultimate test of wits; try to draw the mystery object before the AI can with no hints whatsoever!")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.horizontal, 100)
                            .padding(.bottom, 5)
                    }
                }
                .padding(.top)
                
                NavigationLink(destination: GameView()) {
                    Text("Let's Roll!")
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                        .modifier(RectangleWrapper(fixedHeight: 50, color: .blue, opacity: 1.0))
                        .frame(width: 250)
                        .padding(.top, 50)
                }
                
            }
        }
        
        // MARK: Navigation View Settings
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("New Game")
    }
}

struct NewGameMenuView_Previews: PreviewProvider {
    static var previews: some View {
        NewGameMenuView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}

struct IconButtonView: View {
    
    // Variables
    var imageName: String
    var text: String
    var isBlue: Bool
    
    var body: some View {
        VStack {
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.primary)
                .frame(height: 30)
            
            Text(text)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.top, 5)
        }
        .modifier(RectangleWrapper(fixedHeight: 80, color: isBlue ? .blue : nil, opacity: isBlue ? 1.0 : 0.1))
        .frame(width: 120)
    }
}
