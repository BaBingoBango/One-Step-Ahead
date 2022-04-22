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
    /// Whether or not the tutorial game view is being presented.
    @State var isShowingTutorialGameView = false
    /// The state of the app's currently running game.
    @State var game: GameState = GameState()
    
    var body: some View {
        ZStack {
            NavigationLink(destination: TutorialGameView(game: game, commandText: game.defaultCommandText), isActive: $isShowingTutorialGameView) { EmptyView() }
            
            SpriteView(scene: SKScene(fileNamed: "Backstory View Graphics")!)
                .edgesIgnoringSafeArea(.all)
        }
        .onTapGesture {
            game.shouldRunTimer = false
            game.task = Task.taskList.first(where: { $0.object == "Door" })!
            isShowingTutorialGameView = true
        }
    }
}

struct BackstoryView_Previews: PreviewProvider {
    static var previews: some View {
        BackstoryView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
