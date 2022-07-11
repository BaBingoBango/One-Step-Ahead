//
//  SettingsView.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 5/21/22.
//

import SwiftUI
import GameKit
import MessageUI

struct SettingsView: View {
    
    // MARK: View Variables
    /// The presentation status variable for this view's modal presentation.
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    /// Whether or not the user has enabled Unlock Assist. This value is persisted inside UserDefaults.
    @AppStorage("isUnlockAssistOn") var isUnlockAssistOn = true
    /// Whether or not the user has enabled Auto-Upload. This value is persisted inside UserDefaults.
    @AppStorage("isAutoUploadOn") var isAutoUploadOn = false
    /// Whether or not the view has triggered the Game Center authentication process.
    @State var shouldAuthenticateWithGameCenter = false
    /// Whether or not the mail sender view is being presented.
    @State var isShowingMailSender = false
    /// Whether or not the feedback email has been copied yet.
    @State var hasCopiedFeedbackEmail = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if shouldAuthenticateWithGameCenter {
                    RepresentableGameCenterAuthenticationController()
                }
                
                Form {
                    Section(header: Text("Gallery"), footer: Text("Unlock Assist helps you make progress on the Gallery by forcing all new games to use drawings you haven't unlocked yet.")) {
                        Toggle("Unlock Assist", isOn: $isUnlockAssistOn)
                            .onChange(of: isUnlockAssistOn) { newValue in
                                // If the toggle is disabled, grant an achievement
                                if newValue == false {
                                    reportAchievementProgress("Look_Mom_No_Hands")
                                }
                            }
                    }
                    
                    Section(header: Text("Drawing Central"), footer: Text("With Auto-Upload enabled, your drawings will automatically be uploaded to Drawing Central after you finish games.")) {
                        Toggle("Auto-Upload", isOn: $isAutoUploadOn)
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
                    
                    Section(header: Text("Feedback")) {
                        if MFMailComposeViewController.canSendMail() {
                            Button(action: {
                                isShowingMailSender = true
                            }) {
                                HStack { Image(systemName: "exclamationmark.bubble.fill").imageScale(.large); Text("Send Feedback Mail") }
                            }
                            .sheet(isPresented: $isShowingMailSender) {
                                MailSenderView(recipients: ["proper.griffon-0s@icloud.com"], subject: "One Step Ahead Feedback", body: "Please provide your feedback below. Feature suggestions, bug reports, and more are all appreciated! :)\n\n(If applicable, you may be contacted for more information or for follow-up questions.)\n\n\n")
                            }
                        } else {
                            Button(action: {
                                UIPasteboard.general.string = "proper.griffon-0s@icloud.com"
                                hasCopiedFeedbackEmail = true
                            }) {
                                HStack { Image(systemName: "exclamationmark.bubble.fill").imageScale(.large); Text(!hasCopiedFeedbackEmail ? "Copy Feedback Email" : "Feedback Email Copied!") }
                            }
                        }
                        
                        Link(destination: URL(string: "https://apps.apple.com/us/app/one-step-ahead/id1620737001")!) {
                            HStack { Image(systemName: "star.bubble.fill").imageScale(.large); Text("Rate on the App Store") }
                        }
                    }
                    
                    Section(header: Text("Resources")) {
                        Link(destination: URL(string: "https://github.com/BaBingoBango/One-Step-Ahead/wiki/Privacy-Policy")!) {
                            HStack { Image(systemName: "hand.raised.fill").imageScale(.large); Text("Privacy Policy") }
                        }
                        
                        Link(destination: URL(string: "https://github.com/BaBingoBango/One-Step-Ahead/wiki/Support-Center")!) {
                            HStack { Image(systemName: "questionmark.circle.fill").imageScale(.large); Text("Support Center") }
                        }
                        
                        Link(destination: URL(string: "https://github.com/BaBingoBango/One-Step-Ahead")!) {
                            HStack { Image(systemName: "curlybraces").imageScale(.large); Text("One Step Ahead on GitHub") }
                        }
                    }
                    
                    Section(header: Text("About")) {
                        NavigationLink(destination: LicensingView()) {
                            Text("Licensing and Credit")
                        }
                        
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
        .dynamicTypeSize(.medium).statusBar(hidden: true)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
