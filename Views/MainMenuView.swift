//
//  MainMenuView.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 4/7/22.
//

import Foundation
import SwiftUI
import SpriteKit

/// The central navigation point for the app, containing links to New Game and Practice.
struct MainMenuView: View {
    var body: some View {
        ZStack {
            SpriteView(scene: SKScene(fileNamed: "Main Menu Graphics")!)
            HStack(spacing: 100) {
                VStack {
                    NavigationLink(destination: NewGameMenuView()) {
                        RotatingSquare(firstColor: .blue, secondColor: .cyan, text: "NEW GAME")
                            .padding(90)
                    }
                    
                    Text("Description Text")
                        .padding(.top)
                }
                
                VStack {
                    NavigationLink(destination: EmptyView()) {
                        RotatingSquare(firstColor: .green, secondColor: .mint, text: "PRACTICE")
                            .padding(90)
                    }
                    
                    Text("Description Text")
                        .padding(.top)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
