//
//  DrawingCentralUploadView.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 7/9/22.
//

import SwiftUI
import CloudKit

/// The view for uploading the player's final drawing of a game to Drawing Central.
struct DrawingCentralUploadView: View {
    
    // MARK: - View Variables
    /// Whether or not the user has enabled Auto-Upload. This value is persisted inside UserDefaults.
    @AppStorage("isAutoUploadOn") var isAutoUploadOn = false
    /// The game state of the game that acted as the source for this view.
    var game: GameState
    /// The action that dismisses this view.
    @Environment(\.dismiss) private var dismiss
    /// The status of this view's CloudKit upload operation.
    @Binding var uploadOperationStatus: CloudKitOperationStatus
    /// Whether or not an alert representing upload failure is being presented.
    @State var isShowingFailAlert = false
    
    var body: some View {
        /// The size of the circle behind the upload icon.
        let circleSize = screenWidth / 7
        
        NavigationStack {
            VStack {
                ZStack {
                    Circle()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: circleSize, height: circleSize)
                        .foregroundStyle(.white)
                        .opacity(0.15)
                    
                    Image(systemName: "icloud.and.arrow.up")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.blue)
                        .shadow(radius: 10)
                        .shadow(radius: 10)
                        .frame(width: circleSize / 1.5, height: circleSize / 1.5)
                }
                
                Text("Upload to Drawing Central")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Connect to the Internet to anonymously share your beautiful art and score with the world! Your drawing and score will be uploaded to the server and avaliable for other users to view.")
                    .padding(.top, 1)
                
                Spacer()
                
                if uploadOperationStatus == .inProgress {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .modifier(RectangleWrapper(fixedHeight: 50, color: .secondary, opacity: 1.0))
                } else {
                    if uploadOperationStatus == .success {
                        HStack {
                            Image(systemName: "checkmark")
                                .font(Font.body.weight(.bold))
                                .imageScale(.large)
                            
                            Text("Drawing Uploaded!")
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                        .modifier(RectangleWrapper(fixedHeight: 50, color: .secondary, opacity: 1.0))
                    } else {
                        Button(action: {
                            startUploadOperation()
                        }) {
                            Text("Upload Drawing")
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .modifier(RectangleWrapper(fixedHeight: 50, color: .blue, opacity: 1.0))
                        }
                    }
                }
            }
            .padding([.leading, .bottom, .trailing])
            .alert("Drawing Upload Failed", isPresented: $isShowingFailAlert) {
                Button("Close") {}
            } message: {
                Text("Check that you are connected to the Internet and signed in to iCloud in Settings.")
            }
            
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Done")
                            .fontWeight(.bold)
                    }
                }
            })
        }
        .dynamicTypeSize(.medium).statusBar(hidden: true)
        .onAppear {
            if isAutoUploadOn {
                startUploadOperation()
            }
        }
    }
    
    // MARK: - View Functions
    /// Uploads the player's final drawing and score to Drawing Central's public CloudKit database.
    func startUploadOperation() {
        uploadOperationStatus = .inProgress
        
        let drawingRecord = CKRecord(recordType: CKRecord.RecordType("Drawing"))
        drawingRecord["Image"] = CKAsset(fileURL: getDocumentsDirectory().appending(path: "\(game.task.object).\(game.currentRound).png"))
        drawingRecord["Object"] = game.task.object
        drawingRecord["Score"] = game.playerScores.last ?? 0.0
        
        Task {
            do {
                _ = try await CKContainer(identifier: "iCloud.One-Step-Ahead").publicCloudDatabase.save(drawingRecord)
                uploadOperationStatus = .success
                dismiss()
            } catch {
                uploadOperationStatus = .failure
                isShowingFailAlert = true
                print(error.localizedDescription)
            }
        }
    }
}

#Preview(traits: .landscapeLeft) {
    DrawingCentralUploadView(game: GameState(), uploadOperationStatus: .constant(.notStarted))
}
