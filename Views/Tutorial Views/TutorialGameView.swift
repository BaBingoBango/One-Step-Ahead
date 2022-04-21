//
//  TutorialGameView.swift
//  
//
//  Created by Ethan Marshall on 4/21/22.
//

import SwiftUI
import SpriteKit
import PencilKit

/// The version of the game view used in the tutorial; it has dialogue and a much more guided feel.
struct TutorialGameView: View {
    
    // View Variables
    /// The ID number of the tutorial's current state. When the state ID is incremented, the view responds by changing UI elements appropriately.
    @State var stateID: Int = 1
    
    // Current State Variables
    /// The name of the emoji representation of the current speaker.
    @State var speakerEmoji = "radio"
    /// The name of the current speaker.
    @State var speakerName = "Old Radio"
    /// The current speaker's current dialogue.
    @State var speakerDialogue = "Incoming Transmission..."
    /// The current speaker's primary representation color.
    @State var speakerColor1: Color = .brown
    /// The current speaker's secondary representation color.
    @State var speakerColor2: Color = .yellow
    
    // Game View Variables
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    /// Whether or not the game end view is showing.
    @State private var isShowingGameEndView = false
    /// Whether or not the view is currently being collapsed by the End Game View.
    @State var isDismissing = false
    /// The state of the app's currently running game, passed in from the New Game screen.
    @State var game: GameState = GameState()
    /// A 0.1-second-interval timer responsible for triggering game events.
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    /// The text displaying at the top of the view under the round number.
    @State var commandText: String
    /// The text which displays in the AI's "canvas" area.
    @State var AItext = GameView.getIdleAIMessage()
    /// Whether or not the AI model is currently being trained.
    @State var isTrainingAImodel = false
    /// The UIKit view object for the drawing canvas.
    @State var canvasView = PKCanvasView()
    /// A list of all versions of the canvas; facilitates the Undo button.
    @State var allDrawings: [PKDrawing] = []
    /// Whether or not a canvas undo operation is currently taking place.
    @State var isDeletingDrawing = false
    
    var body: some View {
        ZStack {
            SpriteView(scene: SKScene(fileNamed: "Game View Graphics")!)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                VStack {
                    // MARK: Game View Start
                    VStack(spacing: 0) {
                        Text("- Round \(game.currentRound) -")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.bottom, 5)
                        
                        Text(commandText)
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.bottom, 5)
                        
                        Text(game.timeLeft.truncate(places: 1).description + "s")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                        
                        Spacer()
                        
                        HStack(alignment: .center, spacing: 37.5) {
                            VStack {
                                HStack(alignment: .bottom) {
                                    Text("You")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        // Undo the canvas
                                        // FIXME: Undo funtion might not be working
                                        isDeletingDrawing = true
                                        canvasView.drawing = allDrawings.count >= 2 ? allDrawings[allDrawings.count - 2] : PKDrawing()
                                        if allDrawings.count >= 1 {
                                            allDrawings.removeLast()
                                        }
                                        isDeletingDrawing = false
                                    }) {
                                        ZStack {
                                            Rectangle()
                                                .foregroundColor(.secondary)
                                                .cornerRadius(50)
                                            HStack {
                                                Image(systemName: "arrow.uturn.backward.circle")
                                                    .foregroundColor(.primary)
                                                
                                                Text("Undo")
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.primary)
                                            }
                                        }
                                    }
                                    .frame(width: 120, height: 40)
                                    .offset(y: 5)
                                }
                                .padding(.horizontal, 40)
                                
                                ZStack {
                                    Rectangle()
                                        .opacity(0.2)
                                        .aspectRatio(1.0, contentMode: .fit)
                                    
                                    CanvasView(canvasView: $canvasView, onSaved: {
                                        if !isDeletingDrawing {
                                            allDrawings.append(canvasView.drawing)
                                        }
                                    })
                                }
                                .aspectRatio(1.0, contentMode: .fit)
                                
                                Text("Current Score")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .padding(.top)
                                
                                if game.currentRound != 1 {
                                    Text("\(game.playerScores[game.currentRound - 2].description)%")
                                        .font(.largeTitle)
                                        .fontWeight(.heavy)
                                        .foregroundColor(.green)
                                } else {
                                    Text("---")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Text("VS")
                                .font(.largeTitle)
                                .fontWeight(.black)
                                .padding(.bottom, 48)
                            
                            VStack {
                                HStack {
                                    ZStack {
                                        Rectangle()
                                            .foregroundColor(.secondary)
                                            .cornerRadius(50)
                                        HStack {
                                            Image(systemName: "arrow.uturn.backward.circle")
                                                .foregroundColor(.primary)
                                            
                                            Text("Undo")
                                                .fontWeight(.bold)
                                                .foregroundColor(.primary)
                                        }
                                    }
                                    .frame(width: 120, height: 40)
                                    .offset(y: 5)
                                    .hidden()
                                    
                                    Spacer()
                                    
                                    Text("The Machine")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                }
                                .padding(.horizontal, 40)
                                
                                ZStack {
                                    Rectangle()
                                        .opacity(0.2)
                                        .aspectRatio(1.0, contentMode: .fit)
                                    
                                    VStack {
                                        if isTrainingAImodel {
                                            ProgressView()
                                                .scaleEffect(2.5)
                                                .progressViewStyle(CircularProgressViewStyle())
                                                .frame(width: 75, height: 75)
                                        } else {
                                            Image("robot")
                                                .resizable()
                                                .frame(width: 75, height: 75)
                                        }
                                        
                                        Text(AItext)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .padding(.top)
                                    }
                                }
                                
                                Text("Current Score")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .padding(.top)
                                
                                if game.currentRound != 1 {
                                    Text("\(game.AIscores[game.currentRound - 2].truncate(places: 2).description)%")
                                        .font(.largeTitle)
                                        .fontWeight(.heavy)
                                        .foregroundColor(.green)
                                } else {
                                    Text("---")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal, 75)
                        
                        Text("Your Win Threshold: \(game.playerWinThreshold)%")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                            .multilineTextAlignment(.center)
                            .opacity(0.7)
                            .frame(width: 350)
                        
                        Text("AI Win Threshold: \(game.AIwinThreshold)%")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .opacity(0.7)
                            .padding(.top, 5)
                            .frame(width: 350)
                        
                        Spacer()
                    }
                    // MARK: Game View End
                }
                
                Spacer()
                
                DialogueView(emojiImageName: speakerEmoji, characterName: speakerName, dialogue: speakerDialogue, color1: speakerColor1, color2: speakerColor2)
                    .onTapGesture {
                        moveToNextState()
                    }
                    .padding(.horizontal, 50)
                    .padding(.bottom)
            }
        }
    }
    
    // MARK: View Functions
    /// Transitions the UI to the state with the ID number one greater than the current ID number.
    func moveToNextState() {
        stateID += 1
        
        switch stateID {
            
        case 2:
            // Move from state 1 to 2
            speakerEmoji = "doctor"
            speakerName = "Dr. Jim Bake"
            speakerDialogue = "Hello? Can you hear me? ...Ah!"
            speakerColor1 = .blue
            speakerColor2 = .cyan
            
        case 3:
            // Move from state 2 to 3
            speakerDialogue = "Goooooooood mooooooorrrrrrning! So glad I found you! Now we can get to work stopping this machine!"
            
            
        case 4:
            // Move from state 3 to 4
            speakerDialogue = "AUGH"
            // FIXME: missing code
            
        default:
            // Restore the state to the default
            speakerEmoji = "radio"
            speakerName = "Old Radio"
            speakerDialogue = "Incoming Transmission..."
            speakerColor1 = .brown
            speakerColor2 = .yellow
            
        }
    }
    
}

struct TutorialGameView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialGameView(commandText: "Preview command text!")
            .previewInterfaceOrientation(.landscapeLeft)
    }
}

/// A view representing speech by a game character.
struct DialogueView: View {
    
    // Variables
    var emojiImageName: String
    var characterName: String
    var dialogue: String
    var color1: Color
    var color2: Color
    
    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: .init(colors: [color1, color2]),
                        startPoint: .init(x: 0.5, y: 0),
                        endPoint: .init(x: 0.5, y: 0.6)
                    ))
                
                Image(emojiImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 110, height: 110)
            }
            .frame(width: 170, height: 170)
            .padding(.trailing, -70)
            .foregroundColor(.gray)
            .zIndex(1)
            
            ZStack {
                Rectangle()
                    .frame(height: 145)
                    .cornerRadius(30)
                
                ZStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: .init(colors: [color1, color2]),
                            startPoint: .init(x: 0.5, y: 0),
                            endPoint: .init(x: 0.5, y: 0.6)
                        ))
                        .cornerRadius(10)
                    
                    Text(characterName)
                        .font(.title3)
                        .fontWeight(.heavy)
                }
                .frame(width: 200, height: 40)
                .padding(.bottom, 140)
                .padding(.trailing, 550)
                
                Text(dialogue)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .padding(.leading, 95)
                    .padding(.trailing)
                    .padding(.top, 7)
                
                Text("Tap ➤")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color1)
                    .padding(.top, 100)
                    .padding(.leading, 830)
            }
        }
    }
}
