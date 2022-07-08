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
    // FIXME: FIX!
    @AppStorage("hasFinishedTutorial") var hasFinishedTutorial = true
    /// Whether or not the tutorial sequence is being presented as a full screen modal.
    @State var isShowingTutorialSequence = false
    /// Whether or not the Game Center dashboard is being presented.
    @State var isShowingGameCenterDashboard = false
    /// Whether or not the Game Center information view is being presented.
    @State var isShowingGameCenterInfoView = false
    /// Whether or not the settings view is being presented.
    @State var isShowingSettings = false
    /// Whether or not to show the Versus button.
    @State var isShowingVersus = false
    /// The tip currently being displayed at the bottom of the view.
    @State var tip = Tip.tipList.randomElement()!
    
    /// The timer that manages the shared rotation of the clockwise square buttons.
    let clockwiseRotatingSquareTimer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    /// The current amount of degrees that each clockwise square button is rotated.
    @State var clockwiseRotationDegrees: Double = 0.0
    /// The timer that manages the shared rotation of the clockwise square buttons.
    let counterclockwiseRotatingSquareTimer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    /// The current amount of degrees that each clockwise square button is rotated.
    @State var counterclockwiseRotationDegrees: Double = 0.0
    
    /// The amount of padding for each of the larger menu buttons.
    var bigSquarePadding = 100.0
    /// The amount of padding for each of the smaller menu buttons.
    var smallSquarePadding = 80.0
    
    /// The SpriteKit scene for the graphics of this view.
    @State var graphicsScene = SKScene(fileNamed: "\(UIDevice.current.userInterfaceIdiom == .phone ? "iOS " : "")Main Menu Graphics")!
    
    var body: some View {
        ZStack {
            SpriteView(scene: graphicsScene)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                
                HStack(spacing: 0) {
                    Spacer()
                    
                    VStack {
                        Button(action: {
                            isShowingTutorialSequence = true
                        }) {
                            RotatingSquare(direction: .clockwise, firstColor: .green, secondColor: .mint, text: "TUTORIAL", iconName: "graduationcap.fill", rotationDegrees: $clockwiseRotationDegrees)
                        }
                        .fullScreenCover(isPresented: $isShowingTutorialSequence) {
                            BackstoryView(isShowingTutorialSequence: $isShowingTutorialSequence)
                        }
                        
                        RotatingSquare(direction: .clockwise, firstColor: .blue, secondColor: .blue, text: "", rotationDegrees: $clockwiseRotationDegrees)
                            .hidden()
                        
                        if GKLocalPlayer.local.isAuthenticated {
                            Button(action: {
                                isShowingGameCenterDashboard = true
                            }) {
                                RotatingSquare(direction: .clockwise, firstColor: .purple, secondColor: .pink, text: "GAME CENTER", imageAssetName: "Game Center Logo", rotationDegrees: $clockwiseRotationDegrees)
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
                                    RotatingSquare(direction: .clockwise, firstColor: .gray, secondColor: .gray.opacity(0.5), text: "GAME CENTER", imageAssetName: "Game Center Logo", rotationDegrees: $clockwiseRotationDegrees)
                                    
                                    if UIDevice.current.userInterfaceIdiom != .phone {
                                        Image("Black And White Game Center Logo")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .opacity(0.7)
                                            .padding()
                                            .padding()
                                    } else {
                                        Image("Black And White Game Center Logo")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .opacity(0.7)
                                            .padding()
                                    }
                                }
                            }
                            .sheet(isPresented: $isShowingGameCenterInfoView) {
                                GameCenterInfoView(isShowingVersus: $isShowingVersus)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    HStack {
                        if UIDevice.current.userInterfaceIdiom != .phone {
                            VStack {
                                RotatingSquare(direction: .clockwise, firstColor: .blue, secondColor: .blue, text: "", rotationDegrees: $clockwiseRotationDegrees)
                                RotatingSquare(direction: .clockwise, firstColor: .blue, secondColor: .blue, text: "", rotationDegrees: $clockwiseRotationDegrees)
                                RotatingSquare(direction: .clockwise, firstColor: .blue, secondColor: .blue, text: "", rotationDegrees: $clockwiseRotationDegrees)
                                RotatingSquare(direction: .clockwise, firstColor: .blue, secondColor: .blue, text: "", rotationDegrees: $clockwiseRotationDegrees)
                                RotatingSquare(direction: .clockwise, firstColor: .blue, secondColor: .blue, text: "", rotationDegrees: $clockwiseRotationDegrees)
                            }
                                .hidden()
                        }
                        
                        if hasFinishedTutorial {
                            NavigationLink(destination: NewGameMenuView()) {
                                RotatingSquare(direction: .clockwise, firstColor: .blue, secondColor: .cyan, text: "NEW GAME", iconName: "play.circle.fill", rotationDegrees: $clockwiseRotationDegrees)
                                    .padding()
                                    .padding()
                            }
                            .padding()
                        } else {
                            RotatingSquare(direction: .clockwise, firstColor: .gray, secondColor: .gray.opacity(0.5), text: "NEW GAME", iconName: "lock.fill", rotationDegrees: $clockwiseRotationDegrees)
                                .padding()
                                .padding()
                        }
                        
                        if UIDevice.current.userInterfaceIdiom != .phone {
                            VStack {
                                RotatingSquare(direction: .clockwise, firstColor: .blue, secondColor: .blue, text: "", rotationDegrees: $clockwiseRotationDegrees)
                                RotatingSquare(direction: .clockwise, firstColor: .blue, secondColor: .blue, text: "", rotationDegrees: $clockwiseRotationDegrees)
                                RotatingSquare(direction: .clockwise, firstColor: .blue, secondColor: .blue, text: "", rotationDegrees: $clockwiseRotationDegrees)
                                RotatingSquare(direction: .clockwise, firstColor: .blue, secondColor: .blue, text: "", rotationDegrees: $clockwiseRotationDegrees)
                                RotatingSquare(direction: .clockwise, firstColor: .blue, secondColor: .blue, text: "", rotationDegrees: $clockwiseRotationDegrees)
                            }
                                .hidden()
                        }
                    }
                    
                    Spacer()
                    
                    if isShowingVersus {
                        Rectangle()
                            .frame(width: 150, height: 100)
                            .hidden()
                        
                        if hasFinishedTutorial {
                            if GKLocalPlayer.local.isAuthenticated {
                                NavigationLink(destination: NewVersusGameMenuView()) {
                                    RotatingSquare(direction: .counterclockwise, firstColor: .yellow, secondColor: .orange, text: "VERSUS", rotationDegrees: $counterclockwiseRotationDegrees)
                                }
                                .padding(.top, 110)
                            } else {
                                Button(action: {
                                    isShowingGameCenterInfoView = true
                                }) {
                                    RotatingSquare(direction: .counterclockwise, firstColor: .yellow, secondColor: .orange, text: "VERSUS", rotationDegrees: $counterclockwiseRotationDegrees)
                                }
                                .sheet(isPresented: $isShowingGameCenterInfoView) {
                                    GameCenterInfoView(isShowingVersus: $isShowingVersus)
                                }
                                .padding(.top, 110)
                            }
                        } else {
                            RotatingSquare(direction: .counterclockwise, firstColor: .gray, secondColor: .gray.opacity(0.5), text: "VERSUS", iconName: "lock.fill", rotationDegrees: $counterclockwiseRotationDegrees)
                            .padding(.top, 110)
                        }
                    }
                    
                    VStack {
                        if hasFinishedTutorial {
                            NavigationLink(destination: GalleryView()) {
                                RotatingSquare(direction: .clockwise, firstColor: .purple, secondColor: .indigo, text: "GALLERY", iconName: "photo.artframe", rotationDegrees: $clockwiseRotationDegrees)
                            }
                        } else {
                            RotatingSquare(direction: .clockwise, firstColor: .gray, secondColor: .gray.opacity(0.5), text: "GALLERY", iconName: "lock.fill", rotationDegrees: $clockwiseRotationDegrees)
                        }
                        
                        RotatingSquare(direction: .clockwise, firstColor: .blue, secondColor: .blue, text: "", rotationDegrees: $clockwiseRotationDegrees)
                            .hidden()
                        
                        Button(action: {
                            isShowingSettings = true
                        }) {
                            RotatingSquare(direction: .clockwise, firstColor: .white, secondColor: .gray, text: "SETTINGS", iconName: "gearshape.fill", rotationDegrees: $clockwiseRotationDegrees)
                        }
                        .sheet(isPresented: $isShowingSettings) {
                            SettingsView()
                        }
                    }
                    
                    Spacer()
                }
                .padding(.vertical)
                
                Spacer()
                
                DialogueView(isShowingAdvancePrompt: .constant(true), emojiImageName: tip.speakerEmoji, characterName: tip.speakerName, dialogue: tip.tipText, color1: tip.speakerPrimaryColor, color2: tip.speakerSecondaryColor, height: UIDevice.current.userInterfaceIdiom != .phone ? 120 : 55, advancePrompt: "Another Tip ➤")
                    .onTapGesture {
                        var candidateTip = Tip.tipList.randomElement()!
                        while candidateTip.tipText == tip.tipText {
                            candidateTip = Tip.tipList.randomElement()!
                        }
                        tip = candidateTip
                    }
                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom != .phone ? 60 : 0)
            }
            .padding(.horizontal, UIDevice.current.userInterfaceIdiom != .phone ? 70 : 20)
        }
        .edgesIgnoringSafeArea(.top)
        
        // MARK: Square Button Rotation Timer Responses
        .onReceive(clockwiseRotatingSquareTimer) { input in
            clockwiseRotationDegrees += 0.1
        }
        .onReceive(counterclockwiseRotatingSquareTimer) { input in
            counterclockwiseRotationDegrees -= 0.1
        }
        .onAppear {
            // MARK: View Launch Code
            // If nothing is playing, start "Lounge Drum and Bass"
            if !(audioPlayer?.isPlaying ?? true) {
                playAudio(fileName: "Lounge Drum and Bass", type: "mp3")
            }
        }
        
        // MARK: Navigation View Settings
        .navigationTitle("Main Menu")
        
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MainMenuView()
        }
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
