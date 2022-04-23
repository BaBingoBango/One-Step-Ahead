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
    /// Whether or not the game sequence is being presented as a full screen modal.
    @State var isShowingGameSequence = false
    
    var body: some View {
        ZStack {
            SpriteView(scene: SKScene(fileNamed: "New Game Menu Graphics")!)
                .edgesIgnoringSafeArea(.all)
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
                                    game.gameMode = .demystify
                                    game.defaultCommandText = game.getDefaultCommandText()
                                }) {
                                    IconButtonView(imageName: "wand.and.stars.inverse", text: "Demystify", isBlue: game.gameMode == .demystify)
                                }
                                .padding(.leading, 100)
                                Button(action: {
                                    game.gameMode = .batch
                                    game.defaultCommandText = game.getDefaultCommandText()
                                }) {
                                    IconButtonView(imageName: "square.grid.2x2.fill", text: "Batch", isBlue: game.gameMode == .batch)
                                }
                                Button(action: {
                                    game.gameMode = .cluedIn
                                    game.defaultCommandText = game.getDefaultCommandText()
                                }) {
                                    IconButtonView(imageName: "person.fill.questionmark", text: "Clued In", isBlue: game.gameMode == .cluedIn)
                                }
                                Button(action: {
                                    game.gameMode = .flyingBlind
                                    game.defaultCommandText = game.getDefaultCommandText()
                                }) {
                                    IconButtonView(imageName: "eye.slash.fill", text: "Flying Blind", isBlue: game.gameMode == .flyingBlind)
                                }
                            }
                        }
                        Text(getGameModeDescription())
                            .font(.title3)
                            .fontWeight(.bold)
                            .frame(width: 350)
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
                                    IconButtonView(imageName: "bolt.fill", text: "Hard", isBlue: game.difficulty == .hard)
                                }
                                Button(action: {
                                    game.difficulty = .lunatic
                                }) {
                                    IconButtonView(imageName: "flame.fill", text: "Lunatic", isBlue: game.difficulty == .lunatic)
                                }
                            }
                        }
                        Text(getDifficultyDescription())
                            .font(.title3)
                            .fontWeight(.bold)
                            .frame(width: 350)
                            .padding(.horizontal, 100)
                            .padding(.bottom, 5)
                    }
                }
                .padding(.top)
                
                Button(action: {
                    isShowingGameSequence = true
                }) {
                    Text("Let's Roll!")
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                        .modifier(RectangleWrapper(fixedHeight: 50, color: .blue, opacity: 1.0))
                        .frame(width: 250)
                        .padding(.top, 50)
                }
                .fullScreenCover(isPresented: $isShowingGameSequence) {
                    GameView(isShowingGameSequence: $isShowingGameSequence, game: game, commandText: game.defaultCommandText)
                }
            }
        }
        .onChange(of: isShowingGameSequence) { newValue in
            if newValue == false {
                // Reset the current game state
                game = GameState()
                game.defaultCommandText = game.getDefaultCommandText()
            }
        }
        .onAppear {
            // MARK: View Launch Code
            // If nothing is playing, or if "Powerup!" is playing, start "The Big Beat 80s"
            if !audioPlayer!.isPlaying || audioPlayer!.url!.absoluteString.contains("Powerup") {
                stopAudio()
                playAudio(fileName: "The Big Beat 80s (Spaced)", type: "wav")
            }
            
            // Reset the current game state
            game = GameState()
            game.defaultCommandText = game.getDefaultCommandText()
        }
        
        // MARK: Navigation View Settings
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("New Game")
    }
    
    // MARK: View Functions
    func getGameModeDescription() -> String {
        switch game.gameMode {
        case .flyingBlind:
            return "The ultimate test of wits; try to draw the mystery object before the AI can with no hints whatsoever!"
        case .cluedIn:
            return "You'll have a generic description of what to draw; can your deductive skills beat the AI's computational skills?"
        case .batch:
            return "The correct drawing will be concealed amongst three fakes. Can you find it before the machine does?"
        case .demystify:
            return "You'll know what to draw right away; it's a true test of your skills as an artist!"
        }
    }
    func getDifficultyDescription() -> String {
        switch game.difficulty {
        case .easy:
            return "You'll only need 80% drawing accuracy to win; the AI will need 90% to win!"
        case .normal:
            return "Both you and the AI will need 90% drawing accuracy to win."
        case .hard:
            return "You'll need 97% drawing accuracy to win; the AI will only need 80% to win!"
        case .lunatic:
            return "The ultimate showdown; can you reach 99% accuracy before the machine reaches 50%?"
        }
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
