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
    
    /// The task list, sorted alphabetically.
    var sortedTaskList = Task.taskList.sorted(by: { $0.object < $1.object })
    
    var body: some View {
        ZStack {
            SpriteView(scene: SKScene(fileNamed: "Gallery View Graphics")!)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ScrollView {
                    HStack {
                        Text("~")
                            .font(.system(size: 120))
                            .fontWeight(.heavy)
                        
                        ProgressCircleView(progress: 0.75, color: .blue, lineWidth: 10, imageName: "photo.artframe")
                            .aspectRatio(1.0, contentMode: .fill)
                        
                        VStack(alignment: .leading, spacing: -10) {
                            Text("75%")
                                .font(.system(size: 120))
                                .fontWeight(.heavy)
                            Text("Gallery Completion")
                                .font(.system(size: 40))
                                .fontWeight(.bold)
                        }
                        
                        Text("~")
                            .font(.system(size: 120))
                            .fontWeight(.heavy)
                    }
                    .padding(.top)
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
