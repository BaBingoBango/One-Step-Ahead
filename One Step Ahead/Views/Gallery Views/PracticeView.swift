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
    
    // MARK: - View Variables
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
    
    /// The SpriteKit scene for the graphics of this view.
    @State var graphicsScene = SKScene(fileNamed: "\(UIDevice.current.userInterfaceIdiom == .phone ? "iOS " : "")Game View Graphics")!
    
    // MARK: - View Body
    var body: some View {
        NavigationView {
            ZStack {
                SpriteView(scene: graphicsScene)
                    .edgesIgnoringSafeArea(.all)
                
                HStack {
                    VStack(spacing: 0) {
                        let canvasViewBody = ZStack {
                            ZStack {
                                Rectangle()
                                    .opacity(0.2)
                                    .aspectRatio(1.0, contentMode: .fit)
                                    .foregroundColor(.blue)
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
                                                    .foregroundColor(.secondary)
                                                    .cornerRadius(50)
                                                
                                                HStack {
                                                    Image(systemName: "arrow.uturn.backward.circle")
                                                        .foregroundColor(.primary)
                                                    
                                                    Text("Undo")
                                                        .font (UIDevice.current.userInterfaceIdiom != .phone ? .body : .body)
                                                        .fontWeight(.bold)
                                                        .foregroundColor(.primary)
                                                }
                                            }
                                        }
                                        .frame(width: UIDevice.current.userInterfaceIdiom != .phone ? 120 : 100, height: UIDevice.current.userInterfaceIdiom != .phone ? 40 : 30)
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
                        
                        if UIDevice.current.userInterfaceIdiom != .phone {
                            canvasViewBody
                                .aspectRatio(1, contentMode: .fit)
                                .padding()
                        } else {
                            canvasViewBody
                                .aspectRatio(1, contentMode: .fit)
                                .frame(width: UIScreen.main.bounds.width / 4)
                                .padding()
                        }
                        
                        HStack(spacing: 0) {
                            let buttonFixedHeight = UIDevice.current.userInterfaceIdiom != .phone ? 60 : 40
                            
                            Text("")
                                .modifier(RectangleWrapper(fixedHeight: buttonFixedHeight, color: .blue, opacity: 1.0))
                                .hidden()
                            
                            Button(action: {
                                processAttempt(canvasBounds: canvasView.bounds)
                            }) {
                                Text("Done!")
                                    .font(UIDevice.current.userInterfaceIdiom != .phone ? .title2 : .body)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .modifier(RectangleWrapper(fixedHeight: buttonFixedHeight, color: .blue, opacity: 1.0))
                            }
                            
                            Text("")
                                .modifier(RectangleWrapper(fixedHeight: buttonFixedHeight, color: .blue, opacity: 1.0))
                                .hidden()
                        }
                        .padding(.top, UIDevice.current.userInterfaceIdiom != .phone ? 15 : 0)
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
                                    .font(.system(size: UIDevice.current.userInterfaceIdiom != .phone ? 70 : 35.5))
                                
                                VStack(alignment: .leading) {
                                    Text(task.object)
                                        .font(UIDevice.current.userInterfaceIdiom != .phone ? .largeTitle : .title)
                                        .fontWeight(.bold)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.1)
                                    
                                    Text("No. \(index + 1)")
                                        .font(UIDevice.current.userInterfaceIdiom != .phone ? .title : .title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.gray)
                                }
                                .padding(.leading)
                            }
                            .padding(.horizontal, 5)
                        }
                        
                        HStack {
                            VStack {
                                Text(UIDevice.current.userInterfaceIdiom != .phone ? "Elapsed Time" : "Time")
                                    .foregroundColor(.cyan)
                                    .font(.system(size: UIDevice.current.userInterfaceIdiom != .phone ? 40 : 20))
                                    .fontWeight(.bold)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.1)
                                
                                Text(elapsedTime.truncate(places: 1).description + "s")
                                    .foregroundColor(.cyan)
                                    .font(.system(size: UIDevice.current.userInterfaceIdiom != .phone ? 60 : 30))
                                    .fontWeight(.heavy)
                            }
                            
                            Spacer()
                            
                            VStack {
                                Text("Accuracy")
                                    .foregroundColor(.green)
                                    .font(.system(size: UIDevice.current.userInterfaceIdiom != .phone ? 40 : 20))
                                    .fontWeight(.bold)
                                
                                Text(currentPlayerScore != nil ? currentPlayerScore!.truncate(places: 2).description + "%" : "---")
                                    .foregroundColor(currentPlayerScore != nil ? .green : .secondary)
                                    .font(.system(size: UIDevice.current.userInterfaceIdiom != .phone ? 60 : 30))
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
                        playAudio(fileName: "Lounge Drum and Bass", type: "mp3")
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Exit Practice")
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
                playAudio(fileName: getRandomBattleThemeFilename(), type: "mp3")
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
        .dynamicTypeSize(.medium).statusBar(hidden: true)
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
            var drawingImage = background.mergeWith(topImage: canvasView.drawing.image(from: canvasBounds, scale: UIScreen.main.scale).tint(with: .black)!)
            
            // Resize the image
            drawingImage = drawingImage.resizeImage(image: drawingImage, newWidth: 256)!
            
            // Get the probabilities for every drawing
            try ImagePredictor().makePredictions(with: {
                if task.object <= "Backpack" {
                    return .one
                } else if task.object <= "Bed" {
                    return .two
                } else if task.object <= "Bowtie" {
                    return .three
                } else if task.object <= "Cake" {
                    return .four
                } else if task.object <= "Cat" {
                    return .five
                } else if task.object <= "Computer" {
                    return .six
                } else if task.object <= "Diving Board" {
                    return .seven
                } else if task.object <= "Elephant" {
                    return .eight
                } else if task.object <= "Fish" {
                    return .nine
                } else if task.object <= "Giraffe" {
                    return .ten
                } else if task.object <= "Helicopter" {
                    return .eleven
                } else if task.object <= "Hurricane" {
                    return .tweleve
                } else if task.object <= "Leg" {
                    return .thirteen
                } else if task.object <= "Matches" {
                    return .fourteen
                } else if task.object <= "Mug" {
                    return .fifteen
                } else if task.object <= "Palm Tree" {
                    return .sixteen
                } else if task.object <= "Pickup Truck" {
                    return .seventeen
                } else if task.object <= "Power Outlet" {
                    return .eighteen
                } else if task.object <= "Rollerskates" {
                    return .nineteen
                } else if task.object <= "Shoe" {
                    return .twenty
                } else if task.object <= "Snowman" {
                    return .twentyone
                } else if task.object <= "Stereo" {
                    return .twentytwo
                } else if task.object <= "Swing Set" {
                    return .twentythree
                } else if task.object <= "Toe" {
                    return .twentyfour
                } else if task.object <= "Trumpet" {
                    return .twentyfive
                } else if task.object <= "Wine Glass" {
                    return .twentysix
                } else {
                    return .twentyseven
                }
            }(), for: drawingImage, completionHandler: { predictions in
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
        PracticeView(task: Task.taskList[0], index: 0)
            .previewInterfaceOrientation(.landscapeRight)
    }
}
