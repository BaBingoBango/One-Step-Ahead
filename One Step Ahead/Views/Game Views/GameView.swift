//
//  GameView.swift
//  
//
//  Created by Ethan Marshall on 4/7/22.
//

import SwiftUI
import Combine
import PencilKit
import CoreML
import SpriteKit

/// The view displaying the elements of the currently running game; originates from the New Game screen.
struct GameView: View {
    @Environment(\.screenLayout) private var layout
    
    // MARK: - View Variables
    /// A wrapper for the user's task-related save data. This value is presisted inside UserDefaults.
    @AppStorage("userTaskRecords") var userTaskRecords: UserTaskRecords = UserTaskRecords()
    /// The number of games the user has won to date.
    @AppStorage("gamesWon") var gamesWon: Int = 0
    /// The action that dismisses this view.
    @Environment(\.dismiss) private var dismiss
    /// The display scale used to render the player's drawing for judging.
    @Environment(\.displayScale) private var displayScale
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
    
    /// The space on either side of the two drawing boxes, which narrows when the window is tall or small.
    private var canvasesPadding: CGFloat {
        layout.isPhone ? 75 : (layout.isCompact ? 20 : (layout.isPortrait ? 30 : 75))
    }
    
    // MARK: - View Body
    var body: some View {
        NavigationStack {
            ZStack {
                GameBackground(scene: graphicsScene)
                
                HStack {
                    Spacer()
                    
                    VStack {
                        Text(game.currentRound != 1 ? "\(game.gameScore) pts." : "---")
                            .font(layout.isRegular ? .largeTitle : .title2)
                            .fontWeight(.heavy)
                            .foregroundStyle(game.currentRound != 1 ? Color.gold : .gray)
                            .padding([.top, .trailing])
                        
                        Spacer()
                    }
                }
                
                VStack {
                    VStack {
                        VStack(spacing: 0) {
                            Text("- Round \(game.currentRound) -")
                                .font(layout.isRegular ? .largeTitle : .title3)
                                .fontWeight(.bold)
                                .padding(.bottom, 5)
                                .padding(.top, layout.isRegular ? 20 : 0)
                            
                            Text(commandText)
                                .font(layout.isRegular ? .title : .body)
                                .fontWeight(.bold)
                                .padding(.bottom, 5)
                            
                            Text(game.timeLeft.truncate(places: 1).description + "s")
                                .font(layout.isRegular ? .largeTitle : .title3)
                                .fontWeight(.heavy)
                            
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
                                Text("VS")
                                    .font(.largeTitle)
                                    .fontWeight(.black)
                                    .padding(.bottom, 48)
                                
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
                                                
                                                Text(AItext)
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
                            }
                            .padding(.horizontal, canvasesPadding)
                            
                            Spacer()
                        }
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
            .navigationDestination(isPresented: $isShowingGameEndView) {
                GameEndView(isShowingGameSequence: $isShowingGameSequence, game: game)
            }
            
            // MARK: Navigation View Settings
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
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
                            stopAudio()
                            playAudio(fileName: "Lounge Drum and Bass", type: "mp3")
                            isShowingGameSequence = false
                        }) {
                            Text("Quit Game")
                        }
                    }
                }
            }
        }
        .dynamicTypeSize(.medium).statusBar(hidden: true)
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
                dismiss()
            }
        }
        .onDisappear {
            // MARK: View Vanish Code
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
        
        // Award drawing score-based achievements
        if verdict.playerScore == 0.0 {
            reportAchievementProgress("Definitely_Not_Right")
        }
        if verdict.playerScore == 100.0 {
            reportAchievementProgress("Beyond_a_Reasonable_Doubt")
        }
        if verdict.AIscore == 0.0 {
            reportAchievementProgress("Runtime_Error")
        }
        if verdict.AIscore == 100.0 {
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
    /// Gets a random message to use for the AI's box during drawing time.
    static func getIdleAIMessage() -> String {
        let messages: [String] = [
            "Chatting with Skynet!",
            "Plotting your demise!",
            "01001000 01101001",
            "Learning binary!",
            "Debugging!",
            "Beep boop!",
            "Studying Da Vinci!"
        ]
        return messages.randomElement()!
    }
    /// Gets a random message to use for the AI's box during training time.
    static func getTrainingAIMessage() -> String {
        let messages: [String] = [
            "Learning your secrets!",
            "Studying your art!",
            "Admiring your masterpiece=!",
            "Mixing paints!",
            "Copying over your shoulder!",
            "Infringing your copyright!"
        ]
        return messages.randomElement()!
    }
    
}

#Preview(traits: .landscapeRight) {
    GameView(isShowingGameSequence: .constant(true), commandText: "Preview!")
}
