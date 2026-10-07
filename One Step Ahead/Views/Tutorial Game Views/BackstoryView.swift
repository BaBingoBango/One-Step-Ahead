//
//  BackstoryView.swift
//  
//
//  Created by Ethan Marshall on 4/21/22.
//

import SwiftUI
import SpriteKit

/// The first view of the tutorial sequence, teling players about the game's backstory. It originates from the main menu view.
struct BackstoryView: View {
    @Environment(\.screenLayout) private var layout
    
    // Variables
    @Environment(\.dismiss) private var dismiss
    /// Whether or not the tutorial sequence is being presented as a full screen modal.
    @Binding var isShowingTutorialSequence: Bool
    /// Whether or not the tutorial game view is being presented.
    @State var isShowingTutorialGameView = false
    /// The state of the app's currently running game.
    @State var game: GameState = GameState(defaultCommandText: "Draw something you use to climb!")
    /// Whether or not the view is currently being collapsed by the End Game View.
    @State var isDismissing = false
    
    /// The SpriteKit scene for the graphics of this view.
    @State var graphicsScene = SKScene(fileNamed: "\(UIDevice.current.userInterfaceIdiom == .phone ? "iOS " : "")Backstory View Graphics")!
    
    var body: some View {
        NavigationStack {
            ZStack {
                GameBackground(scene: graphicsScene)
            }
            .onTapGesture {
                // Configure settings for the tutorial game
                game.task = DrawingTask.taskList.first(where: { $0.object == "Apple" })!
                game.gameMode = .cluedIn
                game.difficulty = .normal
                
                // Present the tutorial game
                game.shouldRunTimer = false
                isShowingTutorialGameView = true
            }
            
            // MARK: Navigation View Settings
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $isShowingTutorialGameView) {
                TutorialGameView(isShowingTutorialSequence: $isShowingTutorialSequence, game: game, commandText: game.defaultCommandText)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                        playAudio(fileName: "Lounge Drum and Bass", type: "mp3")
                    }) {
                        Text("Quit Tutorial")
                            .fontWeight(.bold)
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .onAppear {
            // MARK: View Launch Code
            stopAudio()
            if isDismissing {
                dismiss()
            }
        }
        .onDisappear {
            // MARK: View Vanish Code
            isDismissing = true
        }
        .dynamicTypeSize(.medium).statusBar(hidden: true)
        .onChange(of: layout.size, initial: true) { _, _ in
            // The story's longest line needs about 720 points of width before it starts getting cut off
            graphicsScene.fitArtwork(toWidth: layout.width, designedWidth: 720)
        }
    }
}

#Preview(traits: .landscapeLeft) {
    BackstoryView(isShowingTutorialSequence: .constant(true))
}
