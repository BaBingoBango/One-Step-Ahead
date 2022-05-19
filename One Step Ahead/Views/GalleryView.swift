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
    /// An array of grid items to size and position each row of the gallery grid.
    var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 6)
    
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
                    
                    LazyVGrid(columns: columns) {
                        ForEach(Task.taskList.sorted(by: { $0.object < $1.object }), id: \.object) { task in
                            TaskRectangleView(task: task)
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
    var task: Task
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.black)
                .opacity(0.3)
                .cornerRadius(10)
                .frame(height: 150)
            
            Text("00\(Task.taskList.sorted(by: { $0.object < $1.object }).firstIndex(where: { $0.object == task.object })! + 1)")
                .foregroundColor(.white)
                .opacity(0.05)
                .font(.system(size: 100))
            
            VStack(spacing: 5) {
                Text("🍎")
                    .font(.system(size: 30))
                
                Text(task.object)
                    .font(.system(size: 25))
                    .fontWeight(.bold)
            }
        }
    }
}
