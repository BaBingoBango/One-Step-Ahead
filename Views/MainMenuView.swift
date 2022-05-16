//
//  MainMenuView.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 4/7/22.
//

import Foundation
import SwiftUI
import SpriteKit

/// The central navigation point for the app, containing links to New Game and the tutorial sequence.
struct MainMenuView: View {
    
    // MARK: View Variables
    /// Whether or not the user has finished the tutorial. This value is presisted inside UserDefaults.
    @AppStorage("hasFinishedTutorial") var hasFinishedTutorial = false
    /// Whether or not the tutorial sequence is being presented as a full screen modal.
    @State var isShowingTutorialSequence = false
    /// The tip currently being displayed at the bottom of the view.
    @State var tip = Tip.tipList.randomElement()!
    
    var body: some View {
        ZStack {
            SpriteView(scene: SKScene(fileNamed: "Main Menu Graphics")!)
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack(spacing: 100) {
                    if hasFinishedTutorial {
                        VStack(spacing: -30) {
                            NavigationLink(destination: NewGameMenuView()) {
                                RotatingSquare(direction: .clockwise, firstColor: .blue, secondColor: .cyan, text: "NEW GAME")
                                    .padding(120)
                            }
                            
                            Text("Who can learn faster - you or a computer? Race to find out and finish a drawing before the AI model does!")
                                .font(.title3)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .padding(.top)
                        }
                    } else {
                        VStack(spacing: -30) {
                            ZStack {
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            gradient: .init(colors: [.gray, .gray.opacity(0.5)]),
                                        startPoint: .init(x: 0.5, y: 0),
                                        endPoint: .init(x: 0.5, y: 0.6)
                                        
                                    ))
                                    .aspectRatio(1.0, contentMode: .fit)
                                
                                VStack {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.white)
                                        .font(.largeTitle)
                                        .offset(y: -10)
                                    
                                    Text("NEW GAME")
                                        .foregroundColor(.white)
                                        .font(.largeTitle)
                                        .fontWeight(.heavy)
                                        .multilineTextAlignment(.center)
                                }
                            }
                                .padding(120)
                            
                            Text("In order to play games with all the game modes and difficulties, you'll need to complete the tutorial!")
                                .font(.title3)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .padding(.top)
                        }
                    }
                    
                    VStack(spacing: -30) {
                        Button(action: {
                            isShowingTutorialSequence = true
                        }) {
                            RotatingSquare(direction: .counterclockwise, firstColor: .green, secondColor: .mint, text: "TUTORIAL")
                                .padding(120)
                        }
                        .fullScreenCover(isPresented: $isShowingTutorialSequence) {
                            BackstoryView(isShowingTutorialSequence: $isShowingTutorialSequence)
                        }
                        
                        Text("Your machine combat journey begins here. Learn the ropes of One Step Ahead and machine learning all at once!")
                            .font(.title3)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding(.top)
                    }
                }
                
                Spacer()
                
                DialogueView(isShowingAdvancePrompt: .constant(true), emojiImageName: tip.speakerEmoji, characterName: tip.speakerName, dialogue: tip.tipText, color1: tip.speakerPrimaryColor, color2: tip.speakerSecondaryColor, height: 120, advancePrompt: "Another Tip ➤")
                    .onTapGesture {
                        var candidateTip = Tip.tipList.randomElement()!
                        while candidateTip.tipText == tip.tipText {
                            candidateTip = Tip.tipList.randomElement()!
                        }
                        tip
                        = candidateTip
                    }
                    .padding(.horizontal, 60)
            }
            .padding(.horizontal)
        }
        .onAppear {
            // MARK: View Launch Code
            // If nothing is playing, start "The Big Beat 80s"
            if !audioPlayer!.isPlaying {
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
