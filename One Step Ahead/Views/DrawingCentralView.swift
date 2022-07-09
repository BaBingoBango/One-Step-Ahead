//
//  DrawingCentralView.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 7/9/22.
//

import SwiftUI
import SpriteKit
import CloudKit

/// The view showing all the Drawing Central drawings for a particular task.
struct DrawingCentralView: View {
    
    // MARK: - View Variables
    /// The SpriteKit scene for the graphics of this view.
    @State var graphicsScene = SKScene(fileNamed: "\(UIDevice.current.userInterfaceIdiom == .phone ? "iOS " : "")Gallery View Graphics")!
    /// The task to show drawings for in this view.
    var task: Task
    @State var downloadedDrawings: [Drawing] = []
    
    // MARK: - View Body
    var body: some View {
        ZStack {
            SpriteView(scene: graphicsScene)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack {
                    HStack {
                        Text(task.emoji)
                            .font(.system(size: UIDevice.current.userInterfaceIdiom != .phone ? 100 : 60))
                            .padding(.trailing)
                        
                        VStack(alignment: .leading) {
                            Text("Drawing Central")
                                .font(.system(size: UIDevice.current.userInterfaceIdiom != .phone ? 30 : 20))
                                .fontWeight(.bold)
                            
                            Text(task.object)
                                .font(.system(size: UIDevice.current.userInterfaceIdiom != .phone ? 50 : 30))
                                .fontWeight(.bold)
                        }
                    }
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 6)) {
                        ForEach(downloadedDrawings, id: \.ID) { eachDrawing in
                            ZStack {
                                Image(uiImage: UIImage(data: try! Data(contentsOf: eachDrawing.image.fileURL!))!)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fit)
                                    .cornerRadius(20)
                                
                                VStack {
                                    Spacer()
                                    
                                    ZStack {
                                        Rectangle()
                                            .frame(height: UIDevice.current.userInterfaceIdiom != .phone ? 30 : 15)
                                            .foregroundColor(.green)
                                            .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
                                        
                                        Text("\(String(eachDrawing.score.truncate(places: 1)))%")
                                            .font(UIDevice.current.userInterfaceIdiom != .phone ? .title3 : .callout)
                                            .fontWeight(.bold)
                                    }
                                }
                            }
                        }
                    }
                    .padding([.leading, .bottom, .trailing])
                }
            }
        }
        
        // MARK: - View Launch Code
        .onAppear {
            var drawingsToAdd: [Drawing] = []
            
            let queryOperation = CKQueryOperation(query: CKQuery(recordType: "Drawing", predicate: NSPredicate(format: "Object = %@", task.object)))
            
            queryOperation.recordMatchedBlock = { (_ recordID: CKRecord.ID, _ recordResult: Result<CKRecord, Error>) -> Void in
                switch recordResult {
                case .success(let record):
                    let newImage = record["Image"] as! CKAsset
                    let newObject = record["Object"] as! String
                    let newScore = record["Score"] as! Double
                    
                    let newDrawing = Drawing(image: newImage, object: newObject, score: newScore)
                    downloadedDrawings.append(newDrawing)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
            queryOperation.queryResultBlock = { (_ operationResult: Result<CKQueryOperation.Cursor?, Error>) -> Void in
                switch operationResult {
                case .success(_):
//                    downloadedDrawings = drawingsToAdd
                    print("")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
            CKContainer(identifier: "iCloud.One-Step-Ahead").publicCloudDatabase.add(queryOperation)
        }
    }
}

// MARK: - View Preview
struct DrawingCentralView_Previews: PreviewProvider {
    static var previews: some View {
        DrawingCentralView(task: Task.taskList[Task.taskList.firstIndex(where: { $0.object == "Apple" })!])
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
