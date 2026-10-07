//
//  PracticeView.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 5/20/22.
//

import SwiftUI
import Combine
import SpriteKit
import PencilKit

/// A view allowing users to practice a specific drawing and be scored by the judge independent of a formal game or the AI.
struct PracticeView: View {
    @Environment(\.screenLayout) private var layout
    
    // MARK: - View Variables
    /// The action that dismisses this view.
    @Environment(\.dismiss) private var dismiss
    /// The display scale used to render the player's drawing for judging.
    @Environment(\.displayScale) private var displayScale
    /// The task that this view provides practice for.
    var task: DrawingTask
    /// The task list index of the task that this view provides practice for.
    var index: Int
    
    /// The all-time number of practice drawings the user has made.
    @AppStorage("practiceDrawingsMade") var practiceDrawingsMade: Int = 0
    /// The user's most recent drawing score.
    @State var currentPlayerScore: Double? = nil
    /// The elapsed time for the user's current attempt.
    @State var elapsedTime: Double = 0.0
    
    /// A 0.1-second-interval timer responsible for triggering game events.
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    /// The current status of the end-of-round score evaluation process.
    @State var scoreEvaluationStatus : ScoreEvaluationStatus = .notEvaluating
    /// Whether or not the drawing canvas is disabled.
    @State var isCanvasDisabled = false
    
    /// The UIKit view object for the drawing canvas.
    @State var canvasView = PKCanvasView()
    /// A list of all versions of the canvas; facilitates the Undo button.
    @State var allDrawings: [PKDrawing] = []
    /// Whether or not a canvas undo operation is currently taking place.
    @State var isDeletingDrawing = false
    
    /// The SpriteKit scene for the graphics of this view.
    @State var graphicsScene = SKScene(fileNamed: "\(UIDevice.current.userInterfaceIdiom == .phone ? "iOS " : "")Game View Graphics")!
    
    /// The arrangement of the drawing area and the task details: side by side, or stacked when the window is taller than it is wide.
    private var panelLayout: AnyLayout {
        layout.isPortrait ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout())
    }
    /// The size of the drawing area when it sits above the task details rather than beside them: as large as the window allows once the details have their room.
    private var stackedCanvasSize: CGFloat { max(200, min(layout.width - 64, layout.height - 660)) }
    
    // MARK: - View Body
    var body: some View {
        NavigationStack {
            ZStack {
                GameBackground(scene: graphicsScene)
            
                panelLayout {
                    VStack(spacing: 0) {
                        let canvasViewBody = ZStack {
                            ZStack {
                                Rectangle()
                                    .opacity(0.2)
                                    .aspectRatio(1.0, contentMode: .fit)
                                    .foregroundStyle(.blue)
                                    .hidden()
                            
                                VStack {
                                    HStack {
                                        Text("You")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .hidden()
                                    
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
                                                    .foregroundStyle(Color.secondary)
                                                    .clipShape(.rect(cornerRadius: 50))
                                            
                                                HStack {
                                                    Image(systemName: "arrow.uturn.backward.circle")
                                                        .foregroundStyle(Color.primary)
                                                
                                                    Text("Undo")
                                                        .font (layout.isRegular ? .body : .body)
                                                        .fontWeight(.bold)
                                                        .foregroundStyle(Color.primary)
                                                }
                                            }
                                        }
                                        .frame(width: layout.isRegular ? 120 : 100, height: layout.isRegular ? 40 : 30)
                                        .offset(y: -5)
                                    }
                                
                                    Spacer()
                                }
                            }
                            .aspectRatio(1.0, contentMode: .fit)
                            .offset(y: -40)
                        
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
                    
                        if layout.isRegular {
                            canvasViewBody
                                .aspectRatio(1, contentMode: .fit)
                                .frame(width: layout.isPortrait ? stackedCanvasSize : nil, height: layout.isPortrait ? stackedCanvasSize : nil)
                                .padding()
                        } else {
                            canvasViewBody
                                .aspectRatio(1, contentMode: .fit)
                                .frame(width: layout.isPhone || !layout.isPortrait ? layout.width / 4 : layout.width * 0.6)
                                .padding()
                        }
                    
                        HStack(spacing: 0) {
                            let buttonFixedHeight = layout.isRegular ? 60 : 40
                        
                            Text("")
                                .modifier(RectangleWrapper(fixedHeight: buttonFixedHeight, color: .blue, opacity: 1.0))
                                .hidden()
                        
                            Button(action: {
                                processAttempt()
                            }) {
                                Text("Done!")
                                    .font(layout.isRegular ? .title2 : .body)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .modifier(RectangleWrapper(fixedHeight: buttonFixedHeight, color: .blue, opacity: 1.0))
                            }
                        
                            Text("")
                                .modifier(RectangleWrapper(fixedHeight: buttonFixedHeight, color: .blue, opacity: 1.0))
                                .hidden()
                        }
                        .padding(.top, layout.isRegular ? 15 : 0)
                    }
                    .padding()
                    .padding()
                
                    VStack(spacing: layout.isRegular && layout.isPortrait ? 30 : 80) {
                        Spacer()
                    
                        ZStack {
                            Rectangle()
                                .opacity(0.2)
                                .frame(height: 100)
                                .clipShape(.rect(cornerRadius: 30))
                        
                            HStack {
                                Text(task.emoji)
                                    .font(.system(size: layout.isRegular ? 70 : 35.5))
                            
                                VStack(alignment: .leading) {
                                    Text(task.object)
                                        .font(layout.isRegular ? .largeTitle : .title)
                                        .fontWeight(.bold)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.1)
                                
                                    Text("No. \(index + 1)")
                                        .font(layout.isRegular ? .title : .title2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.gray)
                                }
                                .padding(.leading)
                            }
                            .padding(.horizontal, 5)
                        }
                    
                        HStack {
                            VStack {
                                Text(layout.isRegular ? "Elapsed Time" : "Time")
                                    .foregroundStyle(.cyan)
                                    .font(.system(size: layout.isRegular ? 40 : 20))
                                    .fontWeight(.bold)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.1)
                            
                                Text(elapsedTime.truncate(places: 1).description + "s")
                                    .foregroundStyle(.cyan)
                                    .font(.system(size: layout.isRegular ? 60 : 30))
                                    .fontWeight(.heavy)
                            }
                        
                            Spacer()
                        
                            VStack {
                                Text("Accuracy")
                                    .foregroundStyle(.green)
                                    .font(.system(size: layout.isRegular ? 40 : 20))
                                    .fontWeight(.bold)
                            
                                Text(currentPlayerScore != nil ? currentPlayerScore!.truncate(places: 2).description + "%" : "---")
                                    .foregroundStyle(currentPlayerScore != nil ? .green : Color.secondary)
                                    .font(.system(size: layout.isRegular ? 60 : 30))
                                    .fontWeight(currentPlayerScore != nil ? .heavy : .regular)
                            }
                        }
                    
                        Spacer()
                    }
                    .padding(.vertical)
                    .padding(.vertical)
                    .padding(.horizontal)
                    .padding(.horizontal)
                }
                .padding(.all)
            }
            // The content above needs more height than the screen offers, so SwiftUI centers it and lets it overflow. Sizing this view to the screen first keeps the chrome below pinned to the top edge rather than centered along with the content.
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            // MARK: Navigation View Settings
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: 0) {
                NavigationChromeBar {
                    GlassCapsuleButton(title: "Exit Practice", tint: .red) {
                        stopAudio()
                        playAudio(fileName: "Lounge Drum and Bass", type: "mp3")
                        dismiss()
                    }
                }
            }
    
            .onAppear {
                // MARK: View Launch Code
                // Clear the documents and temporary directories
                clearFolder(getDocumentsDirectory().path)
                clearFolder(FileManager.default.temporaryDirectory.path)
                
                // Start the battle music
                stopAudio()
                playAudio(fileName: getRandomBattleThemeFilename(), type: "mp3")
            }
            .onReceive(timer) { _ in
                // MARK: Timer Response
                // Increment the elapsed time
                elapsedTime += 0.1
            }
            
            // MARK: Navigation View Settings
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            
        }
        .dynamicTypeSize(.medium).statusBar(hidden: true)
    }
    
    // MARK: - Functions
    /// Processes a completed attempt by the user, to be called when the Done! button is pressed.
    func processAttempt() {
        // Render the drawing and use the judge model to give the user a score
        let canvasBounds = canvasView.bounds
        let strokes = canvasView.drawing.image(from: canvasBounds, scale: displayScale)
        let drawingImage = DrawingJudge.prepareDrawing(strokes: strokes, canvasSize: canvasBounds.size)
        if let score = DrawingJudge.playerScore(for: drawingImage, object: task.object) {
            // Place the score into the UI
            currentPlayerScore = score
        }
        
        // Update the Practice Drawings Made leaderboard and the save data only if the drawing is not empty
        if !canvasView.drawing.strokes.isEmpty {
            practiceDrawingsMade += 1;
            uploadLeaderboardScore("Practice_Drawings_Made", score: practiceDrawingsMade)
        }
        
        // Reset the canvas
        canvasView.drawing = PKDrawing()
        allDrawings = []
        
        // Reset the elapsed time
        elapsedTime = 0.0
        
        // Award practice mode drawing score-based achievements
        if currentPlayerScore == 0.0 {
            reportAchievementProgress("Practice_Makes_Imperfect")
        }
        if currentPlayerScore == 100.0 {
            reportAchievementProgress("Practice_Makes_Perfect")
        }
    }
    
}

#Preview(traits: .landscapeRight) {
    PracticeView(task: DrawingTask.taskList[0], index: 0)
}
