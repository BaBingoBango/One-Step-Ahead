//
//  GameEndView.swift
//  
//
//  Created by Ethan Marshall on 4/19/22.
//

import SwiftUI
import SpriteKit

/// The screen displayed when a game finishes.
struct GameEndView: View {
    @Environment(\.screenLayout) private var layout
    
    // MARK: - View Variables
    @Environment(\.dismiss) private var dismiss
    /// Whether or not the game sequence is being presented as a full screen modal.
    @Binding var isShowingGameSequence: Bool
    /// The state of the app's currently running game, passed in from the Game View.
    @State var game: GameState
    /// Whether or not the victory/defeat jingle has played.
    @State var hasPlayedJingle = false
    /// Whether or not the Drawing Central upload view is being presented.
    @State var showingUploadView = false
    /// The status of the Drawing Central upload operation.
    @State var uploadOperationStatus = CloudKitOperationStatus.notStarted
    
    /// Whether or not the user has enabled Auto-Upload. This value is persisted inside UserDefaults.
    @AppStorage("isAutoUploadOn") var isAutoUploadOn = false
    @State var isShowingDrawingCentral = false
    
    /// The SpriteKit scene for the graphics of this view.
    @State var graphicsScene = SKScene(fileNamed: "\(UIDevice.current.userInterfaceIdiom == .phone ? "iOS " : "")Game End View Graphics")!
    
    /// The arrangement of the buttons below the results: side by side when the window is wide enough for both, and stacked otherwise.
    private var endButtonsLayout: AnyLayout {
        layout.isPhone || layout.width >= 800 ? AnyLayout(HStackLayout(spacing: 30)) : AnyLayout(VStackLayout(spacing: 15))
    }
    
    // MARK: - Computed Properties
    /// The player score from the last round of play.
    var lastPlayerScore: Double {
        game.playerScores.last!
    }
    /// The AI score from the last round of play.
    var lastAIscore: Double {
        game.AIscores.last!
    }
    /// The player's drawing from the last round of play.
    var playerDrawing: UIImage {
        getImageFromDocuments("\(game.task.object).\(game.currentRound).png") ?? UIImage()
    }
    /// The combatant who won the game.
    var winner: Combatant {
        if lastPlayerScore >= lastAIscore && lastPlayerScore >= Double(game.playerWinThreshold) {
            return .player
        } else {
            return .AI
        }
    }
    
    // MARK: - View Body
    var body: some View {
        ZStack {
            GameBackground(scene: graphicsScene)
            
            HStack {
                Spacer()
                
                VStack {
                    Text("\(game.gameScore) pts.")
                        .font(layout.isRegular ? .largeTitle : .title2)
                        .fontWeight(.heavy)
                        .foregroundStyle(Color.gold)
                        .padding([.top, .trailing])
                    
                    Spacer()
                }
            }
            
            VStack(spacing: 0) {
                Text(winner == .player ? "You win!" : "You lose...")
                    .foregroundStyle(winner == .player ? Color.gold : .red)
                    .font(.system(size: layout.isRegular ? 70 : 45))
                    .fontWeight(.black)
                    .padding(.top, layout.isRegular ? 15 : 0)
                
                HStack(spacing: 0) {
                    Text("Solution: ")
                        .font(layout.isRegular ? .title : .body)
                        .fontWeight(layout.isRegular ? .semibold : .regular)
                    
                    Text(game.task.object)
                        .font(layout.isRegular ? .title : .body)
                        .fontWeight(layout.isRegular ? .heavy : .bold)
                }
                
                HStack(alignment: .center) {
                    Spacer()
                    
                    VStack {
                        HStack(alignment: .center, spacing: 0) {
                            GameEndShareButtonsView()
                            
                            Image(uiImage: playerDrawing)
                                .resizable()
                                .aspectRatio(1.0, contentMode: .fit)
                                .frame(width: layout.isRegular ? 175 : 100)
                                .clipShape(.rect(cornerRadius: 25))
                                .padding(.horizontal, 5)
                            
                            VStack {
                                if layout.isCompact {
                                    Spacer()
                                }
                                
                                ShareLink(item: Image(uiImage: playerDrawing), preview: SharePreview(game.task.object, image: Image(uiImage: playerDrawing))) {
                                    ZStack {
                                        Circle()
                                            .foregroundStyle(.gray)
                                            .frame(width: layout.isRegular ? 50 : 40, height: layout.isRegular ? 50 : 40)
                                        
                                        Image(systemName: "square.and.arrow.up")
                                            .resizable()
                                            .foregroundStyle(.white)
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: layout.isRegular ? 30 : 20, height: layout.isRegular ? 30 : 20)
                                    }
                                }
                                .accessibilityLabel("Share Drawing")
                                
                                Button(action: {
                                    showingUploadView = true
                                }) {
                                    ZStack {
                                        Circle()
                                            .foregroundStyle(.gray)
                                            .opacity(uploadOperationStatus == .success ? 0.5 : 1)
                                            .frame(width: layout.isRegular ? 50 : 40, height: layout.isRegular ? 50 : 40)
                                        
                                        Image(systemName: uploadOperationStatus == .success ? "checkmark.icloud" : "icloud.and.arrow.up")
                                            .resizable()
                                            .foregroundStyle(.white)
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: layout.isRegular ? 30 : 20, height: layout.isRegular ? 30 : 20)
                                    }
                                }
                                .disabled(uploadOperationStatus == .success)
                                .accessibilityLabel("Upload to Drawing Central")
                                .sheet(isPresented: $showingUploadView) {
                                    DrawingCentralUploadView(game: game, uploadOperationStatus: $uploadOperationStatus)
                                }
                                
                                Spacer()
                            }
                            .frame(height: layout.isRegular ? 175 : 100)
                        }
                        
                        Text("\(String(lastPlayerScore.truncate(places: 1)))%")
                            .font(.title)
                            .foregroundStyle(.green)
                            .fontWeight(.heavy)
                    }
                    
                    Spacer()
                    
                    Rectangle()
                        .foregroundStyle(.white)
                        .frame(width: 7)
                        .clipShape(.rect(cornerRadius: 10))
                        .padding(.vertical, 70)
                    
                    Spacer()
                    
                    VStack {
                        HStack(alignment: .center, spacing: 0) {
                            GameEndShareButtonsView()
                            
                            ZStack {
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            gradient: .init(colors: [.gray.opacity(0.6), .gray]),
                                            startPoint: .init(x: 0.25, y: 0.25),
                                        endPoint: .init(x: 0.5, y: 1)
                                        
                                    ))
                                    .aspectRatio(1.0, contentMode: .fit)
                                    .frame(width: layout.isRegular ? 175 : 100, height: layout.isRegular ? 175 : 100)
                                    .clipShape(.rect(cornerRadius: 25))
                                
                                Image("robot")
                                    .scaleEffect(layout.isRegular ? 0.8 : 0.4)
                                    .frame(width: layout.isRegular ? 175 : 100, height: layout.isRegular ? 175 : 100)
                            }
                            .padding(.horizontal, 5)
                            
                            GameEndShareButtonsView()
                        }
                        
                        Text("\(String(lastAIscore.truncate(places: 1)))%")
                            .font(.title)
                            .foregroundStyle(.red)
                            .fontWeight(.heavy)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, layout.isRegular ? 0 : 0)
                
                endButtonsLayout {
                    NavigationLink(destination: PlayerScoresView(game: game)) {
                        if layout.isRegular {
                            Text("View Round History")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            .modifier(RectangleWrapper(fixedHeight: 60, color: .gray, opacity: 1.0))
                            .frame(width: 375)
                        } else {
                            Text("View Round History")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            .modifier(RectangleWrapper(fixedHeight: 50, color: .gray, opacity: 1.0))
                        }
                    }
                    
                    Button(action: {
                        isShowingDrawingCentral = true
                    }) {
                        if layout.isRegular {
                            Text("View on Drawing Central")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .modifier(RectangleWrapper(fixedHeight: 60, color: .teal, opacity: 1.0))
                                .frame(width: 375)
                        } else {
                            Text("View on Drawing Central")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .modifier(RectangleWrapper(fixedHeight: 50, color: .teal, opacity: 1.0))
                        }
                    }
                    .fullScreenCover(isPresented: $isShowingDrawingCentral) {
                        DrawingCentralView(task: game.task)
                            .measuringScreenLayout()
                    }
                }
                .padding(.bottom, layout.isRegular ? 50 : 10)
            }
            .padding(.top)
        }
        .dynamicTypeSize(.medium).statusBar(hidden: true)
        .ignoresSafeArea(edges: .top)
        .onAppear {
            // MARK: View Launch Code
            // Adjust the music
            stopAudio()
            if !hasPlayedJingle {
                playAudioOnce(fileName: winner == .player ? "Victory Jingle" : "Defeat Jingle", type: "mp3")
                hasPlayedJingle = true
            }
            
            // Award game-end achievements
            if winner == .player && game.difficulty == .easy && game.gameMode == .demystify {
                reportAchievementProgress("A_Minor_Test_of_Strength")
            }
            if winner == .player && game.difficulty == .lunatic && game.gameMode == .flyingBlind {
                reportAchievementProgress("A_Major_Test_of_Strength")
            }
            if winner == .player && game.currentRound == 1 {
                reportAchievementProgress("Formula_Won")
            }
            if winner == .AI && game.currentRound == 1 {
                reportAchievementProgress("Formula_Lost")
            }
            if game.currentRound >= 10 {
                reportAchievementProgress("The_Long_Haul")
            }
            if game.currentRound >= 20 {
                reportAchievementProgress("The_Really_Long_Haul")
            }
            
            // Launch the Drawing Central upload view if Auto-Upload is on and if we haven't already attempted an upload
            if isAutoUploadOn && uploadOperationStatus == .notStarted {
                showingUploadView = true
            }
        }
        
        // MARK: Navigation Bar Settings
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    playAudio(fileName: "Lounge Drum and Bass", type: "mp3")
                    isShowingGameSequence = false
                }) {
                    Text("Return To Menu")
                        .fontWeight(.bold)
                        .foregroundStyle(.red)
                }
            }
        }
    }
}

#Preview(traits: .landscapeLeft) {
    NavigationStack {
        GameEndView(isShowingGameSequence: .constant(true), game: GameState(playerScores: [99.9], AIscores: [69.4]))
    }
}

/// A view representing progress towards a goal via a colored circle and text.
struct PercentCircle: View {
    
    // Variables
    var percent: Double
    var circleWidth: CGFloat = 150
    var circleHeight: CGFloat = 150
    var color: Color = .green
    var font: Font = .largeTitle
    
    var body: some View {
        HStack(spacing: 50) {
            ZStack {
                Circle()
                    .foregroundStyle(color)
                    .frame(width: circleWidth, height: circleHeight)
                
                Text("\(percent.description)%")
                    .font(font)
                    .fontWeight(.heavy)
                    .frame(width: circleWidth - 20)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
            }
        }
        .dynamicTypeSize(.medium).statusBar(hidden: true)
    }
}

/// The buttons used in the game end view to access share and upload options.
struct GameEndShareButtonsView: View {
    @Environment(\.screenLayout) private var layout
    var body: some View {
        VStack {
            if layout.isRegular {
                Spacer()
            }
            
            ZStack {
                Circle()
                    .foregroundStyle(.gray)
                    .frame(width: layout.isRegular ? 50 : 40, height: layout.isRegular ? 50 : 40)
                
                Image(systemName: "square.and.arrow.up")
                    .resizable()
                    .foregroundStyle(.white)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: layout.isRegular ? 30 : 20, height: layout.isRegular ? 30 : 20)
            }
            
            ZStack {
                Circle()
                    .foregroundStyle(.gray)
                    .frame(width: layout.isRegular ? 50 : 40, height: layout.isRegular ? 50 : 40)
                
                Image(systemName: "icloud.and.arrow.up")
                    .resizable()
                    .foregroundStyle(.white)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: layout.isRegular ? 30 : 20, height: layout.isRegular ? 30 : 20)
            }
            
            Spacer()
        }
        .dynamicTypeSize(.medium).statusBar(hidden: true)
        .frame(height: layout.isRegular ? 175 : 100)
        .hidden()
    }
}
