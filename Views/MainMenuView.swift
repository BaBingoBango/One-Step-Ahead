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
                VStack(spacing: -30) {
                    NavigationLink(destination: NewGameMenuView()) {
                        RotatingSquare(direction: .clockwise, firstColor: .blue, secondColor: .cyan, text: "NEW GAME")
                            .padding(90)
                    }
                    
                    Text("Who can learn faster? You or a computer? Race to find out and finish a drawing before the AI model does!")
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.top)
                }
                
                VStack(spacing: -30) {
                    NavigationLink(destination: EmptyView()) {
                        RotatingSquare(direction: .counterclockwise, firstColor: .green, secondColor: .mint, text: "TUTORIAL")
                            .padding(90)
                    }
                    
                    Text("Your machine combat journey begins here. Learn the ropes of One Step Ahead and machine learning all at once!")
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.top)
                }
            }
            .padding(.horizontal)
        }
        // MARK: Navigation View Settings
        .navigationTitle("Main Menu")
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
