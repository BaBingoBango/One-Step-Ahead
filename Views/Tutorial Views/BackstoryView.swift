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
    @State var isShowingTutorialGameView = false
    
    var body: some View {
        ZStack {
            NavigationLink(destination: EmptyView(), isActive: $isShowingTutorialGameView) { EmptyView() }
            
            SpriteView(scene: SKScene(fileNamed: "Backstory View Graphics")!)
                .edgesIgnoringSafeArea(.all)
        }
        .onTapGesture {
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
