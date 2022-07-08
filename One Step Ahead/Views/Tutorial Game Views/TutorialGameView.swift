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
    /// Whether or not the tutorial sequence is being presented as a full screen modal.
    @Binding var isShowingTutorialSequence: Bool
    
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
    @State var isShowingAIbox = true // !
    /// Whether or not the player box and "VS" text are on-screen.
    @State var isShowingPlayerBox = true // !
    /// Whether or not the round indicator is on-screen.
    @State var isShowingRoundIndicator = true // !
    /// Whether or not the timer is on-screen.
    @State var isShowingTimer = true // !
    /// Whether or not the "Tap" text is on-screen.
    @State var isShowingAdvancePrompt = true
    /// Whether or not the training explanation drawing is on-screen.
    @State var isShowingTrainingDataDrawing = false
    /// Whether or not the judge model explanation text is on-screen.
    @State var isShowingJudgeModelDrawing = false
    
    // Game View Variables
    /// A wrapper for the user's task-related save data. This value is presisted inside UserDefaults.
    @AppStorage("userTaskRecords") var userTaskRecords: UserTaskRecords = UserTaskRecords()
    /// The number of games the user has won to date.
    @AppStorage("gamesWon") var gamesWon: Int = 0
    /// The presentation status variable for this view's modal presentation.
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    /// Whether or not the game end view is showing.
    @State private var isShowingGameEndView = false
    /// Whether or not the view is currently being collapsed by the End Game View.
    @State var isDismissing = false
    /// The state of the app's currently running game, passed in from the New Game screen.
    @State var game: GameState = GameState(shouldRunTimer: false)
    /// A 0.1-second-interval timer responsible for triggering game events.
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    /// The current status of the end-of-round score evaluation process.
    @State var scoreEvaluationStatus : ScoreEvaluationStatus = .notEvaluating
    /// Whether or not the drawing canvas is disabled.
    @State var isCanvasDisabled = false
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
    /// Whether or not the game is paused and the pause menu is showing.
    @State var isGamePaused = false
    
    /// The SpriteKit scene for the graphics of this view.
    @State var graphicsScene = SKScene(fileNamed: "\(UIDevice.current.userInterfaceIdiom == .phone ? "iOS " : "")Game View Graphics")!
    
    // MARK: - Enumeration
    /// The different possible statuses of the end-of-round score evaluation process.
    enum ScoreEvaluationStatus {
        case notEvaluating
        case evaluating
        case evaluationComplete
    }
    
    var body: some View {
        ZStack {
            // The programatically-triggered navigation link for the game end view
            NavigationLink(destination: TutorialGameEndView(isShowingTutorialSequence: $isShowingTutorialSequence, game: game), isActive: $isShowingGameEndView) { EmptyView() }
            
            SpriteView(scene: graphicsScene)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                VStack {
                    // MARK: Game View Start
                    VStack(spacing: 0) {
                        Text("- Round \(game.currentRound) -")
                            .font(UIDevice.current.userInterfaceIdiom != .phone ? .largeTitle : .title3)
                            .fontWeight(.bold)
                            .padding(.bottom, 5)
                            .padding(.top, UIDevice.current.userInterfaceIdiom != .phone ? 20 : 0)
                            .isHidden(!isShowingRoundIndicator)
                        
                        Text(game.timeLeft.truncate(places: 1).description + "s")
                            .font(UIDevice.current.userInterfaceIdiom != .phone ? .largeTitle : .title3)
                            .fontWeight(.heavy)
                            .isHidden(!isShowingTimer)
                        
                        Spacer()
                        
                        HStack(alignment: .center, spacing: 30) {
//                            Spacer()
                            
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
                            .isHidden(!isShowingPlayerBox, remove: false)
                            
//                            Spacer()
                            
                            Text("VS")
                                .font(.largeTitle)
                                .fontWeight(.black)
                                .padding(.bottom, 48)
                                .isHidden(!isShowingPlayerBox, remove: false)
                            
//                            Spacer()
                            
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
                            .isHidden(!isShowingAIbox, remove: false)
                            
//                            Spacer()
                        }
                        .padding(.horizontal, 75)
                        
//                        Spacer()
                    }
                    // MARK: Game View End
                }
                
                Spacer()
                
                DialogueView(isShowingAdvancePrompt: $isShowingAdvancePrompt, emojiImageName: speakerEmoji, characterName: speakerName, dialogue: speakerDialogue, color1: speakerColor1, color2: speakerColor2, height: UIDevice.current.userInterfaceIdiom != .phone ? 145 : 55)
                    .onTapGesture {
                        if stateID != 10 {
                            moveToNextState()
                        }
                    }
                    .padding(.horizontal, 50)
                    .padding(.bottom)
            }
            
            VStack {
                
                Spacer()
                
                Image("Training Explanation Art")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(UIDevice.current.userInterfaceIdiom != .phone ? 30 : 10)
                    .padding(UIDevice.current.userInterfaceIdiom != .phone ? 50 : 20)
                    .isHidden(!isShowingTrainingDataDrawing, remove: true)
                
                Image("Judge Explanation Art")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(UIDevice.current.userInterfaceIdiom != .phone ? 30 : 10)
                    .padding(UIDevice.current.userInterfaceIdiom != .phone ? 50 : 20)
                    .isHidden(!isShowingJudgeModelDrawing, remove: true)
                
                Spacer()
                
                DialogueView(isShowingAdvancePrompt: $isShowingAdvancePrompt, emojiImageName: speakerEmoji, characterName: speakerName, dialogue: speakerDialogue, color1: speakerColor1, color2: speakerColor2, height: UIDevice.current.userInterfaceIdiom != .phone ? 145 : 55)
                    .onTapGesture {
                        if stateID != 10 {
                            moveToNextState()
                        }
                    }
                    .padding(.horizontal, 50)
                    .padding(.bottom)
                    .hidden()
            }
            
            // MARK: Navigation View Settings
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
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
                            isShowingTutorialSequence = false
                            playAudio(fileName: "Lounge Drum and Bass", type: "mp3")
                        }) {
                            Text("Quit Game")
                        }
                    }
                }
            }
            
        }
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            // MARK: View Launch Code
            // Clear the documents and temporary directories
            clearFolder(getDocumentsDirectory().path)
            clearFolder(FileManager.default.temporaryDirectory.path)
            
            // Start the battle music if not dismissing
            if !isDismissing {
                stopAudio()
                playAudio(fileName: "Space Chillout", type: "mp3")
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
    /// Evaluates the user and AI scores for this round.
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
            isShowingAIbox = false
            isShowingTrainingDataDrawing = true
            
        case 7:
            // Move from state 6 to 7
            speakerDialogue = "To beat the machine, you'll have to learn how to draw the mystery object before the machine learning model figures it out from your guesses!"
            isShowingTrainingDataDrawing = false
            isShowingJudgeModelDrawing = true
            
        case 8:
            // Move from state 7 to 8
            speakerDialogue = "Let's give it a try. You'll have 15 seconds to draw each round. After that, the machine will copy your art for its training data and you'll each get a score!"
            isShowingTrainingDataDrawing = false
            isShowingJudgeModelDrawing = false
            isShowingPlayerBox = true
            isShowingAIbox = true
        case 9:
            // Move from state 8 to 9
            speakerDialogue = "All right, here we go! Once you tap, you'll have 10 seconds to try and draw \"something round and edible\" with 97% accuracy or higher!"
            
        case 10:
            // Move from state 9 to 10
            speakerDialogue = "Go, go, go! Draw \"something round and edible\" with 97% accuracy or better! The machine only needs 80%!"
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
        TutorialGameView(isShowingTutorialSequence: .constant(true), commandText: "Preview command text!")
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
    var height: CGFloat = 145
    var advancePrompt = "Tap ➤"
    
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
                
                if UIDevice.current.userInterfaceIdiom != .phone {
                    Image(emojiImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: height - 35, height: height - 35)
                } else {
                    Image(emojiImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: height - 10, height: height - 10)
                }
            }
            .frame(width: UIDevice.current.userInterfaceIdiom != .phone ? height + 25 : height + 15, height: UIDevice.current.userInterfaceIdiom != .phone ? height + 25 : height + 15)
            .padding(.trailing, -70)
            .foregroundColor(.gray)
            .zIndex(1)
            
            ZStack {
                Rectangle()
                    .frame(height: height)
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
                                .font(UIDevice.current.userInterfaceIdiom != .phone ? .title3 : .footnote)
                                .fontWeight(.heavy)
                        }
                        .frame(width: 150, height: UIDevice.current.userInterfaceIdiom != .phone ? 45 : 25)
                        .offset(y: UIDevice.current.userInterfaceIdiom != .phone ? 0 : 7)
                        Spacer()
                    }
                    Spacer()
                }
                .frame(height: height + 39)
                .padding(.leading, 75)
                
                Text(dialogue)
                    .font(UIDevice.current.userInterfaceIdiom != .phone ? .title2 : .footnote)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .lineLimit(UIDevice.current.userInterfaceIdiom != .phone ? 1000 : 2)
                    .minimumScaleFactor(0.1)
                    .padding(.horizontal, 90)
                    .padding(.trailing)
                    .padding(.top, 7)
                
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        Text(advancePrompt)
                            .font(UIDevice.current.userInterfaceIdiom != .phone ? .title2 : .footnote)
                            .fontWeight(.bold)
                            .foregroundColor(color1 != .white ? color1 : .gray)
                            .isHidden(!isShowingAdvancePrompt)
                    }
                }
                .frame(height: height)
                .padding([.bottom, .trailing])
            }
        }
    }
}
