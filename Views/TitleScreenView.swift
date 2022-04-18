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
    
    // Variables
    @State var showingAppInfo = false
    
    var body: some View {
        NavigationView {
            ZStack {
                SpriteView(scene: SKScene(fileNamed: "Title Screen Graphics")!)
                VStack {
                    Image("Main Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 350)
                        .hidden()
                    
                    NavigationLink(destination: MainMenuView()) {
                        Text("Start Game")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .modifier(RectangleWrapper(fixedHeight: 50, color: .blue, opacity: 1.0))
                            .frame(width: 250)
                    }
                    .padding(.top)
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
