//
//  TutorialGameView.swift
//  
//
//  Created by Ethan Marshall on 4/21/22.
//

import SwiftUI
import Combine
import SpriteKit
import PencilKit

/// The version of the game view used in the tutorial; it has dialogue and a much more guided feel.
struct TutorialGameView: View {
    @Environment(\.screenLayout) private var layout
    
    // MARK: - View Variables
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
    @State var isShowingAIbox = false
    /// Whether or not the player box and "VS" text are on-screen.
    @State var isShowingPlayerBox = false
    /// Whether or not the round indicator is on-screen.
    @State var isShowingRoundIndicator = false
    /// Whether or not the timer is on-screen.
    @State var isShowingTimer = false
    /// Whether or not the "Tap" text is on-screen.
    @State var isShowingAdvancePrompt = true
    /// Whether or not the training explanation drawing is on-screen.
    @State var isShowingTrainingDataDrawing = false
    /// Whether or not the judge model explanation text is on-screen.
    @State var isShowingJudgeModelDrawing = false
    /// Whether or not the dialogue view is on-screen.
    @State var isShowingDialogueView = true
    /// Whether or not the command text is on-screen.
    @State var isShowingCommand = false
    
    // Game View Variables
    /// A wrapper for the user's task-related save data. This value is presisted inside UserDefaults.
    @AppStorage("userTaskRecords") var userTaskRecords: UserTaskRecords = UserTaskRecords()
    /// The number of games the user has won to date.
    @AppStorage("gamesWon") var gamesWon: Int = 0
    /// The action that dismisses this view.
    @Environment(\.dismiss) private var dismiss
    /// The display scale used to render the player's drawing for judging.
    @Environment(\.displayScale) private var displayScale
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
    
    /// The space on either side of the two drawing boxes, which narrows when the window is tall or small.
    private var canvasesPadding: CGFloat {
        layout.isPhone ? 75 : (layout.isCompact ? 20 : (layout.isPortrait ? 30 : 75))
    }
    
    // MARK: - View Body
    var body: some View {
        ZStack {
            GameBackground(scene: graphicsScene)
            
            VStack {
                VStack {
                    VStack(spacing: 0) {
                        Text("- Round \(game.currentRound) -")
                            .font(layout.isRegular ? .largeTitle : .title3)
                            .fontWeight(.bold)
                            .padding(.bottom, 5)
                            .padding(.top, layout.isRegular ? 20 : 0)
                            .isHidden(!isShowingRoundIndicator)
                        
                        if isShowingCommand {
                            Text("Draw something round and edible!")
                                .font(layout.isRegular ? .title : .body)
                                .fontWeight(.bold)
                        }
                        
                        Text(game.timeLeft.truncate(places: 1).description + "s")
                            .font(layout.isRegular ? .largeTitle : .title3)
                            .fontWeight(.heavy)
                            .isHidden(!isShowingTimer)
                        
                        Spacer()
                        
                        HStack(alignment: .center, spacing: 30) {
                            VStack {
                                ZStack {
                                    ZStack {
                                        Rectangle()
                                            .opacity(0.2)
                                            .aspectRatio(1.0, contentMode: .fit)
                                            .foregroundStyle(.blue)
                                            .hidden()
                                        
                                        VStack {
                                            HStack {
                                                Text("You")
                                                    .font(layout.isRegular ? .title2 : .callout)
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
                                                        if layout.isRegular {
                                                            Rectangle()
                                                                .foregroundStyle(Color.secondary)
                                                                .clipShape(.rect(cornerRadius: 50))
                                                        } else {
                                                            Circle()
                                                                .foregroundStyle(Color.secondary)
                                                        }
                                                        HStack {
                                                            Image(systemName: "arrow.uturn.backward.circle")
                                                                .foregroundStyle(Color.primary)
                                                            
                                                            if layout.isRegular {
                                                                Text("Undo")
                                                                    .fontWeight(.bold)
                                                                    .foregroundStyle(Color.primary)
                                                            }
                                                        }
                                                    }
                                                }
                                                .frame(width: layout.isRegular ? 120 : 30, height: layout.isRegular ? 40 : 10)
                                                .offset(y: layout.isRegular ? -5 : 0)
                                                .accessibilityLabel("Undo")
                                            }
                                            
                                            Spacer()
                                        }
                                    }
                                    .aspectRatio(1.0, contentMode: .fit)
                                    .offset(y: layout.isRegular ? -40 : -25)
                                    
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
                                .padding(.top, layout.isRegular ? 45 : 0)
                                
                                Text("Current Score")
                                    .font(layout.isRegular ? .title : .body)
                                    .fontWeight(.bold)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.1)
                                    .padding(.top)
                                
                                HStack(spacing: 0) {
                                    if game.currentRound != 1 {
                                        Text("\(game.playerScores[game.currentRound - 2].description)%")
                                            .font(layout.isRegular ? .largeTitle : .title3)
                                            .fontWeight(.heavy)
                                            .foregroundStyle(.green)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.1)
                                    } else {
                                        Text("---")
                                            .font(layout.isRegular ? .title : .title3)
                                            .fontWeight(.bold)
                                            .foregroundStyle(Color.secondary)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.1)
                                    }
                                    
                                    Text("  /  \(game.playerWinThreshold)%")
                                        .font(layout.isRegular ? .title2 : .body)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.green)
                                        .opacity(0.6)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.1)
                                }
                            }
                            .isHidden(!isShowingPlayerBox, remove: false)
                            
                            Text("VS")
                                .font(.largeTitle)
                                .fontWeight(.black)
                                .padding(.bottom, 48)
                                .isHidden(!isShowingPlayerBox, remove: false)
                            
                            VStack {
                                ZStack {
                                    ZStack {
                                        Rectangle()
                                            .opacity(0.2)
                                            .aspectRatio(1.0, contentMode: .fit)
                                            .foregroundStyle(.blue)
                                            .hidden()
                                        
                                        VStack {
                                            HStack {
                                                ZStack {
                                                    Rectangle()
                                                        .foregroundStyle(Color.secondary)
                                                        .clipShape(.rect(cornerRadius: 50))
                                                    HStack {
                                                        Image(systemName: "arrow.uturn.backward.circle")
                                                            .foregroundStyle(Color.primary)
                                                        
                                                        Text("Undo")
                                                            .fontWeight(.bold)
                                                            .foregroundStyle(Color.primary)
                                                    }
                                                }
                                                .frame(width: 120, height: 40)
                                                .isHidden(true, remove: true)
                                                
                                                Spacer()
                                                
                                                Text("The Machine")
                                                    .font(layout.isRegular ? .title2 : .callout)
                                                    .fontWeight(.bold)
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.1)
                                            }
                                            
                                            Spacer()
                                        }
                                    }
                                    .aspectRatio(1.0, contentMode: .fit)
                                    .offset(y: layout.isRegular ? -40 : -25)
                                    
                                    ZStack {
                                        Rectangle()
                                            .opacity(0.2)
                                            .aspectRatio(1.0, contentMode: .fit)
                                        
                                        VStack {
                                            if isTrainingAImodel {
                                                ProgressView()
                                                    .scaleEffect(layout.isRegular ? 2.5 : 1.5)
                                                    .progressViewStyle(CircularProgressViewStyle())
                                                    .frame(width: 75, height: 75)
                                            } else {
                                                Image("robot")
                                                    .resizable()
                                                    .frame(width: layout.isRegular ? 75 : 35, height: layout.isRegular ? 75 : 35)
                                            }
                                            
                                            Text("Hello!")
                                                .font(layout.isRegular ? .custom("Roboto Mono", size: 20) : .custom("Roboto Mono", size: 10))
                                                .fontWeight(.bold)
                                                .multilineTextAlignment(.center)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.1)
                                                .padding(.horizontal, layout.isRegular ? 0 : 10)
                                        }
                                    }
                                }
                                .padding(.top, layout.isRegular ? 45 : 0)
                                
                                Text("Current Score")
                                    .font(layout.isRegular ? .title : .body)
                                    .fontWeight(.bold)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.1)
                                    .padding(.top)
                                
                                HStack {
                                    if game.currentRound != 1 {
                                        Text("\(game.AIscores[game.currentRound - 2].truncate(places: 2).description)%")
                                            .font(layout.isRegular ? .largeTitle : .title3)
                                            .fontWeight(.heavy)
                                            .foregroundStyle(.red)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.1)
                                    } else {
                                        Text("---")
                                            .font(layout.isRegular ? .title : .title3)
                                            .fontWeight(.bold)
                                            .foregroundStyle(Color.secondary)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.1)
                                    }
                                    
                                    Text("  /  \(game.AIwinThreshold)%")
                                        .font(layout.isRegular ? .title2 : .body)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.red)
                                        .opacity(0.6)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.1)
                                }
                            }
                            .isHidden(!isShowingAIbox, remove: false)
                        }
                        .padding(.horizontal, canvasesPadding)
                    }
                }
                
                Spacer()
                
                if isShowingDialogueView {
                    DialogueView(isShowingAdvancePrompt: $isShowingAdvancePrompt, emojiImageName: speakerEmoji, characterName: speakerName, dialogue: speakerDialogue, color1: speakerColor1, color2: speakerColor2, height: layout.isRegular ? 145 : 55)
                        .onTapGesture {
                            if stateID != 10 {
                                moveToNextState()
                            }
                        }
                        .padding(.horizontal, 50)
                        .padding(.bottom)
                }
            }
            .padding(.bottom)
            
            VStack {
                
                Spacer()
                
                Image("Training Explanation Art")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(.rect(cornerRadius: layout.isRegular ? 30 : 10))
                    .padding(layout.isRegular ? 50 : 20)
                    .isHidden(!isShowingTrainingDataDrawing, remove: true)
                
                Image("Judge Explanation Art")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(.rect(cornerRadius: layout.isRegular ? 30 : 10))
                    .padding(layout.isRegular ? 50 : 20)
                    .isHidden(!isShowingJudgeModelDrawing, remove: true)
                
                Spacer()
                
                DialogueView(isShowingAdvancePrompt: $isShowingAdvancePrompt, emojiImageName: speakerEmoji, characterName: speakerName, dialogue: speakerDialogue, color1: speakerColor1, color2: speakerColor2, height: layout.isRegular ? 145 : 55)
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
            .toolbar(.hidden, for: .navigationBar)
        }
        .dynamicTypeSize(.medium).statusBar(hidden: true)
        .ignoresSafeArea(edges: .top)
        .safeAreaInset(edge: .top, spacing: 0) {
            NavigationChromeBar {
                GlassCircleButton(systemImage: "pause.fill", accessibilityLabel: "Pause Game", symbolSize: 20, tint: .blue) {
                    isGamePaused = true
                    game.shouldRunTimer = false
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
        .navigationDestination(isPresented: $isShowingGameEndView) {
            TutorialGameEndView(isShowingTutorialSequence: $isShowingTutorialSequence, game: game)
        }
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
                dismiss()
            }
        }
        .onDisappear {
            // MARK: View Vanish Code
            // Mark the navigation chain as collapsing for later use by the game end view to close all the views at once
            isDismissing = true
        }
        .onReceive(timer) { _ in
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
            
            // On the next 0.1 second, calculate the scores in the background
            if game.timeLeft == -0.1 {
                scoreEvaluationStatus = .evaluating
                game.timeLeft = 0.0
                game.shouldRunTimer = false
                Task {
                    await evaluateScores()
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
    /// The player's drawing is rendered on the main actor, then judged and used to train the Machine on a background thread, since the ML training can take a long time and would lag the main thread.
    func evaluateScores() async {
        // Render the player's strokes before leaving the main actor
        let canvasBounds = canvasView.bounds
        let strokes = canvasView.drawing.image(from: canvasBounds, scale: displayScale)
        
        // Judge the drawing and train the Machine in the background
        let verdict = await DrawingJudge.judgeRound(strokes: strokes, canvasSize: canvasBounds.size, object: game.task.object, round: game.currentRound, playerScores: game.playerScores)
        
        // Add the scores to the game state
        game.playerScores.append(verdict.playerScore)
        game.AIscores.append(verdict.AIscore)
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
                reportAchievementProgress("Art_Aficionado", progress: 1.0 / Double(DrawingTask.taskList.count) * 100.0 * 2)
                reportAchievementProgress("Museum_Curator", progress: 1.0 / Double(DrawingTask.taskList.count) * 100.0)
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
            for eachTask in DrawingTask.taskList {
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
            speakerDialogue = "All right, here we go! Once you tap, you'll have 10 seconds to try and draw \"something round and edible\" with 90% accuracy or higher!"
            
        case 10:
            // Move from state 9 to 10
            isShowingDialogueView = false
            isShowingCommand = true
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

#Preview(traits: .landscapeLeft) {
    TutorialGameView(isShowingTutorialSequence: .constant(true), commandText: "Preview command text!")
}

/// A view representing speech by a game character.
struct DialogueView: View {
    @Environment(\.screenLayout) private var layout
    
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
                
                if layout.isRegular {
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
            .frame(width: layout.isRegular ? height + 25 : height + 15, height: layout.isRegular ? height + 25 : height + 15)
            .padding(.trailing, -70)
            .foregroundStyle(.gray)
            .zIndex(1)
            
            ZStack {
                Rectangle()
                    .frame(height: height)
                    .clipShape(.rect(cornerRadius: 30))
                
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
                                .clipShape(.rect(cornerRadius: 10))
                            
                            Text(characterName)
                                .font(layout.isRegular ? .title3 : .footnote)
                                .fontWeight(.heavy)
                        }
                        .frame(width: 150, height: layout.isRegular ? 45 : 25)
                        .offset(y: layout.isRegular ? 0 : 7)
                        Spacer()
                    }
                    Spacer()
                }
                .frame(height: height + 39)
                .padding(.leading, 75)
                
                Text(dialogue)
                    .font(layout.isRegular ? .title2 : .footnote)
                    .fontWeight(.medium)
                    .foregroundStyle(.black)
                    .lineLimit(layout.isRegular ? 1000 : 2)
                    .minimumScaleFactor(0.1)
                    .padding(.horizontal, 90)
                    .padding(.trailing)
                    .padding(.top, 7)
                
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        Text(advancePrompt)
                            .font(layout.isRegular ? .title2 : .footnote)
                            .fontWeight(.bold)
                            .foregroundStyle(color1 != .white ? color1 : .gray)
                            .isHidden(!isShowingAdvancePrompt)
                    }
                }
                .frame(height: height)
                .padding([.bottom, .trailing])
            }
        }
        .dynamicTypeSize(.medium).statusBar(hidden: true)
    }
}
