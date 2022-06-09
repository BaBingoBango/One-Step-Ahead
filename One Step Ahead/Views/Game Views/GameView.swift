//
//  GameView.swift
//  
//
//  Created by Ethan Marshall on 4/7/22.
//

import SwiftUI
import PencilKit
import CoreML
import SpriteKit

/// The view displaying the elements of the currently running game; originates from the New Game screen.
struct GameView: View {
    
    // MARK: - Variables
    /// A wrapper for the user's task-related save data. This value is presisted inside UserDefaults.
    @AppStorage("userTaskRecords") var userTaskRecords: UserTaskRecords = UserTaskRecords()
    /// The presentation status variable for this view's modal presentation.
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    /// Whether or not the game sequence is being presented as a full screen modal.
    @Binding var isShowingGameSequence: Bool
    
    /// Whether or not the game end view is showing.
    @State private var isShowingGameEndView = false
    /// Whether or not the view is currently being collapsed by the End Game View.
    @State var isDismissing = false
    
    /// The state of the app's currently running game, passed in from the New Game screen.
    @State var game: GameState = GameState()
    /// A 0.1-second-interval timer responsible for triggering game events.
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    /// The current status of the end-of-round score evaluation process.
    @State var scoreEvaluationStatus : ScoreEvaluationStatus = .notEvaluating
    
    /// The text displaying at the top of the view under the round number.
    @State var commandText: String
    /// The text which displays in the AI's "canvas" area.
    @State var AItext = getIdleAIMessage()
    /// Whether or not the AI model is currently being trained.
    @State var isTrainingAImodel = false
    
    /// The UIKit view object for the drawing canvas.
    @State var canvasView = PKCanvasView()
    /// A list of all versions of the canvas; facilitates the Undo button.
    @State var allDrawings: [PKDrawing] = []
    /// Whether or not a canvas undo operation is currently taking place.
    @State var isDeletingDrawing = false
    
    // MARK: - Enumeration
    /// The different possible statuses of the end-of-round score evaluation process.
    enum ScoreEvaluationStatus {
        case notEvaluating
        case evaluating
        case evaluationComplete
    }
    
    // MARK: - View Body
    var body: some View {
        NavigationView {
            ZStack {
                // The programatically-triggered navigation link for the game end view
                NavigationLink(destination: GameEndView(isShowingGameSequence: $isShowingGameSequence, game: game), isActive: $isShowingGameEndView) { EmptyView() }
                
                SpriteView(scene: SKScene(fileNamed: "Game View Graphics")!)
                    .edgesIgnoringSafeArea(.all)
                
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
                            
                            HStack(spacing: 0) {
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
                                
                                Text("  /  \(game.playerWinThreshold)%")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                    .opacity(0.6)
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
                            
                            HStack {
                                if game.currentRound != 1 {
                                    Text("\(game.AIscores[game.currentRound - 2].truncate(places: 2).description)%")
                                        .font(.largeTitle)
                                        .fontWeight(.heavy)
                                        .foregroundColor(.red)
                                } else {
                                    Text("---")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.secondary)
                                }
                                
                                Text("  /  \(game.AIwinThreshold)%")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                                    .opacity(0.6)
                            }
                        }
                    }
                    .padding(.horizontal, 75)
                    
                    Text("Game Score")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.gold)
                    
                    Text(game.currentRound != 1 ? "\(game.gameScore) pts." : "---")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(game.currentRound != 1 ? .gold : .gray)
                    
                    Spacer()
                }
            }
            // MARK: Navigation View Settings
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        stopAudio()
                        playAudio(fileName: "The Big Beat 80s (Spaced)", type: "wav")
                        isShowingGameSequence = false
                    }) {
                        Text("Quit Game")
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
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
            if game.timeLeft == 0.0 && scoreEvaluationStatus == .notEvaluating {
                commandText = "Judging your drawing..."
                AItext = GameView.getTrainingAIMessage()
                isTrainingAImodel = true
            }
            
            // On the next 0.1 second, calculate the scores
            if game.timeLeft == -0.1 {
                scoreEvaluationStatus = .evaluating
                game.timeLeft = 0.0
                game.shouldRunTimer = false
                let canvasBounds = canvasView.bounds
                DispatchQueue.global(qos: .userInteractive).async {
                    evaluateScores(canvasBounds: canvasBounds)
                    scoreEvaluationStatus = .evaluationComplete
                }
            }
            
            // If we have finished scoring, finish out the round
            if game.timeLeft == 0.0 && scoreEvaluationStatus == .evaluationComplete {
                isTrainingAImodel = false
                scoreEvaluationStatus = .notEvaluating
                finishRound()
            }
        }
    }
    
    // MARK: - Functions
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
    ///Evaluates the user and AI scores for this round.
    ///
    /// > Warning: This function should be run in a background thread. While doing this is technically optional, it absolutely should be done, since the ML training can take a long time and will lag the main thread.
    func evaluateScores(canvasBounds: CGRect) {
        
        // Use the judge model to give the user a score
        var predictionProbabilities: [String : String] = [:]
        do {
            // Layer the drawing on top of a white background
            let background = UIColor.white.imageWithColor(width: canvasBounds.width, height: canvasBounds.height)
            let drawingImage = background.mergeWith(topImage: canvasView.drawing.image(from: canvasBounds, scale: UIScreen.main.scale).tint(with: .black)!)
            
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
        
        // Award drawing score-based achievements
        if game.playerScores.last! == 0.0 {
            reportAchievementProgress("Definitely_Not_Right")
        }
        if game.playerScores.last! == 100.0 {
            reportAchievementProgress("Beyond_a_Reasonable_Doubt")
        }
        if game.AIscores.last! == 0.0 {
            reportAchievementProgress("Runtime_Error")
        }
        if game.AIscores.last! == 100.0 {
            reportAchievementProgress("Skynet_Online")
        }
    }
    /// Updates the game state variables to end the current round of play (and possibly the entire game).
    func finishRound() {
        // Check if a winner exists
        if game.playerScores.last! > Double(game.playerWinThreshold) || game.AIscores.last! > Double(game.AIwinThreshold) {
            // If one does, the game is over!
            // Record the task and player score to the user's save data
            if !userTaskRecords.records.keys.contains(game.task.object) {
                // If the task is locked, unlock it
                userTaskRecords.records[game.task.object] = ["timesPlayed" : 0, "highScore" : 0]
                
                // Grant Gallery unlock-based achievements
                reportAchievementProgress("Art_Aficionado", progress: 1.0 / Double(Task.taskList.count) * 100.0 * 2)
                reportAchievementProgress("Museum_Curator", progress: 1.0 / Double(Task.taskList.count) * 100.0)
            }
            userTaskRecords.records[game.task.object]!["timesPlayed"]! += 1
            userTaskRecords.records[game.task.object]!["highScore"] = game.gameScore
            
            // Update the command, trigger the navigation link, and disable the timer
            commandText = "That's a wrap!"
            isShowingGameEndView = true
            game.shouldRunTimer = false
            game.timeLeft = -1
        } else {
            // If one dosen't, start a new round!
            setupNewRound()
        }
    }
    /// Gets a random message to use for the AI's box during drawing time.
    static func getIdleAIMessage() -> String {
        let messages: [String] = [
            "Chatting with Skynet...",
            "Plotting humanity's demise...",
            "01001000 01101001",
            "Learning binary...",
            "Debugging...",
            "Beep boop!",
            "Studying Da Vinci..."
        ]
        return messages.randomElement()!
    }
    /// Gets a random message to use for the AI's box during training time.
    static func getTrainingAIMessage() -> String {
        let messages: [String] = [
            "Learning your secrets...",
            "Studying your art...",
            "Admiring your masterpiece...",
            "Mixing paints...",
            "Copying over your shoulder...",
            "Infringing your copyright..."
        ]
        return messages.randomElement()!
    }
    
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(isShowingGameSequence: .constant(true), commandText: "Preview!")
            .previewInterfaceOrientation(.landscapeRight)
    }
}
