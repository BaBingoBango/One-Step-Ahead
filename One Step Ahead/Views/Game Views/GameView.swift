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
    /// The number of games the user has won to date.
    @AppStorage("gamesWon") var gamesWon: Int = 0
    /// The presentation status variable for this view's modal presentation.
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    /// Whether or not the game sequence is being presented as a full screen modal.
    @Binding var isShowingGameSequence: Bool
    
    /// Whether or not the game end view is showing.
    @State private var isShowingGameEndView = false
    /// Whether or not the view is currently being collapsed by the End Game View.
    @State var isDismissing = false
    
    /// Whether or not the game is paused and the pause menu is showing.
    @State var isGamePaused = false
    
    /// The state of the app's currently running game, passed in from the New Game screen.
    @State var game: GameState = GameState()
    /// A 0.1-second-interval timer responsible for triggering game events.
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    /// The current status of the end-of-round score evaluation process.
    @State var scoreEvaluationStatus: ScoreEvaluationStatus = .notEvaluating
    /// Whether or not the drawing canvas is disabled.
    @State var isCanvasDisabled = false
    
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
    
    /// The SpriteKit scene for the graphics of this view.
    @State var graphicsScene = SKScene(fileNamed: "\(UIDevice.current.userInterfaceIdiom == .phone ? "iOS " : "")Game View Graphics")!
    
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
                
                SpriteView(scene: graphicsScene)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    VStack {
                        VStack(spacing: 0) {
                            Text("- Round \(game.currentRound) -")
                                .font(UIDevice.current.userInterfaceIdiom != .phone ? .largeTitle : .title3)
                                .fontWeight(.bold)
                                .padding(.bottom, 5)
                                .padding(.top, UIDevice.current.userInterfaceIdiom != .phone ? 20 : 0)
                            
                            Text(commandText)
                                .font(UIDevice.current.userInterfaceIdiom != .phone ? .title : .body)
                                .fontWeight(.bold)
                                .padding(.bottom, 5)
                            
                            Text(game.timeLeft.truncate(places: 1).description + "s")
                                .font(UIDevice.current.userInterfaceIdiom != .phone ? .largeTitle : .title3)
                                .fontWeight(.heavy)
                            
                            Spacer()
                            
                            HStack(alignment: .center, spacing: 30) {
//                                Spacer()
                                
                                VStack {
                                    ZStack {
                                        ZStack {
                                            Rectangle()
                                                .opacity(0.2)
                                                .aspectRatio(1.0, contentMode: .fit)
                                                .foregroundColor(.blue)
                                                .hidden()
                                            
                                            VStack {
                                                HStack {
                                                    Text("You")
                                                        .font(UIDevice.current.userInterfaceIdiom != .phone ? .title2 : .callout)
                                                        .fontWeight(.bold)
                                                        .lineLimit(1)
                                                        .minimumScaleFactor(0.1)
                                                    
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
                                                            if UIDevice.current.userInterfaceIdiom != .phone {
                                                                Rectangle()
                                                                    .foregroundColor(.secondary)
                                                                    .cornerRadius(50)
                                                            } else {
                                                                Circle()
                                                                    .foregroundColor(.secondary)
                                                            }
                                                            HStack {
                                                                Image(systemName: "arrow.uturn.backward.circle")
                                                                    .foregroundColor(.primary)
                                                                
                                                                if UIDevice.current.userInterfaceIdiom != .phone {
                                                                    Text("Undo")
                                                                        .fontWeight(.bold)
                                                                        .foregroundColor(.primary)
                                                                }
                                                            }
                                                        }
                                                    }
                                                    .frame(width: UIDevice.current.userInterfaceIdiom != .phone ? 120 : 30, height: UIDevice.current.userInterfaceIdiom != .phone ? 40 : 10)
                                                    .offset(y: UIDevice.current.userInterfaceIdiom != .phone ? -5 : 0)
                                                }
                                                
                                                Spacer()
                                            }
                                        }
                                        .aspectRatio(1.0, contentMode: .fit)
                                        .offset(y: UIDevice.current.userInterfaceIdiom != .phone ? -40 : -25)
                                        
                                        if !isCanvasDisabled {
                                            Rectangle()
                                                .opacity(0.2)
                                                .aspectRatio(1.0, contentMode: .fit)
                                        }
                                        
                                        CanvasView(canvasView: $canvasView, onSaved: {
                                            if !isDeletingDrawing {
                                                allDrawings.append(canvasView.drawing)
                                            }
                                        })
                                        .disabled(isCanvasDisabled)
                                        
                                        if isCanvasDisabled {
                                            Rectangle()
                                                .opacity(0.2)
                                                .aspectRatio(1.0, contentMode: .fit)
                                        }
                                    }
                                    .aspectRatio(1.0, contentMode: .fit)
                                    .padding(.top, UIDevice.current.userInterfaceIdiom != .phone ? 45 : 0)
                                    
                                    Text("Current Score")
                                        .font(UIDevice.current.userInterfaceIdiom != .phone ? .title : .body)
                                        .fontWeight(.bold)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.1)
                                        .padding(.top)
                                    
                                    HStack(spacing: 0) {
                                        if game.currentRound != 1 {
                                            Text("\(game.playerScores[game.currentRound - 2].description)%")
                                                .font(UIDevice.current.userInterfaceIdiom != .phone ? .largeTitle : .title3)
                                                .fontWeight(.heavy)
                                                .foregroundColor(.green)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.1)
                                        } else {
                                            Text("---")
                                                .font(UIDevice.current.userInterfaceIdiom != .phone ? .title : .title3)
                                                .fontWeight(.bold)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.1)
                                        }
                                        
                                        Text("  /  \(game.playerWinThreshold)%")
                                            .font(UIDevice.current.userInterfaceIdiom != .phone ? .title2 : .body)
                                            .fontWeight(.bold)
                                            .foregroundColor(.green)
                                            .opacity(0.6)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.1)
                                    }
                                }
                                
//                                Spacer()
                                
                                Text("VS")
                                    .font(.largeTitle)
                                    .fontWeight(.black)
                                    .padding(.bottom, 48)
                                
//                                Spacer()
                                
                                VStack {
                                    ZStack {
                                        ZStack {
                                            Rectangle()
                                                .opacity(0.2)
                                                .aspectRatio(1.0, contentMode: .fit)
                                                .foregroundColor(.blue)
                                                .hidden()
                                            
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
                                                    .isHidden(true, remove: true)
                                                    
                                                    Spacer()
                                                    
                                                    Text("The Machine")
                                                        .font(UIDevice.current.userInterfaceIdiom != .phone ? .title2 : .callout)
                                                        .fontWeight(.bold)
                                                        .lineLimit(1)
                                                        .minimumScaleFactor(0.1)
                                                }
                                                
                                                Spacer()
                                            }
                                        }
                                        .aspectRatio(1.0, contentMode: .fit)
                                        .offset(y: UIDevice.current.userInterfaceIdiom != .phone ? -40 : -25)
                                        
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
                                                        .frame(width: UIDevice.current.userInterfaceIdiom != .phone ? 75 : 35, height: UIDevice.current.userInterfaceIdiom != .phone ? 75 : 35)
                                                }
                                                
                                                Text("Hello!")
                                                    .font(UIDevice.current.userInterfaceIdiom != .phone ? .custom("Roboto Mono", size: 20) : .custom("Roboto Mono", size: 10))
                                                    .fontWeight(.bold)
                                                    .multilineTextAlignment(.center)
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.1)
                                                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom != .phone ? 0 : 10)
                                            }
                                        }
                                    }
                                    .padding(.top, UIDevice.current.userInterfaceIdiom != .phone ? 45 : 0)
                                    
                                    Text("Current Score")
                                        .font(UIDevice.current.userInterfaceIdiom != .phone ? .title : .body)
                                        .fontWeight(.bold)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.1)
                                        .padding(.top)
                                    
                                    HStack {
                                        if game.currentRound != 1 {
                                            Text("\(game.AIscores[game.currentRound - 2].truncate(places: 2).description)%")
                                                .font(UIDevice.current.userInterfaceIdiom != .phone ? .largeTitle : .title3)
                                                .fontWeight(.heavy)
                                                .foregroundColor(.red)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.1)
                                        } else {
                                            Text("---")
                                                .font(UIDevice.current.userInterfaceIdiom != .phone ? .title : .title3)
                                                .fontWeight(.bold)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.1)
                                        }
                                        
                                        Text("  /  \(game.AIwinThreshold)%")
                                            .font(UIDevice.current.userInterfaceIdiom != .phone ? .title2 : .body)
                                            .fontWeight(.bold)
                                            .foregroundColor(.red)
                                            .opacity(0.6)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.1)
                                    }
                                }
                                
//                                Spacer()
                            }
                            .padding(.horizontal, 75)
                            
                            Spacer()
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(UIDevice.current.userInterfaceIdiom != .mac ? .top : [])
            
            // MARK: Navigation View Settings
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        VStack {
                            Button(action: {
                                isGamePaused = true
                                game.shouldRunTimer = false
                            }) {
                                Image(systemName: "pause.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.blue)
                                    .frame(width: 20, height: 20)
                            }
                            .alert("Game Paused", isPresented: $isGamePaused) {
                                Button(role: .cancel, action : {
                                    isGamePaused = false
                                    game.shouldRunTimer = true
                                }) {
                                    Text("Resume Game")
                                }
                                
                                Button(role: .destructive, action : {
                                    stopAudio()
                                    playAudio(fileName: "Lounge Drum and Bass", type: "mp3")
                                    isShowingGameSequence = false
                                }) {
                                    Text("Quit Game")
                                }
                            }
                            .padding(.leading, 10)
                            .padding(.top, 30)
                            
                            Spacer()
                        }
                        
                        Spacer()
                    }
                }
            })
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
                playAudio(fileName: getRandomBattleThemeFilename(), type: "mp3")
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
                isCanvasDisabled = true
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
                isCanvasDisabled = false
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
            try ImagePredictor().makePredictions(with: {
                if game.task.object <= "Duck" {
                    return .I
                } else if game.task.object <= "Ocean" {
                    return .II
                } else if game.task.object <= "Sword" {
                    return .III
                } else {
                    return .IV
                }
            }(), for: drawingImage, completionHandler: { predictions in
                for eachPrediction in predictions! {
                    predictionProbabilities[eachPrediction.classification] = eachPrediction.confidencePercentage
                }
            })
            
            // Add the score to the game state
//            game.playerScores.append(Double(predictionProbabilities[game.task.object]!)!)
            game.playerScores.append(Double(predictionProbabilities[game.task.object]!.replacingOccurrences(of: "%", with: ""))!)
        } catch {
            print("[Judge Model Prediction Error]")
            print(error.localizedDescription)
            print(error)
        }
        
        // Train a new AI model and get its training score, unless it is round 1, in which
        // case we simply copy the player score as the AI score. If the AI score to assign is NaN, use 0 as the score.
        let newAIscore = getAIscore()
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
            
            // Update the save data
            userTaskRecords.records[game.task.object]!["timesPlayed"]! += 1
            if game.gameScore > userTaskRecords.records[game.task.object]!["highScore"]! {
                userTaskRecords.records[game.task.object]!["highScore"] = game.gameScore
            }
            gamesWon += 1
            
            // Update the Sum of High Scores, Games Finished, and Games Won leaderboards
            var scoreSum = 0
            var gamesFinished = 0
            for eachTask in Task.taskList {
                if userTaskRecords.records.keys.contains(eachTask.object) {
                    scoreSum += userTaskRecords.records[eachTask.object]!["highScore"]!
                    gamesFinished += userTaskRecords.records[game.task.object]!["timesPlayed"]!
                }
            }
            uploadLeaderboardScore("Sum_of_High_Scores", score: scoreSum)
            uploadLeaderboardScore("Games_Finished", score: gamesFinished)
            uploadLeaderboardScore("Games_Won", score: gamesWon)
            
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
            "Plotting your demise...",
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
