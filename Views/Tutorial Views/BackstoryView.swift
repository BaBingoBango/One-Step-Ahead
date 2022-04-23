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
    
    // Variables
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    /// Whether or not the tutorial game view is being presented.
    @State var isShowingTutorialGameView = false
    /// The state of the app's currently running game.
    @State var game: GameState = GameState()
    /// Whether or not the view is currently being collapsed by the End Game View.
    @State var isDismissing = false
    
    var body: some View {
        ZStack {
            NavigationLink(destination: TutorialGameView(game: game, commandText: game.defaultCommandText), isActive: $isShowingTutorialGameView) { EmptyView() }
            
            SpriteView(scene: SKScene(fileNamed: "Backstory View Graphics")!)
                .edgesIgnoringSafeArea(.all)
        }
        .onTapGesture {
            // Configure settings for the tutorial game
            game.task = Task.taskList.first(where: { $0.object == "Axe" })!
            game.gameMode = .cluedIn
            game.difficulty = .hard
            
            // Present the tutorial game
            game.shouldRunTimer = false
            isShowingTutorialGameView = true
        }
        .onAppear {
            // MARK: View Launch Code
            stopAudio()
            if isDismissing {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .onDisappear {
            // MARK: View Vanish Code
            isDismissing = true
        }
    }
}

struct BackstoryView_Previews: PreviewProvider {
    static var previews: some View {
        BackstoryView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
