//
//  MainMenuView.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 4/7/22.
//

import Foundation
import SwiftUI

/// The central navigation point for the app, containing links to New Game and Practice.
struct MainMenuView: View {
    var body: some View {
        HStack(spacing: 100) {
            VStack {
                NavigationLink(destination: NewGameMenuView()) {
                    Image("New Game Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 325)
                }
                
                Text("Description Text")
                    .padding(.top)
            }
            
            VStack {
                NavigationLink(destination: EmptyView()) {
                    Image("Practice Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 325)
                }
                
                Text("Description Text")
                    .padding(.top)
            }
        }
        .padding(.horizontal)
        
        // MARK: Navigation View Settings
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("ONE STEP AHEAD")
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}