//
//  TitleScreenView.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 4/7/22.
//

import Foundation
import SwiftUI

/// The entry point view for the app. Shows the main logo and a button to advance to the main menu.
struct TitleScreenView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image("Main Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 250)
                
                NavigationLink(destination: MainMenuView()) {
                    Text("Start Game")
                        .fontWeight(.bold)
                }
                .modifier(RectangleWrapper(fixedHeight: 50, color: .blue))
                .frame(width: 250)
                .padding(.top)
            }
            
            // MARK: Navigation View Settings
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // FIXME: Add app info
                        print("where's the info?")
                    }) {
                        Image(systemName: "info.circle")
                    }
                }
            })
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct TitleScreenView_Previews: PreviewProvider {
    static var previews: some View {
        TitleScreenView()
            .previewInterfaceOrientation(.landscapeRight)
    }
}
