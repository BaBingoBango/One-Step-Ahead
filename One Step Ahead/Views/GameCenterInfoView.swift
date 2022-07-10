//
//  GameCenterInfoView.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 5/21/22.
//

import SwiftUI

/// A view with information about signing in to Game Center.
struct GameCenterInfoView: View {
    
    // Variables
    @Environment(\.presentationMode) private var presentationMode
    /// Whether or not to show the Versus button.
    @Binding var isShowingVersus: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    Image("Game Center Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIDevice.current.userInterfaceIdiom != .phone ? 130 : UIScreen.main.bounds.width / 8)
                        .padding(.bottom, 20)
                    
                    Text("Game Center")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                    
                    HStack {
                        Text("Game Center Features")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }
                        .padding(.top)
                    
                    HStack {
                        Text("If you are not signed in to Game Center, you be unable to access the following Game Center-powered services:")
                        Spacer()
                    }
                    .padding(.top, 5)
                    
                    if isShowingVersus {
                        HStack(spacing: 50) {
                            VStack {
                                HStack(spacing: 30) {
                                    Image("Achievements Icon")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .padding(5)
                                        .frame(width: 60, height: 60)
                                    
                                    Text("Achievements")
                                        .font(.title)
                                        .fontWeight(.bold)
                                }
                                    .padding(.top)
                                
                                HStack(spacing: 30) {
                                    Image("Leaderboards Icon")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .padding(5)
                                        .frame(width: 60, height: 60)
                                    
                                    Text("Leaderboards")
                                        .font(.title)
                                        .fontWeight(.bold)
                                }
                            }
                            
                            VStack {
                                HStack(spacing: 30) {
                                    Image(systemName: "person.2.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .padding(1)
                                        .foregroundColor(.white)
                                        .frame(width: 60, height: 60)
                                    
                                    Text("Multiplayer")
                                        .font(.title)
                                        .fontWeight(.bold)
                                }
                                    .padding(.top)
                                
                                HStack(spacing: 30) {
                                    Image(systemName: "flag.filled.and.flag.crossed")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(.white)
                                        .frame(width: 60, height: 60)
                                    
                                    Text("Challenges")
                                        .font(.title)
                                        .fontWeight(.bold)
                                }
                            }
                        }
                        .padding(.top)
                    } else {
                        HStack(spacing: 35) {
                            VStack {
                                Image("Achievements Icon")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding(5)
                                    .frame(width: 60, height: 60)
                                
                                Image("Leaderboards Icon")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding(5)
                                    .frame(width: 60, height: 60)
                                    .padding(.top, 5)
                                
                                Image(systemName: "flag.filled.and.flag.crossed")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .padding(.top, 5)
                            }
                            
                            VStack(spacing: 35) {
                                Text("Achievements")
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Text("Leaderboards")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .padding(.top, 5)
                                
                                Text("Challenges")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .padding(.top, 5)
                            }
                        }
                        .padding(.top, 40)
                    }
                    
                    HStack {
                        Text("Signing In")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }
                        .padding(.top, 30)
                    
                    HStack {
                        Text("To sign in to Game Center, visit the Settings app and select Game Center. From there, sign in with an Apple ID, at which point you will automatically be authenticated by Game Center for One Step Ahead!")
                        Spacer()
                    }
                    .padding(.top, 5)
                    
                    HStack {
                        Link(destination: URL(string: "https://support.apple.com/en-us/HT210401")!) {
                            Text("To learn more about Game Center, tap here to visit Apple Support on the web.")
                                .multilineTextAlignment(.leading)
                                .font(.headline)
                                .foregroundColor(Color.blue)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical)
                }
                .padding(.horizontal)
                .padding(.horizontal)
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
        .dynamicTypeSize(.medium)
        .navigationViewStyle(.stack)
    }
}

struct GameCenterInfoView_Previews: PreviewProvider {
    static var previews: some View {
        GameCenterInfoView(isShowingVersus: .constant(false))
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
