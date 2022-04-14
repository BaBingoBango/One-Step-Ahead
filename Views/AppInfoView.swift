//
//  AppInfoView.swift
//  
//
//  Created by Ethan Marshall on 4/13/22.
//

import SwiftUI

/// A view with some textual information about the app.
struct AppInfoView: View {
    
    // Variables
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Text("One Step Ahead!")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                
                Text("WWDC22 Swift Student Challenge Submission")
                    .padding(.top)
                
                Text("Version 1.0")
                    .padding(.top)
                
                Text("Created by Ethan Marshall")
                    .padding(.top)
            }
            
            // MARK: Navigation View Settings
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Done")
                            .fontWeight(.bold)
                    }
                }
            })
            
        }
    }
}

struct AppInfoView_Previews: PreviewProvider {
    static var previews: some View {
        AppInfoView()
    }
}
