//
//  TutorialGameEndView.swift
//  
//
//  Created by Ethan Marshall on 4/22/22.
//

import SwiftUI
import SpriteKit

struct TutorialGameEndView: View {
    
    // View Variables
    /// The ID number of the tutorial's current state. When the state ID is incremented, the view responds by changing UI elements appropriately.
    @State var stateID: Int = 1
    /// Whether or not the tutorial sequence is being presented as a full screen modal.
    @Binding var isShowingTutorialSequence: Bool
    /// Whether or not the user has finished the tutorial. This value is presisted inside UserDefaults.
    @AppStorage("hasFinishedTutorial") var hasFinishedTutorial = false
    /// Whether or not the victory/defeat jingle has played.
    @State var hasPlayedJingle = false
    
    // Current State Variables
    /// The name of the emoji representation of the current speaker.
    @State var speakerEmoji = "doctor"
    /// The name of the current speaker.
    @State var speakerName = "Dr. Tim Bake"
    /// The current speaker's current dialogue.
    @State var speakerDialogue = "Hi ho! That's a wrap, then!"
    /// The current speaker's primary representation color.
    @State var speakerColor1: Color = .blue
    /// The current speaker's secondary representation color.
    @State var speakerColor2: Color = .cyan
    
    // Game End View Variables
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    /// The state of the app's currently running game, passed in from the Game View.
    @State var game: GameState
    
    /// The SpriteKit scene for the graphics of this view.
    @State var graphicsScene = SKScene(fileNamed: "Game End View Graphics")!
    
    // Computed Properties
    /// The player score from the last round of play.
    var lastPlayerScore: Double {
        game.playerScores.last ?? 69.3974934
    }
    /// The AI score from the last round of play.
    var lastAIscore: Double {
        game.AIscores.last ?? 69.098765
    }
    var winner: Combatant {
        if lastPlayerScore >= lastAIscore && lastPlayerScore >= Double(game.playerWinThreshold) {
            return .player
        } else {
            return .AI
        }
    }
    
    // Enumeration
    /// The types of combatants in a game, that is, the player and the AI.
    enum Combatant {
        case player
        case AI
    }
    
    var body: some View {
        ZStack {
            SpriteView(scene: graphicsScene)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // MARK: Game End View START
                VStack(spacing: 0) {
                    Text(winner == .player ? "You win!" : "You lose...")
                        .foregroundColor(winner == .player ? .gold : .red)
                        .font(.system(size: 70))
                        .fontWeight(.black)
                        .padding(.top)
                    Text("Correct Drawing: \(game.task.object)")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .padding(.top, 3)
                    
                    HStack(alignment: .center) {
                        Spacer()
                        
                        VStack {
                            Text("Your Beautiful Artwork:")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.bottom)
                            
                            HStack(alignment: .center, spacing: 0) {
                                Image(uiImage: getImageFromDocuments("\(game.task.object).\(game.currentRound).png")!)
                                    .resizable()
                                    .aspectRatio(1.0, contentMode: .fit)
                                    .frame(width: 175)
                                    .cornerRadius(25)
                                    .padding(.trailing)
                                
                                PercentCircle(percent: lastPlayerScore.truncate(places: 1))
                            }
                        }
                        
                        Spacer()
                        
                        Rectangle()
                            .foregroundColor(.white)
                            .frame(width: 7)
                            .cornerRadius(10)
                            .padding(.vertical, 70)
                        
                        Spacer()
                        
                        VStack {
                            Text(winner == .player ? "\"My plans are foiled!\"" : "\"Ha, ha! I win!\"")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.bottom)
                            
                            HStack(alignment: .center, spacing: 0) {
                                ZStack {
                                    Rectangle()
                                        .fill(
                                            LinearGradient(
                                                gradient: .init(colors: [.gray.opacity(0.6), .gray]),
                                                startPoint: .init(x: 0.25, y: 0.25),
                                            endPoint: .init(x: 0.5, y: 1)
                                            
                                        ))
                                        .aspectRatio(1.0, contentMode: .fit)
                                        .frame(width: 175)
                                        .cornerRadius(25)
                                    
                                    Image("robot")
                                        .scaleEffect(0.8)
                                }
                                .padding(.trailing)
                                
                                PercentCircle(percent: lastAIscore.truncate(places: 1), color: .red)
                            }
                        }
                        
                        Spacer()
                    }
                }
                .padding(.top)
                // MARK: Game End View END
                
                Spacer()
                
                DialogueView(isShowingAdvancePrompt: .constant(true), emojiImageName: speakerEmoji, characterName: speakerName, dialogue: speakerDialogue, color1: speakerColor1, color2: speakerColor2)
                    .onTapGesture {
                        if stateID != 7 {
                            moveToNextState()
                        }
                    }
                    .padding(.horizontal, 50)
                    .padding(.bottom)
            }
        }
        .onAppear {
            // MARK: View Launch Code
            stopAudio()
            if !hasPlayedJingle {
                playAudioOnce(fileName: winner == .player ? "Victory Jingle" : "Defeat Jingle", type: "mp3")
                hasPlayedJingle = true
            }
        }
        
        // MARK: Navigation Bar Settings
        .navigationBarBackButtonHidden(true)
    }
    
    // View Functions
    /// Transitions the UI to the state with the ID number one greater than the current ID number.
    func moveToNextState() {
        stateID += 1
        
        switch stateID {
            
        case 2:
            // Move from state 1 to 2
            speakerDialogue = winner == .player ? "Congratulations on defeating the machine! However, I'm sorry to say that this is only the beginning..." : "Too bad! Sorry you weren't able to defeat the machine this time. Luckily, there will plenty of opportunities in the future!"
            
        case 3:
            // Move from state 2 to 3
            speakerEmoji = "robot"
            speakerName = "The Machine"
            speakerDialogue = winner == .player ? "I will return for your demise! Beep boop..." : "That's right! I'll be back for more! Boop beep!"
            speakerColor1 = .white
            speakerColor2 = .gray
            
        case 4:
            // Move from state 3 to 4
            speakerEmoji = "doctor"
            speakerName = "Dr. Tim Bake"
            speakerDialogue = winner == .player ? "You see! We have not won just yet. Now, it is up to you to select NEW GAME and defeat the machine in all its many forms!" : "With the machine coming back, we still have a chance! It's up to you now to select NEW GAME and challenge the machine once more! You can do it!"
            speakerColor1 = .blue
            speakerColor2 = .cyan
            
        case 5:
            // Move from state 4 to 5
            speakerDialogue = "It's time for me to go for now. Good luck out there! Thanks for playing, and remember to stay one step ahead of the machine! :)"
            
        case 6:
            // Move ftom state 5 to 6
            speakerEmoji = "radio"
            speakerName = "Old Radio"
            speakerDialogue = "Transmission concluded."
            speakerColor1 = .brown
            speakerColor2 = .yellow
            
        case 7:
            // Award tutorial achievements
            reportAchievementProgress("First_Step_Ahead")
            if hasFinishedTutorial {
                reportAchievementProgress("Back_to_Basics")
            }
            
            // End the tutorial sequence and return to the main menu
            playAudio(fileName: "Lounge Drum and Bass", type: "mp3")
            hasFinishedTutorial = true
            isShowingTutorialSequence = false
            
        default:
            // Place the view in an invalid/bad state (we should never arrive here)
            speakerEmoji = ""
            speakerName = "---"
            speakerDialogue = ""
            speakerColor1 = .gray
            speakerColor2 = .gray
            
        }
    }
    
}

struct TutorialGameEndView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialGameEndView(isShowingTutorialSequence: .constant(true), game: GameState())
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
