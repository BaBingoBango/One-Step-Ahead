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
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    /// The SpriteKit scene for the graphics of this view.
    @State var graphicsScene = SKScene(fileNamed: "\(UIDevice.current.userInterfaceIdiom == .phone ? "iOS " : "")Gallery View Graphics")!
    /// The task to show drawings for in this view.
    var task: Task
    @State var downloadedDrawings: [Drawing] = []
    @State var queryOperationStatus: CloudKitOperationStatus = .notStarted
    @State var sortingAscending = false
    
    // MARK: - View Body
    var body: some View {
        let headerView = HStack {
            Text(task.emoji)
                .font(.system(size: UIDevice.current.userInterfaceIdiom != .phone ? 100 : 60))
                .padding([.trailing, .top])
            
            VStack(alignment: .leading) {
                Text("Drawing Central")
                    .font(.system(size: UIDevice.current.userInterfaceIdiom != .phone ? 30 : 20))
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text(task.object)
                    .font(.system(size: UIDevice.current.userInterfaceIdiom != .phone ? 50 : 30))
                    .fontWeight(.bold)
            }
        }
        
        NavigationView {
            ZStack {
                SpriteView(scene: graphicsScene)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack {
                        headerView
                        
                        if queryOperationStatus == .inProgress {
                            VStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(UIDevice.current.userInterfaceIdiom != .phone ? 2 : 1.5)
                                
                                Text("Connecting...")
                                    .font(UIDevice.current.userInterfaceIdiom != .phone ? .title2 : .body)
                                    .foregroundColor(.secondary)
                                    .fontWeight(.bold)
                                    .padding(.top, UIDevice.current.userInterfaceIdiom != .phone ? 25 : 15)
                                
                                Spacer()
                            }
                        } else if queryOperationStatus == .failure {
                            VStack {
                                Image(systemName: "xmark.icloud.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.secondary)
                                    .frame(height: 50)
                                
                                Text("Could Not Connect")
                                    .font(UIDevice.current.userInterfaceIdiom != .phone ? .title2 : .body)
                                    .foregroundColor(.secondary)
                                    .fontWeight(.bold)
                                    .padding(.top, 5)
                                
                                Text("Check you are connected to the Internet and try again.")
                                    .font(UIDevice.current.userInterfaceIdiom != .phone ? .title3 : .callout)
                                    .foregroundColor(.secondary)
                                
                                Button(action: {
                                    launchQueryOperation()
                                }) {
                                    HStack {
                                        let tryAgainButton =
                                        Text("Try Again")
                                            .font(UIDevice.current.userInterfaceIdiom != .phone ? .title3 : .body)
                                            .foregroundColor(.white)
                                            .fontWeight(.bold)
                                            .modifier(RectangleWrapper(fixedHeight: 45, color: .blue, opacity: 1.0))
                                        
                                        tryAgainButton
                                            .hidden()
                                        
                                        tryAgainButton
                                        
                                        tryAgainButton
                                            .hidden()
                                    }
                                }
                                
                                Spacer()
                            }
                        }
                        
                        if queryOperationStatus == .success {
                            if downloadedDrawings.isEmpty {
                                VStack {
                                    Image(systemName: "rectangle.portrait.on.rectangle.portrait.slash")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(.secondary)
                                        .frame(height: UIDevice.current.userInterfaceIdiom != .phone ? 75 : 50)
                                    
                                    Text("No Drawings Yet!")
                                        .font(UIDevice.current.userInterfaceIdiom != .phone ? .title : .body)
                                        .foregroundColor(.secondary)
                                        .fontWeight(.bold)
                                        .padding(.top, UIDevice.current.userInterfaceIdiom != .phone ? 15 : 5)
                                    
                                    Text("Perhaps the first great artist is you!")
                                        .font(UIDevice.current.userInterfaceIdiom != .phone ? .title2 : .callout)
                                        .foregroundColor(.secondary)
                                        .padding(.top, UIDevice.current.userInterfaceIdiom != .phone ? 0 : 0)
                                }
                            } else {
                                HStack(spacing: 0) {
                                    let sortButtonRectangle =
                                    Rectangle()
                                        .frame(height: 40)
                                        .foregroundColor(.black)
                                        .opacity(0.25)
                                        .cornerRadius(13)
                                    
                                    Button(action: {
                                        sortingAscending.toggle()
                                        launchQueryOperation()
                                    }) {
                                        ZStack {
                                            sortButtonRectangle
                                            
                                            HStack {
                                                Image(systemName: sortingAscending ? "arrow.up" : "arrow.down")
                                                    .foregroundColor(.white)
                                                
                                                Text("Sorting \(sortingAscending ? "Low to High" : "High to Low")")
                                                    .foregroundColor(.white)
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.1)
                                            }
                                            .padding(.horizontal)
                                        }
                                    }
                                    
                                    sortButtonRectangle
                                        .hidden()
                                    
                                    sortButtonRectangle
                                        .hidden()
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 5)
                                
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
                                                        .frame(height: UIDevice.current.userInterfaceIdiom != .phone ? 30 : 20)
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
                }
            }
            .edgesIgnoringSafeArea(.top)
            
            // MARK: - Navigation View Settings
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
        .dynamicTypeSize(.medium).statusBar(hidden: true)
        .navigationViewStyle(StackNavigationViewStyle())
        
        // MARK: - View Launch Code
        .onAppear {
            launchQueryOperation()
        }
    }
    
    // MARK: - View Functions
    func launchQueryOperation() {
        queryOperationStatus = .inProgress
        var drawingsToAdd: [Drawing] = []
        
        let query = CKQuery(recordType: "Drawing", predicate: NSPredicate(format: "Object = %@", task.object))
        query.sortDescriptors = [NSSortDescriptor(key: "Score", ascending: sortingAscending)]
        let queryOperation = CKQueryOperation(query: query)
        
        queryOperation.recordMatchedBlock = { (_ recordID: CKRecord.ID, _ recordResult: Result<CKRecord, Error>) -> Void in
            switch recordResult {
            case .success(let record):
                let newImage = record["Image"] as! CKAsset
                let newObject = record["Object"] as! String
                let newScore = record["Score"] as! Double
                
                let newDrawing = Drawing(image: newImage, object: newObject, score: newScore)
                drawingsToAdd.append(newDrawing)
            case .failure(let error):
                queryOperationStatus = .failure
                print(error.localizedDescription)
            }
        }
        
        queryOperation.queryResultBlock = { (_ operationResult: Result<CKQueryOperation.Cursor?, Error>) -> Void in
            switch operationResult {
            case .success(_):
                queryOperationStatus = .success
                downloadedDrawings = drawingsToAdd
                print("")
            case .failure(let error):
                queryOperationStatus = .failure
                print(error.localizedDescription)
            }
        }
        
        CKContainer(identifier: "iCloud.One-Step-Ahead").publicCloudDatabase.add(queryOperation)
    }
}

// MARK: - View Preview
struct DrawingCentralView_Previews: PreviewProvider {
    static var previews: some View {
        DrawingCentralView(task: Task.taskList[Task.taskList.firstIndex(where: { $0.object == "Apple" })!])
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
