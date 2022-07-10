//
//  TitleScreenView.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 4/7/22.
//

import Foundation
import SwiftUI
import SpriteKit
import GameKit

/// The entry point view for the app. Shows the main logo and a button to advance to the main menu.
struct TitleScreenView: View {
    
    // MARK: View Variables
    /// Whether or not GameKit has completed the Game Center authentication process.
    @AppStorage("hasAuthenticatedWithGameCenter") var hasAuthenticatedWithGameCenter: Bool = false
    /// Whether or not the app info view is being presented.
    @State var showingAppInfo = false
    
    /// The SpriteKit scene for the graphics of this view.
    @State var graphicsScene = SKScene(fileNamed: "\(UIDevice.current.userInterfaceIdiom == .phone ? "iOS " : "")Title Screen Graphics")!
    
    var body: some View {
        NavigationView {
            ZStack {
                SpriteView(scene: graphicsScene)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Rectangle()
                        .frame(width: UIDevice.current.userInterfaceIdiom != .phone ? 350 : 150, height: UIDevice.current.userInterfaceIdiom != .phone ? 350 : 150)
                        .hidden()
                    
                    if hasAuthenticatedWithGameCenter {
                        NavigationLink(destination: MainMenuView()) {
                            Text("Start Game")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .modifier(RectangleWrapper(fixedHeight: 50, color: .blue, opacity: 1.0))
                                .frame(width: 250)
                        }
                        .padding(.top)
                    } else {
                        ZStack {
                            Text("")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
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
        .dynamicTypeSize(.medium)
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            // MARK: View Launch Code
            // Start the menu music
            playAudio(fileName: "Lounge Drum and Bass (Spaced)", type: "mp3")
        }
    }
}

struct TitleScreenView_Previews: PreviewProvider {
    static var previews: some View {
        TitleScreenView()
            .previewInterfaceOrientation(.landscapeRight)
    }
}
