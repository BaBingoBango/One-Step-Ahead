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
    
    // MARK: View Variables
    /// A wrapper for the user's task-related save data. This value is presisted inside UserDefaults.
    @AppStorage("userTaskRecords") var userTaskRecords: UserTaskRecords = UserTaskRecords()
    /// The task list, sorted alphabetically.
    var sortedTaskList = Task.taskList.sorted(by: { $0.object < $1.object })
    
    var body: some View {
        let galleryProgress = Double(userTaskRecords.records.count) / Double(Task.taskList.count)
        
        ZStack {
            SpriteView(scene: SKScene(fileNamed: "Gallery View Graphics")!)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ScrollView {
                    HStack {
                        ProgressCircleView(progress: galleryProgress, color: .blue, lineWidth: 10, imageName: "photo.artframe")
                            .aspectRatio(1.0, contentMode: .fill)
                        
                        VStack(alignment: .leading, spacing: -10) {
                            Text("\(galleryProgress.truncate(places: galleryProgress.truncatingRemainder(dividingBy: 0.1) == 0 ? 1 : 3).description)%")
                                .font(.system(size: 120))
                                .fontWeight(.heavy)
                            Text("Gallery Completion")
                                .font(.system(size: 40))
                                .fontWeight(.bold)
                        }
                    }
                    .padding(.top, 75)
                    .padding(.bottom, 75)
                    .fixedSize(horizontal: true, vertical: false)
                    .frame(maxWidth: .infinity)
                    
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 6)) {
                        ForEach(0...sortedTaskList.count - 1, id: \.self) { index in
                            TaskRectangleView(task: sortedTaskList[index], index: index)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        
        // MARK: Navigation View Settings
        .navigationTitle("Drawing Gallery")
        
    }
}

struct GalleryView_Previews: PreviewProvider {
    static var previews: some View {
        GalleryView()
            .previewInterfaceOrientation(.landscapeRight)
    }
}
