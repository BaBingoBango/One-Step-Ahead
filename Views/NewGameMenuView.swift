//
//  NewGameMenuView.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 4/7/22.
//

import Foundation
import SwiftUI

/// The view for configuring a new game's options; originates from the main menu.
struct NewGameMenuView: View {
    
    // Variables
    /// The state of the app's currently running game.
    @State var game: GameState = GameState()
    
    var body: some View {
        VStack {
            
            Text("Choose Task Category")
                .font(.title)
                .fontWeight(.bold)
            
            HStack {
                Button(action: {
                    game.task.category = .drawing
                }) {
                    IconButtonView(imageName: "pencil.and.outline", text: "Drawing", isBlue: game.task.category == .drawing)
                }
                Button(action: {
                    game.task.category = .speech
                }) {
                    IconButtonView(imageName: "waveform", text: "Speech", isBlue: game.task.category == .speech)
                }
                Button(action: {
                    game.task.category = .handPoses
                }) {
                    IconButtonView(imageName: "hand.thumbsup.fill", text: "Hand Poses", isBlue: game.task.category == .handPoses)
                }
            }
            
            Text("Choose Difficulty")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)
            
            HStack {
                Button(action: {
                    game.difficulty = .easy
                }) {
                    Text("Easy")
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .modifier(RectangleWrapper(fixedHeight: 40, color: game.difficulty == .easy ? .green : nil))
                        .frame(width: 120)
                }
                Button(action: {
                    game.difficulty = .normal
                }) {
                    Text("Normal")
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .modifier(RectangleWrapper(fixedHeight: 40, color: game.difficulty == .normal ? .blue : nil))
                        .frame(width: 120)
                }
                Button(action: {
                    game.difficulty = .hard
                }) {
                    Text("Hard")
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .modifier(RectangleWrapper(fixedHeight: 40, color: game.difficulty == .hard ? .red : nil))
                        .frame(width: 120)
                }
            }
            
            HStack {
                Button(action: {
                    game.shouldDemystify = false
                }) {
                    Text("Standard Game")
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .modifier(RectangleWrapper(fixedHeight: 40, color: !game.shouldDemystify ? .blue : nil))
                        .frame(width: 185)
                }
                Button(action: {
                    game.shouldDemystify = true
                }) {
                    Text("Demystify!")
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .modifier(RectangleWrapper(fixedHeight: 40, color: game.shouldDemystify ? .purple : nil))
                        .frame(width: 185)
                }
            }
            .padding(.top, 5)
            
            Text("Let's Roll!")
                .fontWeight(.bold)
                .foregroundColor(Color.blue)
                .modifier(RectangleWrapper(fixedHeight: 50, color: .blue))
                .frame(width: 250)
                .padding(.top)
            
        }
        
        // MARK: Navigation View Settings
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("New Game")
    }
}

struct NewGameMenuView_Previews: PreviewProvider {
    static var previews: some View {
        NewGameMenuView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}

struct IconButtonView: View {
    
    // Variables
    var imageName: String
    var text: String
    var isBlue: Bool
    
    var body: some View {
        VStack {
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.primary)
                .frame(height: 30)
            
            Text(text)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.top, 5)
        }
        .modifier(RectangleWrapper(fixedHeight: 80, color: isBlue ? .blue : nil))
        .frame(width: 120)
    }
}
