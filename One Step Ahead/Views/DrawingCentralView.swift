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
    @Environment(\.screenLayout) private var layout
    
    // MARK: - View Variables
    /// The action that dismisses this view.
    @Environment(\.dismiss) private var dismiss
    /// The SpriteKit scene for the graphics of this view.
    @State var graphicsScene = SKScene(fileNamed: "\(UIDevice.current.userInterfaceIdiom == .phone ? "iOS " : "")Gallery View Graphics")!
    /// The task to show drawings for in this view.
    var task: DrawingTask
    /// The set of drawings that have been downloaded from Drawing Central.
    @State var downloadedDrawings: [Drawing] = []
    /// The status of this view's CloudKit query operation.
    @State var queryOperationStatus: CloudKitOperationStatus = .notStarted
    /// Whether or not the user has chosen ascending sort for the scores of the downloaded drawings.
    @State var sortingAscending = false
    
    // MARK: - View Body
    var body: some View {
        let headerView = HStack {
            Text(task.emoji)
                .font(.system(size: layout.isRegular ? 100 : 60))
                .padding([.trailing, .top])
            
            VStack(alignment: .leading) {
                Text("Drawing Central")
                    .font(.system(size: layout.isRegular ? 30 : 20))
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text(task.object)
                    .font(.system(size: layout.isRegular ? 50 : 30))
                    .fontWeight(.bold)
            }
        }
        
        NavigationStack {
            ZStack {
                GameBackground(scene: graphicsScene)
                
                ScrollView {
                    VStack {
                        headerView
                        
                        if queryOperationStatus == .inProgress {
                            VStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(layout.isRegular ? 2 : 1.5)
                                
                                Text("Connecting...")
                                    .font(layout.isRegular ? .title2 : .body)
                                    .foregroundStyle(Color.secondary)
                                    .fontWeight(.bold)
                                    .padding(.top, layout.isRegular ? 25 : 15)
                                
                                Spacer()
                            }
                        } else if queryOperationStatus == .failure {
                            VStack {
                                Image(systemName: "xmark.icloud.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundStyle(Color.secondary)
                                    .frame(height: 50)
                                
                                Text("Could Not Connect")
                                    .font(layout.isRegular ? .title2 : .body)
                                    .foregroundStyle(Color.secondary)
                                    .fontWeight(.bold)
                                    .padding(.top, 5)
                                
                                Text("Check you are connected to the Internet and try again.")
                                    .font(layout.isRegular ? .title3 : .callout)
                                    .foregroundStyle(Color.secondary)
                                
                                Button(action: {
                                    launchQueryOperation()
                                }) {
                                    HStack {
                                        let tryAgainButton =
                                        Text("Try Again")
                                            .font(layout.isRegular ? .title3 : .body)
                                            .foregroundStyle(.white)
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
                                        .foregroundStyle(Color.secondary)
                                        .frame(height: layout.isRegular ? 75 : 50)
                                    
                                    Text("No Drawings Yet!")
                                        .font(layout.isRegular ? .title : .body)
                                        .foregroundStyle(Color.secondary)
                                        .fontWeight(.bold)
                                        .padding(.top, layout.isRegular ? 15 : 5)
                                    
                                    Text("Perhaps the first great artist is you!")
                                        .font(layout.isRegular ? .title2 : .callout)
                                        .foregroundStyle(Color.secondary)
                                        .padding(.top, layout.isRegular ? 0 : 0)
                                }
                            } else {
                                HStack(spacing: 0) {
                                    let sortButtonRectangle =
                                    Rectangle()
                                        .frame(height: 40)
                                        .foregroundStyle(.black)
                                        .opacity(0.25)
                                        .clipShape(.rect(cornerRadius: 13))
                                    
                                    Button(action: {
                                        sortingAscending.toggle()
                                        launchQueryOperation()
                                    }) {
                                        ZStack {
                                            sortButtonRectangle
                                            
                                            HStack {
                                                Image(systemName: sortingAscending ? "arrow.up" : "arrow.down")
                                                    .foregroundStyle(.white)
                                                
                                                Text("Sorting \(sortingAscending ? "Low to High" : "High to Low")")
                                                    .foregroundStyle(.white)
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
                                
                                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: layout.width < ScreenLayout.regularMinimumWidth ? 3 : 6)) {
                                    ForEach(downloadedDrawings) { eachDrawing in
                                        ZStack {
                                            Image(uiImage: eachDrawing.uiImage ?? UIImage())
                                                .resizable()
                                                .aspectRatio(1, contentMode: .fit)
                                                .clipShape(.rect(cornerRadius: 20))
                                            
                                            VStack {
                                                Spacer()
                                                
                                                ZStack {
                                                    Rectangle()
                                                        .frame(height: layout.isRegular ? 30 : 20)
                                                        .foregroundStyle(.green)
                                                        .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
                                                    
                                                    Text("\(String(eachDrawing.score.truncate(places: 1)))%")
                                                        .font(layout.isRegular ? .title3 : .callout)
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
            .ignoresSafeArea(edges: .top)
            
            // MARK: - Navigation View Settings
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
        
        // MARK: - View Launch Code
        .onAppear {
            launchQueryOperation()
        }
    }
    
    // MARK: - View Functions
    /// Downloads the Drawing Central drawings for this view's task, sorted by score.
    func launchQueryOperation() {
        queryOperationStatus = .inProgress
        
        let query = CKQuery(recordType: "Drawing", predicate: NSPredicate(format: "Object = %@", task.object))
        query.sortDescriptors = [NSSortDescriptor(key: "Score", ascending: sortingAscending)]
        
        Task {
            do {
                let (matchResults, _) = try await CKContainer(identifier: "iCloud.One-Step-Ahead").publicCloudDatabase.records(matching: query)
                
                var drawingsToAdd: [Drawing] = []
                for (_, recordResult) in matchResults {
                    switch recordResult {
                    case .success(let record):
                        if let newImage = record["Image"] as? CKAsset, let newObject = record["Object"] as? String, let newScore = record["Score"] as? Double {
                            drawingsToAdd.append(Drawing(image: newImage, object: newObject, score: newScore))
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
                
                downloadedDrawings = drawingsToAdd
                queryOperationStatus = .success
            } catch {
                queryOperationStatus = .failure
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - View Preview
#Preview(traits: .landscapeLeft) {
    DrawingCentralView(task: DrawingTask.taskList[DrawingTask.taskList.firstIndex(where: { $0.object == "Apple" })!])
}
