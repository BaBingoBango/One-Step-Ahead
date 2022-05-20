//
//  TaskDetailView.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 5/19/22.
//

import SwiftUI

/// A view for showing details of a task. It is presented via modal.
struct TaskDetailView: View {
    
    // MARK: View Variables
    /// A wrapper for the user's task-related save data. This value is presisted inside UserDefaults.
    @AppStorage("userTaskRecords") var userTaskRecords: UserTaskRecords = UserTaskRecords()
    /// The presentation status variable for this view's modal presentation.
    @Environment(\.presentationMode) private var presentationMode
    /// The task represented by this view.
    var task: Task
    /// The task list index of the task represented by this view.
    var index: Int
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                Text(task.emoji)
                    .font(.system(size: 100))
                
                Text(task.object)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("No. \(index + 1)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                
                HStack(spacing: 0) {
                    Spacer()
                    
                    VStack {
                        Text("Times Played")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.cyan)
                        
                        Text("\(userTaskRecords.records[task.object]?["timesPlayed"] ?? 0)")
                            .font(.system(size: 50))
                            .fontWeight(.bold)
                            .foregroundColor(.cyan)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("High Score")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.gold)
                        
                        Text("\(userTaskRecords.records[task.object]?["highScore"] ?? 0)")
                            .font(.system(size: 50))
                            .fontWeight(.bold)
                            .foregroundColor(.gold)
                    }
                    
                    Spacer()
                }
                .padding(.top)
                
                Spacer()
                
                HStack {
                    Button(action: {
                        
                    }) {
                        HStack {
                            Image(systemName: "scribble.variable")
                                .foregroundColor(.white)
                                .imageScale(.large)
                            
                            Text("Practice")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .modifier(RectangleWrapper(fixedHeight: 60, color: .green, opacity: 1.0))
                    }
                    

                    NavigationLink(destination: NewGameMenuView()) {
                        HStack {
                            Image(systemName: "play.fill")
                                .foregroundColor(.white)
                                .imageScale(.large)
                            
                            Text("New Game")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .modifier(RectangleWrapper(fixedHeight: 60, color: .blue, opacity: 1.0))
                    }
                }
                .padding([.leading, .bottom, .trailing])
            }
            
            // MARK: Navigation View Settings
            .navigationViewStyle(.stack)
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
    }
}

struct TaskDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TaskDetailView(task: Task.taskList[2], index: 2)
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
