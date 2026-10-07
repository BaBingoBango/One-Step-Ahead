//
//  GalleryView.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 5/19/22.
//

import SwiftUI
import SpriteKit

/// The view showing all the user's locked and unlocked drawings. It serves as the launch point for Practice and Play Game With.
struct GalleryView: View {
    @Environment(\.screenLayout) private var layout
    
    // MARK: View Variables
    /// A wrapper for the user's task-related save data. This value is presisted inside UserDefaults.
    @AppStorage("userTaskRecords") var userTaskRecords: UserTaskRecords = UserTaskRecords()
    /// The task that should be sent to a New Game view.
    @State var taskToPresent: DrawingTask? = nil
    /// Whether or not a New Game view is being presented.
    @State var isShowingNewGameView = false
    /// The task list, sorted alphabetically.
    var sortedTaskList = DrawingTask.taskList.sorted(by: { $0.object < $1.object })
    /// The SpriteKit scene for the graphics of this view.
    @State var graphicsScene = SKScene(fileNamed: "\(UIDevice.current.userInterfaceIdiom == .phone ? "iOS " : "")Gallery View Graphics")!
    
    // MARK: - View Body
    var body: some View {
        let galleryProgress = Double(userTaskRecords.records.count) / Double(DrawingTask.taskList.count)
        
        ZStack {
            GameBackground(scene: graphicsScene)
            
            VStack {
                ScrollView {
                    HStack {
                        ProgressCircleView(progress: galleryProgress, color: galleryProgress != 1.0 ? .blue : .gold, lineWidth: 10, imageName: "photo.artframe")
                            .aspectRatio(1.0, contentMode: .fill)
                        
                        VStack(alignment: .leading, spacing: -10) {
                            Text(galleryProgress != 1.0 ? "\((galleryProgress * 100.0).truncate(places: 1).description)%" : "100%")
                                .font(.system(size: layout.isRegular ? 120 : 65))
                                .fontWeight(.heavy)
                            Text(galleryProgress != 1.0 ? "Gallery Completion" : "Gallery Completion!")
                                .font(.system(size: layout.isRegular ? 40 : 27))
                                .fontWeight(.bold)
                        }
                    }
                    .padding(.top, layout.isRegular ? 75 : 37.5)
                    .padding(.bottom, layout.isRegular ? 75 : 37.5)
                    .fixedSize(horizontal: true, vertical: false)
                    .frame(maxWidth: .infinity)
                    
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: layout.width < ScreenLayout.regularMinimumWidth ? 3 : 6)) {
                        ForEach(0...sortedTaskList.count - 1, id: \.self) { index in
                            TaskRectangleView(taskToPresent: $taskToPresent, task: sortedTaskList[index], index: index)
                        }
                    }
                    .padding([.leading, .bottom, .trailing])
                }
            }
        }
        .dynamicTypeSize(.medium).statusBar(hidden: true)
        .navigationDestination(isPresented: $isShowingNewGameView) {
            NewGameMenuView(enforcedGameTask: taskToPresent)
        }
        .onChange(of: taskToPresent) { _, newValue in
            if newValue != nil {
                // We have a value from a task detail view! Time to activate a navigation link!
                isShowingNewGameView = true
            }
        }
        .onChange(of: isShowingNewGameView) { _, newValue in
            if newValue == false {
                taskToPresent = nil
            }
        }
        
        // MARK: Navigation View Settings
        .navigationTitle("Drawing Gallery")
        
    }
}

#Preview(traits: .landscapeRight) {
    GalleryView()
}
