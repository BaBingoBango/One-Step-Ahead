//
//  GameView.swift
//  
//
//  Created by Ethan Marshall on 4/7/22.
//

import SwiftUI
import PencilKit
import CoreML

/// The view displaying the elements of the currently running game; originates from the New Game screen.
struct GameView: View {
    
    // MARK: - Variables
    /// The state of the app's currently running game, passed in from the New Game screen.
    @State var game: GameState = GameState()
    /// A 0.1-second-interval timer responsible for triggering game events.
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    /// The text displaying at the top of the view under the round number.
    @State var commandText = "Draw the mystery object!"
    // FIXME: Update AI box to something else
    /// The text which displays in the AI's "canvas" area.
    @State var AItext = "Chatting with Skynet..."
    /// Whether or not the Done! button should be active.
    @State var isDoneButtonEnabled = false
    /// Whether or not the AI model is currently being trained.
    @State var isTrainingAImodel = false
    
    /// The UIKit view object for the drawing canvas.
    @State var canvasView = PKCanvasView()
    /// A list of all versions of the canvas; facilitates the Undo button.
    @State var allDrawings: [PKDrawing] = []
    /// Whether or not a canvas undo operation is currently taking place.
    @State var isDeletingDrawing = false
    
    // MARK: - View Body
    var body: some View {
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
                        Spacer()
                        Text("The Machine")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    ZStack {
                        Rectangle()
                            .opacity(0.2)
                            .aspectRatio(1.0, contentMode: .fit)
                        
                        VStack {
                            if isTrainingAImodel {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            }
                            
                            Text(AItext)
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
            
            Text("Done!")
                .fontWeight(.bold)
                .foregroundColor(isDoneButtonEnabled ? .blue : .gray)
                .modifier(RectangleWrapper(fixedHeight: 50, color: isDoneButtonEnabled ? .blue : .black))
                .frame(width: 250)
                .disabled(!isDoneButtonEnabled)
            
            Spacer()
        }
        .onAppear {
            // MARK: View Launch Code
            // Clear the documents and temporary directories
            clearFolder(getDocumentsDirectory().path)
            clearFolder(FileManager.default.temporaryDirectory.path)
            
            // Start the battle music
            stopAudio()
            playAudio(fileName: "Powerup!", type: "mp3")
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
                AItext = "Learning your secrets..."
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
    
    // MARK: - Functions
    /// Updates the game state variables to start a new round of play.
    func setupNewRound() {
        // Update the command and the AI text
        commandText = "Draw the mystery object!"
        AItext = "Chatting with Skynet!"
        
        // Reset the timer to 9.9 seconds
        game.timeLeft = 9.9
        
        // Reset the player canvas
        canvasView.drawing = PKDrawing()
        allDrawings = []
        
        // Enable canvas editing
        // FIXME: No code
        
        // Update the round number
        game.currentRound += 1
        
        // Enable the Done! button
        isDoneButtonEnabled = true
        
        // Start the timer
        game.shouldRunTimer = true
    }
    /// Uses machine learning to produce and update scores for the player and AI.
    /// - Parameter completionHandler: Code to execute once scores have been assigned.
    ///
    /// This function should be run in a background thread. While doing this is technically optional, it absolutely should be done, since the ML training can take a long time and will lag the main thread.
    func evaluateScores() {
        
        // Use the judge model to give the user a score
        var predictionProbabilities: [String : String] = [:]
        do {
            // Layer the drawing on top of a white background
            let background = UIColor.white.imageWithColor(width: canvasView.bounds.width, height: canvasView.bounds.height)
            let drawingImage = background.mergeWith(topImage: canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale))
            
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
//        let newAIscore = getAIscore()
        let newAIscore = 0.0
        game.AIscores.append(newAIscore.isNaN ? 0.0 : newAIscore)
    }
    /// Updates the game state variables to end the current round of play (and possibly the entire game).
    func finishRound() {
        // Check if a winner exists
        // FIXME: Add custom threshold
        if game.playerScores.last! > 100 || game.AIscores.last! > 100 {
            // If one does, update the command
            // FIXME: Add a better game-end event
            commandText = game.playerScores.last! >= game.AIscores.last! ? "You win!" : "The machine wins..."
        } else {
            // If one dosen't, start a new round!
            setupNewRound()
        }
    }
    
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
