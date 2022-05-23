//
//  MainMenuView.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 4/7/22.
//

import Foundation
import SwiftUI
import SpriteKit
import GameKit

/// The central navigation point for the app, containing links to New Game and the tutorial sequence.
struct MainMenuView: View {
    
    // MARK: View Variables
    /// Whether or not the user has finished the tutorial. This value is presisted inside UserDefaults.
    @AppStorage("hasFinishedTutorial") var hasFinishedTutorial = false
    /// Whether or not the tutorial sequence is being presented as a full screen modal.
    @State var isShowingTutorialSequence = false
    /// Whether or not the Game Center dashboard is being presented.
    @State var isShowingGameCenterDashboard = false
    /// Whether or not the Game Center information view is being presented.
    @State var isShowingGameCenterInfoView = false
    /// Whether or not the settings view is being presented.
    @State var isShowingSettings = false
    /// The tip currently being displayed at the bottom of the view.
    @State var tip = Tip.tipList.randomElement()!
    
    /// The amount of padding for each of the larger menu buttons.
    var bigSquarePadding = 0.0
    /// The amount of padding for each of the smaller menu buttons.
    var smallSquarePadding = 50.0
    
    var body: some View {
        ZStack {
            SpriteView(scene: SKScene(fileNamed: "Main Menu Graphics")!)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                
                HStack(spacing: 0) {
                    VStack {
                        Button(action: {
                            isShowingTutorialSequence = true
                        }) {
                            RotatingSquare(direction: .clockwise, firstColor: .green, secondColor: .mint, text: "TUTORIAL")
                                .padding(smallSquarePadding)
                        }
                        .fullScreenCover(isPresented: $isShowingTutorialSequence) {
                            BackstoryView(isShowingTutorialSequence: $isShowingTutorialSequence)
                        }
                        
                        Spacer()
                        
                        if GKLocalPlayer.local.isAuthenticated {
                            Button(action: {
                                isShowingGameCenterDashboard = true
                            }) {
                                RotatingSquare(direction: .clockwise, firstColor: .purple, secondColor: .pink, text: "GAME CENTER", imageAssetName: "Game Center Logo")
                                    .padding(smallSquarePadding)
                            }
                            .fullScreenCover(isPresented: $isShowingGameCenterDashboard) {
                                GameCenterDashboardView()
                                    .edgesIgnoringSafeArea(.all)
                            }
                        } else {
                            Button(action: {
                                isShowingGameCenterInfoView = true
                            }) {
                                ZStack {
                                    RotatingSquare(direction: .clockwise, firstColor: .gray, secondColor: .gray.opacity(0.5), text: "GAME CENTER", imageAssetName: "Game Center Logo")
                                        .padding(smallSquarePadding)
                                    
                                    Image("Black And White Game Center Logo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .opacity(0.7)
                                        .padding(smallSquarePadding)
                                        .padding()
                                        .padding()
                                }
                            }
                            .sheet(isPresented: $isShowingGameCenterInfoView) {
                                GameCenterInfoView()
                            }
                        }
                    }
                    
                    if hasFinishedTutorial {
                        NavigationLink(destination: NewGameMenuView()) {
                            RotatingSquare(direction: .clockwise, firstColor: .blue, secondColor: .cyan, text: "NEW GAME")
                                .padding(bigSquarePadding)
                        }
                        .padding(.top, 110)
                    } else {
                        RotatingSquare(direction: .clockwise, firstColor: .gray, secondColor: .gray.opacity(0.5), text: "NEW GAME", iconName: "lock.fill")
                            .padding(bigSquarePadding)
                            .padding(.top, 110)
                    }
                    
                    Rectangle()
                        .frame(width: 150, height: 100)
                        .hidden()
                    
                    if hasFinishedTutorial {
                        if GKLocalPlayer.local.isAuthenticated {
                            NavigationLink(destination: NewVersusGameMenuView()) {
                                RotatingSquare(direction: .counterclockwise, firstColor: .yellow, secondColor: .orange, text: "VERSUS")
                                    .padding(bigSquarePadding)
                            }
                            .padding(.top, 110)
                        } else {
                            Button(action: {
                                isShowingGameCenterInfoView = true
                            }) {
                                RotatingSquare(direction: .counterclockwise, firstColor: .yellow, secondColor: .orange, text: "VERSUS")
                                    .padding(bigSquarePadding)
                            }
                            .sheet(isPresented: $isShowingGameCenterInfoView) {
                                GameCenterInfoView()
                            }
                            .padding(.top, 110)
                        }
                    } else {
                        RotatingSquare(direction: .counterclockwise, firstColor: .gray, secondColor: .gray.opacity(0.5), text: "VERSUS", iconName: "lock.fill")
                            .padding(bigSquarePadding)
                        .padding(.top, 110)
                    }
                    
                    VStack {
                        if hasFinishedTutorial {
                            NavigationLink(destination: GalleryView()) {
                                RotatingSquare(direction: .counterclockwise, firstColor: .purple, secondColor: .indigo, text: "GALLERY")
                                    .padding(smallSquarePadding)
                            }
                        } else {
                            RotatingSquare(direction: .counterclockwise, firstColor: .gray, secondColor: .gray.opacity(0.5), text: "GALLERY", iconName: "lock.fill")
                                .padding(smallSquarePadding)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            isShowingSettings = true
                        }) {
                            RotatingSquare(direction: .counterclockwise, firstColor: .white, secondColor: .gray, text: "SETTINGS")
                                .padding(smallSquarePadding)
                        }
                        .sheet(isPresented: $isShowingSettings) {
                            SettingsView()
                        }
                    }
                }
                
                Spacer()
                
                DialogueView(isShowingAdvancePrompt: .constant(true), emojiImageName: tip.speakerEmoji, characterName: tip.speakerName, dialogue: tip.tipText, color1: tip.speakerPrimaryColor, color2: tip.speakerSecondaryColor, height: 120, advancePrompt: "Another Tip ➤")
                    .onTapGesture {
                        var candidateTip = Tip.tipList.randomElement()!
                        while candidateTip.tipText == tip.tipText {
                            candidateTip = Tip.tipList.randomElement()!
                        }
                        tip = candidateTip
                    }
                    .padding(.horizontal, 60)
            }
            .padding(.horizontal)
            
            VStack {
                HStack(spacing: 220) {
                    Image("Game Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .hidden()
                    
                    Image("Game Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    
                    Image("Game Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .hidden()
                }
                
                Spacer()
            }
            .padding(.top, 65)
        }
        .onAppear {
            // MARK: View Launch Code
            // If nothing is playing, start "The Big Beat 80s"
            if !(audioPlayer?.isPlaying ?? true) {
                playAudio(fileName: "The Big Beat 80s (Spaced)", type: "wav")
            }
        }
        
        // MARK: Navigation View Settings
        .navigationTitle("Main Menu")
        
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
