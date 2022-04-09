//
//  GameView.swift
//  
//
//  Created by Ethan Marshall on 4/7/22.
//

import SwiftUI
import PencilKit

/// The view displaying the elements of the currently running game; originates from the New Game screen.
struct GameView: View {
    
    // MARK: - Variables
    /// The state of the app's currently running game, passed in from the New Game screen.
    @State var game: GameState = GameState()
    /// A 0.1-second-interval timer responsible for triggering game events.
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    /// The text displaying at the top of the view under the round number.
    @State var commandText = "Get ready..."
    /// Whether or not the Done! button should be active.
    @State var isDoneButtonEnabled = false
    
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
                            print("Deleting...count: \(allDrawings.count)")
                            isDeletingDrawing = true
                            canvasView.drawing = allDrawings.count >= 2 ? allDrawings[allDrawings.count - 2] : PKDrawing()
                            if allDrawings.count >= 1 {
                                allDrawings.removeLast()
                            }
                            isDeletingDrawing = false
                            print("Deleted! count: \(allDrawings.count)")
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
                            print("Saving...count: \(allDrawings.count)")
                            if !isDeletingDrawing {
                                allDrawings.append(canvasView.drawing)
                                print("APPENDED! count: \(allDrawings.count)")
                            }
                            print("Saved! Count: \(allDrawings.count)")
                        })
                    }
                    .aspectRatio(1.0, contentMode: .fit)
                    
                    Text("Current Score")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    if game.currentRound != 1 {
                        Text(game.playerScores[game.currentRound - 1].description)
                            .font(.largeTitle)
                            .fontWeight(.bold)
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
                        Text("The AI")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Rectangle()
                        .opacity(0.2)
                        .aspectRatio(1.0, contentMode: .fit)
                    
                    Text("Current Score")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    if game.currentRound != 1 {
                        Text(game.AIscores[game.currentRound - 1].description)
                            .font(.largeTitle)
                            .fontWeight(.bold)
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
        .onReceive(timer) { input in
            // Update the timer
            game.timeLeft -= 0.1
        }
    }
    
    // MARK: - Functions
    /// Code to execute when a new game round is starting.
    func setupNewRound() {
        // Reset the timer to 20 seconds
        game.timeLeft = 20
        
        // Reset the player canvas
        canvasView.drawing = PKDrawing()
        allDrawings = []
        
        // Enable canvas editing
        // FIXME: No code
        
        // Update the round number
        game.currentRound += 1
        
        // Update the command
        commandText = game.task.commandPrompt
        
        // Enable the Done! button
        isDoneButtonEnabled = true
    }
    
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
