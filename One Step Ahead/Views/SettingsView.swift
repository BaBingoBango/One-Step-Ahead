//
//  SettingsView.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 5/21/22.
//

import SwiftUI

struct SettingsView: View {
    
    // MARK: View Variables
    /// The presentation status variable for this view's modal presentation.
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    /// Whether or not the user has enabled Unlock Assist. This value is persisted inside UserDefaults.
    @AppStorage("isUnlockAssistOn") var isUnlockAssistOn = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Gallery"), footer: Text("Unlock Assist helps you make progress on the Gallery by forcing all new games to use drawings you haven't unlocked yet.")) {
                    Toggle("Unlock Assist", isOn: $isUnlockAssistOn)
                }
                
                Section(header: Text("Game Center")) {
                    HStack { Text("Status"); Spacer(); Text("??????").foregroundColor(.secondary) }
                }
                
                Section(header: Text("About")) {
                    HStack { Text("Game Version"); Spacer(); Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String).foregroundColor(.secondary) }
                    
                    HStack { Text("Build Number"); Spacer(); Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String).foregroundColor(.secondary) }
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
