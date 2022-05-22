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
    
    var body: some View {
        NavigationView {
            ZStack {
                SpriteView(scene: SKScene(fileNamed: "Title Screen Graphics")!)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Rectangle()
                        .frame(width: 350, height: 350)
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
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAppInfo = true
                    }) {
                        Image(systemName: "info.circle")
                    }
                    .sheet(isPresented: $showingAppInfo) {
                        AppInfoView()
                    }
                }
            })
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            // MARK: View Launch Code
            // Start the menu music
            playAudio(fileName: "The Big Beat 80s (Spaced)", type: "wav")
        }
    }
}

struct TitleScreenView_Previews: PreviewProvider {
    static var previews: some View {
        TitleScreenView()
            .previewInterfaceOrientation(.landscapeRight)
    }
}
