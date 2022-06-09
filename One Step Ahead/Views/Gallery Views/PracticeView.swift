//
//  PracticeView.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 5/20/22.
//

import SwiftUI
import SpriteKit
import PencilKit

/// A view allowing users to practice a specific drawing and be scored by the judge independent of a formal game or the AI.
struct PracticeView: View {
    
    // MARK: - Variables
    /// The presentation status variable for this view's modal presentation.
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    /// The task that this view provides practice for.
    var task: Task
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
                SpriteView(scene: SKScene(fileNamed: "Game View Graphics")!)
                    .edgesIgnoringSafeArea(.all)
                
                HStack {
                    VStack {
                        HStack(alignment: .bottom) {
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
                            
                            if isCanvasDisabled {
                                Rectangle()
                                    .opacity(0.2)
                                    .aspectRatio(1.0, contentMode: .fit)
                            }
                        }
                        .aspectRatio(1.0, contentMode: .fit)
                        
                        HStack {
                            Text("")
                                .modifier(RectangleWrapper(fixedHeight: 60, color: .blue, opacity: 1.0))
                                .hidden()
                            
                            Button(action: {
                                processAttempt(canvasBounds: canvasView.bounds)
                            }) {
                                Text("Done!")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .modifier(RectangleWrapper(fixedHeight: 60, color: .blue, opacity: 1.0))
                            }
                            
                            Text("")
                                .modifier(RectangleWrapper(fixedHeight: 60, color: .blue, opacity: 1.0))
                                .hidden()
                        }
                        .padding(.top)
                    }
                    .padding()
                    .padding()
                    
                    VStack(spacing: 80) {
                        Spacer()
                        
                        ZStack {
                            Rectangle()
                                .opacity(0.2)
                                .frame(height: 100)
                                .cornerRadius(30)
                            
                            HStack {
                                Text(task.emoji)
                                    .font(.system(size: 70))
                                
                                VStack(alignment: .leading) {
                                    Text(task.object)
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                    
                                    Text("No. \(index + 1)")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.gray)
                                }
                                .padding(.leading)
                            }
                        }
                        
                        HStack {
                            VStack {
                                Text("Elapsed Time")
                                    .foregroundColor(.cyan)
                                    .font(.system(size: 40))
                                    .fontWeight(.bold)
                                
                                Text(elapsedTime.truncate(places: 1).description + "s")
                                    .foregroundColor(.cyan)
                                    .font(.system(size: 60))
                                    .fontWeight(.heavy)
                            }
                            
                            Spacer()
                            
                            VStack {
                                Text("Accuracy")
                                    .foregroundColor(.green)
                                    .font(.system(size: 40))
                                    .fontWeight(.bold)
                                
                                Text(currentPlayerScore != nil ? currentPlayerScore!.truncate(places: 2).description + "%" : "---")
                                    .foregroundColor(currentPlayerScore != nil ? .green : .secondary)
                                    .font(.system(size: 60))
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
            // MARK: Navigation View Settings
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        stopAudio()
                        playAudio(fileName: "The Big Beat 80s (Spaced)", type: "wav")
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("End Practice")
                            .fontWeight(.bold)
                            .foregroundColor(.red)
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
                playAudio(fileName: "Powerup!", type: "mp3")
            }
            .onReceive(timer) { input in
                // MARK: Timer Response
                // Increment the elapsed time
                elapsedTime += 0.1
            }
            
            // MARK: Navigation View Settings
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            
        }
        .navigationViewStyle(.stack)
    }
    
    // MARK: - Functions
    /// Processes a completed attempt by the user, to be called when the Done! button is pressed.
    func processAttempt(canvasBounds: CGRect) {
        // Use the judge model to give the user a score
        var predictionProbabilities: [String : String] = [:]
        do {
            // Layer the drawing on top of a white background
            let background = UIColor.white.imageWithColor(width: canvasBounds.width, height: canvasBounds.height)
            let drawingImage = background.mergeWith(topImage: canvasView.drawing.image(from: canvasBounds, scale: UIScreen.main.scale).tint(with: .black)!)
            
            // Get the probabilities for every drawing
            try ImagePredictor().makePredictions(for: drawingImage, completionHandler: { predictions in
                for eachPrediction in predictions! {
                    predictionProbabilities[eachPrediction.classification] = eachPrediction.confidencePercentage
                }
            })
            
            // Place the score into the UI
            currentPlayerScore = Double(predictionProbabilities[task.object]!)!
        } catch {
            print("[Judge Model Prediction Error]")
            print(error.localizedDescription)
            print(error)
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

struct PracticeView_Previews: PreviewProvider {
    static var previews: some View {
        PracticeView(task: Task.taskList[0], index: 1)
            .previewInterfaceOrientation(.landscapeRight)
    }
}
