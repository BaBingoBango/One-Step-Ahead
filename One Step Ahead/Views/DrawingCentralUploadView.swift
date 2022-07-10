//
//  DrawingCentralUploadView.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 7/9/22.
//

import SwiftUI
import CloudKit

struct DrawingCentralUploadView: View {
    
    /// Whether or not the user has enabled Auto-Upload. This value is persisted inside UserDefaults.
    @AppStorage("isAutoUploadOn") var isAutoUploadOn = false
    var game: GameState
    @Environment(\.presentationMode) private var presentationMode
    @Binding var uploadOperationStatus: CloudKitOperationStatus
    @State var isShowingFailAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Circle()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.width / 7, height: UIScreen.main.bounds.width / 7)
                        .foregroundColor(.white)
                        .opacity(0.15)
                    
                    Image(systemName: "icloud.and.arrow.up")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.blue)
                        .shadow(radius: 10)
                        .shadow(radius: 10)
                        .frame(width: UIScreen.main.bounds.width / 7 / 1.5, height: UIScreen.main.bounds.width / 7 / 1.5)
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
                                .foregroundColor(.white)
                        }
                        .modifier(RectangleWrapper(fixedHeight: 50, color: .secondary, opacity: 1.0))
                    } else {
                        Button(action: {
                            startUploadOperation()
                        }) {
                            Text("Upload Drawing")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .modifier(RectangleWrapper(fixedHeight: 50, color: .blue, opacity: 1.0))
                        }
                    }
                }
            }
            .padding([.leading, .bottom, .trailing])
            .alert(isPresented: $isShowingFailAlert) {
                Alert(title: Text("Drawing Upload Failed"), message: Text("Check that you are connected to the Internet and signed in to iCloud in Settings."), dismissButton: .default(Text("Close")))
            }
            
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Done")
                            .fontWeight(.bold)
                    }
                }
            })
        }
        .dynamicTypeSize(.medium)
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            if isAutoUploadOn {
                startUploadOperation()
            }
        }
    }
    
    // MARK: - View Functions
    func startUploadOperation() {
        uploadOperationStatus = .inProgress
        
        let drawingRecord = CKRecord(recordType: CKRecord.RecordType("Drawing"))
        
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        
        drawingRecord["Image"] = CKAsset(fileURL: URL(fileURLWithPath: paths.first!).appendingPathComponent("\(game.task.object).\(game.currentRound).png"))
        drawingRecord["Object"] = game.task.object
        drawingRecord["Score"] = game.playerScores.last!
        
        let uploadOperation = CKModifyRecordsOperation(recordsToSave: [drawingRecord])
        
        uploadOperation.perRecordSaveBlock = { (_ recordID: CKRecord.ID, _ saveResult: Result<CKRecord, Error>) -> Void in
            switch saveResult {
            case .success(_):
                uploadOperationStatus = .success
                self.presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                uploadOperationStatus = .failure
                isShowingFailAlert = true
                print(error.localizedDescription)
            }
        }
        
        CKContainer(identifier: "iCloud.One-Step-Ahead").publicCloudDatabase.add(uploadOperation)
    }
}

struct DrawingCentralUploadView_Previews: PreviewProvider {
    static var previews: some View {
        DrawingCentralUploadView(game: GameState(), uploadOperationStatus: .constant(.notStarted))
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
