//
//  TitleScreenView.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 4/7/22.
//

import Foundation
import SwiftUI
import SpriteKit

/// The entry point view for the app. Shows the main logo and a button to advance to the main menu.
struct TitleScreenView: View {
    @Environment(\.screenLayout) private var layout
    
    // MARK: View Variables
    /// Whether or not GameKit has completed the Game Center authentication process.
    @AppStorage("hasAuthenticatedWithGameCenter") var hasAuthenticatedWithGameCenter: Bool = false
    
    /// The SpriteKit scene for the graphics of this view.
    @State var graphicsScene = SKScene(fileNamed: "\(UIDevice.current.userInterfaceIdiom == .phone ? "iOS " : "")Title Screen Graphics")!
    
    var body: some View {
        NavigationStack {
            ZStack {
                GameBackground(scene: graphicsScene)
                VStack {
                    Rectangle()
                        .frame(width: layout.isRegular ? 350 : 150, height: layout.isRegular ? 350 : 150)
                        .hidden()
                    
                    if hasAuthenticatedWithGameCenter {
                        NavigationLink(destination: MainMenuView()) {
                            Text("Start Game")
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .modifier(RectangleWrapper(fixedHeight: 50, color: .blue, opacity: 1.0))
                                .frame(width: 250)
                        }
                        .padding(.top)
                    } else {
                        ZStack {
                            Text("")
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .modifier(RectangleWrapper(fixedHeight: 50, color: .gray, opacity: 1.0))
                                .frame(width: 250)
                            
                            ProgressView()
                        }
                        .padding(.top)
                    }
                }
            }
            
            // MARK: Navigation View Settings
            .navigationBarTitleDisplayMode(.inline)
            
        }
        .dynamicTypeSize(.medium).statusBar(hidden: true)
        .onAppear {
            // MARK: View Launch Code
            // Start the menu music
            playAudio(fileName: "Lounge Drum and Bass (Spaced)", type: "mp3")
        }
        .onChange(of: layout.size, initial: true) { _, _ in
            // The title artwork needs about 760 points of width before it starts getting cut off
            graphicsScene.fitArtwork(toWidth: layout.width, designedWidth: 760)
        }
    }
}

#Preview(traits: .landscapeRight) {
    TitleScreenView()
}
