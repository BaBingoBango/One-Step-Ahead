//
//  SettingsView.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 5/21/22.
//

import SwiftUI
import GameKit

struct SettingsView: View {
    
    // MARK: View Variables
    /// The presentation status variable for this view's modal presentation.
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    /// Whether or not the user has enabled Unlock Assist. This value is persisted inside UserDefaults.
    @AppStorage("isUnlockAssistOn") var isUnlockAssistOn = false
    /// Whether or not the view has triggered the Game Center authentication process.
    @State var shouldAuthenticateWithGameCenter = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if shouldAuthenticateWithGameCenter {
                    RepresentableGameCenterAuthenticationController()
                }
                
                Form {
                    Section(header: Text("Gallery"), footer: Text("Unlock Assist helps you make progress on the Gallery by forcing all new games to use drawings you haven't unlocked yet.")) {
                        Toggle("Unlock Assist", isOn: $isUnlockAssistOn)
                    }
                    
                    if GKLocalPlayer.local.isAuthenticated {
                        Section(header: Text("Game Center")) {
                            HStack { Text("Status"); Spacer(); Text("Authenticated").foregroundColor(.secondary) }
                        }
                    } else {
                        Section(header: Text("Game Center"), footer: Text("If you would like to re-attempt Game Center sign-in, please completely restart the game.")) {
                            HStack { Text("Status"); Spacer(); Text("Not Authenticated").foregroundColor(.secondary) }
                        }
                    }
                    
                    Section(header: Text("About")) {
                        HStack { Text("Game Version"); Spacer(); Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String).foregroundColor(.secondary) }
                        
                        HStack { Text("Build Number"); Spacer(); Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String).foregroundColor(.secondary) }
                    }
                }
            }
            
            // MARK: Navigation View Settings
            .navigationTitle(Text("Settings"))
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
