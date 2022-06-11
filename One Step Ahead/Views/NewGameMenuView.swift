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
    /// The presentation status variable for this view's modal presentation.
    @Environment(\.presentationMode) private var presentationMode
    /// A wrapper for the user's task-related save data. This value is presisted inside UserDefaults.
    @AppStorage("userTaskRecords") var userTaskRecords: UserTaskRecords = UserTaskRecords()
    /// Whether or not the user has enabled Unlock Assist. This value is persisted inside UserDefaults.
    @AppStorage("isUnlockAssistOn") var isUnlockAssistOn = true
    /// The game state object for the game this view will launch.
    @State var game: GameState = GameState()
    /// Whether or not the game sequence is being presented as a full screen modal.
    @State var isShowingGameSequence = false
    /// The object that games launched from this view should always use. If it is nil, the object should be random.
    var enforcedGameTask: Task? = nil
    /// Whether or not the view should include a "Return To Gallery" button.
    var shouldShowReturnToGalleryButton = false
    
    /// The SpriteKit scene for the graphics of this view.
    @State var graphicsScene = SKScene(fileNamed: "New Game Menu Graphics")!
    
    var body: some View {
        ZStack {
            SpriteView(scene: graphicsScene)
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
                                    IconButtonView(color: .green, imageName: "wand.and.stars.inverse", text: "Demystify", isColored: game.gameMode == .demystify)
                                }
                                .padding(.leading, 100)
                                Button(action: {
                                    game.gameMode = .batch
                                    game.defaultCommandText = game.getDefaultCommandText()
                                }) {
                                    IconButtonView(color: .blue, imageName: "square.grid.2x2.fill", text: "Batch", isColored: game.gameMode == .batch)
                                }
                                Button(action: {
                                    game.gameMode = .cluedIn
                                    game.defaultCommandText = game.getDefaultCommandText()
                                }) {
                                    IconButtonView(color: .orange, imageName: "person.fill.questionmark", text: "Clued In", isColored: game.gameMode == .cluedIn)
                                }
                                Button(action: {
                                    game.gameMode = .flyingBlind
                                    game.defaultCommandText = game.getDefaultCommandText()
                                }) {
                                    IconButtonView(color: .red, imageName: "eye.slash.fill", text: "Flying Blind", isColored: game.gameMode == .flyingBlind)
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
                                    IconButtonView(color: .green, imageName: "sun.max.fill", text: "Easy", isColored: game.difficulty == .easy)
                                }
                                .padding(.leading, 100)
                                Button(action: {
                                    game.difficulty = .normal
                                }) {
                                    IconButtonView(color: .blue, imageName: "leaf.fill", text: "Normal", isColored: game.difficulty == .normal)
                                }
                                Button(action: {
                                    game.difficulty = .hard
                                }) {
                                    IconButtonView(color: .orange, imageName: "bolt.fill", text: "Hard", isColored: game.difficulty == .hard)
                                }
                                Button(action: {
                                    game.difficulty = .lunatic
                                }) {
                                    IconButtonView(color: .red, imageName: "flame.fill", text: "Lunatic", isColored: game.difficulty == .lunatic)
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
                resetGameState()
            }
        }
        .onAppear {
            // MARK: View Launch Code
            // If nothing is playing, or if "Powerup!" is playing, start "The Big Beat 80s"
            if audioPlayer != nil {
                if !audioPlayer!.isPlaying || audioPlayer!.url!.absoluteString.contains("Powerup") {
                    stopAudio()
                    playAudio(fileName: "The Big Beat 80s", type: "wav")
                }
            }
            
            // Reset the current game state
            resetGameState()
        }
        
        // MARK: Navigation View Settings
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("New Game")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Return To Gallery")
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                .isHidden(!shouldShowReturnToGalleryButton, remove: true)
            }
        }
    }
    
    // MARK: View Functions
    /// Resets the game state so a new game can begin.
    func resetGameState() {
        // Save the current mode and difficulty
        let currentMode = game.gameMode
        let currentDifficulty = game.difficulty
        
        // Perform the reset and restore
        game = GameState()
        if enforcedGameTask == nil {
            // Pick a random task, considering Unlock Assist
            if isUnlockAssistOn {
                // Use Unlock Assist...
                var candidateTask = Task.taskList.randomElement()!
                // ...as long as there are drawings left to unlock
                if userTaskRecords.records.count == Task.taskList.count {
                    while userTaskRecords.records.keys.contains(candidateTask.object) {
                        candidateTask = Task.taskList.randomElement()!
                    }
                }
                game.task = candidateTask
            } else {
                // Don't use Unlock Assist
                game.task = Task.taskList.randomElement()!
            }
        } else {
            game.task = enforcedGameTask!
        }
        game.gameMode = currentMode
        game.difficulty = currentDifficulty
        game.defaultCommandText = game.getDefaultCommandText()
    }
    /// Gets the extended desxription for a game mode.
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
    /// Gets the extended description for a game difficulty.
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
    var color: Color = .blue
    var imageName: String = ""
    var text: String = ""
    var isColored: Bool = false
    var number: Int?
    
    var body: some View {
        VStack {
            Image(systemName: number == nil ? imageName : "\(number!).circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.primary)
                .frame(height: number == nil ? 30 : 40)
            
            if number == nil {
                Text(text)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.top, 5)
            }
        }
        .modifier(RectangleWrapper(fixedHeight: 80, color: isColored ? color : nil, opacity: isColored ? 1.0 : 0.1))
        .frame(width: 120)
    }
}
