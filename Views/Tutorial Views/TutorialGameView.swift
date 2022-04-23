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
    /// Whether or not the AI box is on-screen.
    @State var isShowingAIbox = false
    /// Whether or not the player box and "VS" text are on-screen.
    @State var isShowingPlayerBox = false
    /// Whether or not the round indicator is on-screen.
    @State var isShowingRoundIndicator = false
    /// Whether or not the timer is on-screen.
    @State var isShowingTimer = false
    /// Whether or not the "Tap" text is on-screen.
    @State var isShowingAdvancePrompt = true
    
    // Game View Variables
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    /// Whether or not the game end view is showing.
    @State private var isShowingGameEndView = false
    /// Whether or not the view is currently being collapsed by the End Game View.
    @State var isDismissing = false
    /// The state of the app's currently running game, passed in from the New Game screen.
    @State var game: GameState = GameState(shouldRunTimer: false)
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
            // The programatically-triggered navigation link for the game end view
            NavigationLink(destination: TutorialGameEndView(game: game), isActive: $isShowingGameEndView) { EmptyView() }
            
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
                            .isHidden(!isShowingRoundIndicator)
                        
                        Text(game.timeLeft.truncate(places: 1).description + "s")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .isHidden(!isShowingTimer)
                        
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
                                .padding(.horizontal, 85)
                                
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
                            .isHidden(!isShowingPlayerBox)
                            
                            Text("VS")
                                .font(.largeTitle)
                                .fontWeight(.black)
                                .padding(.bottom, 48)
                                .isHidden(!isShowingPlayerBox)
                            
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
                                .padding(.horizontal, 85)
                                
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
                                            .font(.headline)
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
                            .isHidden(!isShowingAIbox)
                        }
                        .padding(.horizontal, 75)
                        
                        Spacer()
                    }
                    // MARK: Game View End
                }
                
                Spacer()
                
                DialogueView(isShowingAdvancePrompt: $isShowingAdvancePrompt, emojiImageName: speakerEmoji, characterName: speakerName, dialogue: speakerDialogue, color1: speakerColor1, color2: speakerColor2)
                    .onTapGesture {
                        if stateID != 10 {
                            moveToNextState()
                        }
                    }
                    .padding(.horizontal, 50)
                    .padding(.bottom)
            }
        }
        .onAppear {
            // MARK: View Launch Code
            // Clear the documents and temporary directories
            clearFolder(getDocumentsDirectory().path)
            clearFolder(FileManager.default.temporaryDirectory.path)
            
            // Start the battle music if not dismissing
            if !isDismissing {
                stopAudio()
                playAudio(fileName: "Powerup!", type: "mp3")
            }
            
            // Dismiss the view if we are currently collapsing the navigation chain
            if isDismissing {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .onDisappear {
            // MARK: View Vanish Code
            // Mark the navigation chain as collapsing for later use by the game end view to close all the views at once
            isDismissing = true
        }
        .onReceive(timer) { input in
            // MARK: Timer Response
            
            // Update the on-screen timer if it's running
            if game.shouldRunTimer {
                // Decrease the on-screen timer if it's running
                if game.timeLeft - 0.1 <= 0 && !isTrainingAImodel {
                    // If the timer will be nonpositive, set it to zero
                    game.timeLeft = 0
                } else {
                    // Otherwise, decrease it normally
                    game.timeLeft -= 0.1
                }
            }
            
            // If the time has reached zero, update the UI
            if game.timeLeft == 0 {
                commandText = "Judging your drawing..."
                AItext = GameView.getTrainingAIMessage()
                isTrainingAImodel = true
            }
            
            // On the next 0.1 second, calculate the scores
            if game.timeLeft == -0.1 {
                evaluateScores()
            }
            
            // On the next 0.1 second, process the end of the round
            if game.timeLeft == -0.2 {
                isTrainingAImodel = false
                finishRound()
            }
        }
    }
    
    // MARK: Game View Functions
    /// Updates the game state variables to start a new round of play.
    func setupNewRound() {
        // Update the command and the AI text
        commandText = game.defaultCommandText
        AItext = GameView.getIdleAIMessage()
        
        // Reset the timer to 9.9 seconds
        game.timeLeft = 9.9
        
        // Reset the player canvas
        canvasView.drawing = PKDrawing()
        allDrawings = []
        
        // Update the round number
        game.currentRound += 1
        
        // Start the timer
        game.shouldRunTimer = true
    }
    /// This function should be run in a background thread. While doing this is technically optional, it absolutely should be done, since the ML training can take a long time and will lag the main thread.
    func evaluateScores() {
        
        // Use the judge model to give the user a score
        var predictionProbabilities: [String : String] = [:]
        do {
            // Layer the drawing on top of a white background
            let background = UIColor.white.imageWithColor(width: canvasView.bounds.width, height: canvasView.bounds.height)
            let drawingImage = background.mergeWith(topImage: canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale).tint(with: .black)!)
            
            // Save the image to the AI's training data
            saveImageToDocuments(drawingImage, name: "\(game.task.object).\(game.currentRound).png")
            
            // Get the probabilities for every drawing
            try ImagePredictor().makePredictions(for: drawingImage, completionHandler: { predictions in
                for eachPrediction in predictions! {
                    predictionProbabilities[eachPrediction.classification] = eachPrediction.confidencePercentage
                }
            })
            
            // Add the score to the game state
            game.playerScores.append(Double(predictionProbabilities[game.task.object]!)!)
        } catch {
            print("[Judge Model Prediction Error]")
            print(error.localizedDescription)
            print(error)
        }
        
        // Train a new AI model and get its training score, unless it is round 1, in which
        // case we simply copy the player score as the AI score. If the AI score to assign is NaN, use 0 as the score.
        let newAIscore = 50.0
        game.AIscores.append(newAIscore.isNaN ? 0.0 : newAIscore)
    }
    /// Updates the game state variables to end the current round of play (and possibly the entire game).
    func finishRound() {
        // Check if a winner exists
        if game.playerScores.last! > Double(game.playerWinThreshold) || game.AIscores.last! > Double(game.AIwinThreshold) {
            // If one does, update the command, trigger the navigation link, and disable the timer
            commandText = "That's a wrap!"
            isShowingGameEndView = true
            game.shouldRunTimer = false
            game.timeLeft = -1
        } else {
            // If one dosen't, start a new round!
            setupNewRound()
        }
    }
    
    // MARK: Tutorial-Specific View Functions
    /// Transitions the UI to the state with the ID number one greater than the current ID number.
    func moveToNextState() {
        stateID += 1
        
        switch stateID {
            
        case 2:
            // Move from state 1 to 2
            speakerEmoji = "doctor"
            speakerName = "Dr. Tim Bake"
            speakerDialogue = "Hello? Can you hear me? ...Ah!"
            speakerColor1 = .blue
            speakerColor2 = .cyan
            
        case 3:
            // Move from state 2 to 3
            speakerDialogue = "Goooooooood mooooooorrrrrrning! So glad I found you! Now we can get to work stopping this machine!"
            
        case 4:
            // Move from state 3 to 4
            speakerDialogue = "You see, the machine is bent on copying humans and taking over the world!"
            isShowingAIbox = true
            
        case 5:
            // Move ftom state 4 to 5
            speakerEmoji = "robot"
            speakerName = "The Machine"
            speakerDialogue = "Beep boop! I will learn your ways and destroy humanity!"
            speakerColor1 = .white
            speakerColor2 = .gray
            
        case 6:
            // Move from state 5 to 6
            speakerEmoji = "doctor"
            speakerName = "Dr. Tim Bake"
            speakerDialogue = "Oh dear. As you attempt to draw a mystery object, the machine will train an image classifier model, using all your attempts as the training data!"
            speakerColor1 = .blue
            speakerColor2 = .cyan
            
        case 7:
            // Move from state 6 to 7
            speakerDialogue = "To beat the machine, you'll have to learn how to draw the mystery object before the machine learning model figures it out from your guesses!"
            isShowingPlayerBox = true
            
        case 8:
            // Move from state 7 to 8
            speakerDialogue = "Let's give it a go! You'll have 15 seconds to draw each round. After that, the machine will copy your art for its training data, and the judge model will evaluate both you and the AI!"
        case 9:
            // Move from state 8 to 9
            speakerDialogue = "All right, here we go! Once you tap, you'll have 15 seconds to try and draw \"something that chops\" with 97% accuracy or higher!"
            
        case 10:
            // Move from state 9 to 10
            speakerDialogue = "Go, go, go! Draw something that chops with 97% accuracy or better! The machine only needs 80% accuracy!"
            isShowingAdvancePrompt = false
            
            // Start the game
            isShowingRoundIndicator = true
            isShowingTimer = true
            game.shouldRunTimer = true
            
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

struct TutorialGameView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialGameView(commandText: "Preview command text!")
            .previewInterfaceOrientation(.landscapeLeft)
    }
}

/// A view representing speech by a game character.
struct DialogueView: View {
    
    // Variables
    @Binding var isShowingAdvancePrompt: Bool
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
                
                HStack {
                    VStack {
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
                        Spacer()
                    }
                    Spacer()
                }
                .frame(height: 184)
                .padding(.leading, 75)
                
                Text(dialogue)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .padding(.horizontal, 90)
                    .padding(.trailing)
                    .padding(.top, 7)
                
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        Text("Tap ➤")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(color1 != .white ? color1 : .gray)
                            .isHidden(!isShowingAdvancePrompt)
                    }
                }
                .frame(height: 145)
                .padding([.bottom, .trailing])
            }
        }
    }
}
