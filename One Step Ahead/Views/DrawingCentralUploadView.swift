//
//  DrawingCentralUploadView.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 7/9/22.
//

import SwiftUI
import CloudKit

struct DrawingCentralUploadView: View {
    
    var game: GameState
    @Environment(\.presentationMode) private var presentationMode
    @State var isUploading = false
    @Binding var uploadSuccess: Bool
    
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
                
                if isUploading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .modifier(RectangleWrapper(fixedHeight: 50, color: .secondary, opacity: 1.0))
                } else {
                    if uploadSuccess {
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
                            isUploading = true
                            
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
                                    isUploading = false
                                    uploadSuccess = true
                                case .failure(let error):
                                    isUploading = false
                                    print(error.localizedDescription)
                                }
                            }
                            
                            CKContainer(identifier: "iCloud.One-Step-Ahead").publicCloudDatabase.add(uploadOperation)
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
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct DrawingCentralUploadView_Previews: PreviewProvider {
    static var previews: some View {
        DrawingCentralUploadView(game: GameState(), uploadSuccess: .constant(false))
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
