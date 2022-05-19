//
//  GalleryView.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 5/19/22.
//

import SwiftUI
import SpriteKit

struct GalleryView: View {
    
    // MARK: View Variables
    /// The task list, sorted alphabetically.
    var sortedTaskList = Task.taskList.sorted(by: { $0.object < $1.object })
    
    var body: some View {
        ZStack {
            SpriteView(scene: SKScene(fileNamed: "Main Menu Graphics")!)
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
    }
}

struct GalleryView_Previews: PreviewProvider {
    static var previews: some View {
        GalleryView()
            .previewInterfaceOrientation(.landscapeRight)
    }
}

struct TaskRectangleView: View {
    
    // MARK: View Variables
    /// The task represented by this view.
    var task: Task
    /// The task list index of the task represented by this view.
    var index: Int
    /// A 3-digit string version of the task list index of the task represented by this view.
    var indexString: String {
        switch String(index).count {
        case 1:
            return "00\(index)"
        case 2:
            return "0\(index)"
        default:
            return String(index)
        }
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.black)
                .opacity(0.3)
                .cornerRadius(10)
                .frame(height: 150)
            
            Text(indexString)
                .foregroundColor(.white)
                .opacity(0.05)
                .font(.system(size: 115))
            
            VStack(spacing: 5) {
                Text(task.emoji)
                    .font(.system(size: 30))
                
                Text(task.object)
                    .font(.system(size: 25))
                    .fontWeight(.bold)
            }
        }
    }
}
