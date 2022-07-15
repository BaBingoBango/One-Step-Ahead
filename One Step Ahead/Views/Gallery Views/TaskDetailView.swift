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
    /// The task that should be sent to a New Game view by the Gallery View.
    @Binding var taskToPresent: Task?
    /// Whether or not a task detail view is currently being auto-dismissed.
    @Binding var isTaskDetailAutoDismissing: Bool
    /// Whether or not the Practice is being presented.
    @State var isShowingPracticeView = false
    /// Whether or not the New Game view is being presented.
    @State var isShowingNewGameView = false
    /// Whether or not the Drawing Central view is being presented.
    @State var isShowingDrawingCentral = false
    /// The task represented by this view.
    var task: Task
    /// The task list index of the task represented by this view.
    var index: Int
    
    // MARK: - View Body
    var body: some View {
        NavigationView {
            VStack {
                if UIDevice.current.userInterfaceIdiom != .phone {
                    Spacer()
                }
                
                Text(task.emoji)
                    .font(.system(size: UIDevice.current.userInterfaceIdiom != .phone ? 100 : 50))
                
                Text(task.object)
                    .font(UIDevice.current.userInterfaceIdiom != .phone ? .largeTitle : .title)
                    .fontWeight(.bold)
                
                Text("No. \(index + 1)")
                    .font(UIDevice.current.userInterfaceIdiom != .phone ? .title : .title2)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                
                HStack(spacing: 0) {
                    Spacer()
                    
                    VStack {
                        Text("Times Played")
                            .font(UIDevice.current.userInterfaceIdiom != .phone ? .title : .title2)
                            .fontWeight(.bold)
                            .foregroundColor(.cyan)
                        
                        Text("\(userTaskRecords.records[task.object]?["timesPlayed"] ?? 0)")
                            .font(.system(size: UIDevice.current.userInterfaceIdiom != .phone ? 50 : 25))
                            .fontWeight(.bold)
                            .foregroundColor(.cyan)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("High Score")
                            .font(UIDevice.current.userInterfaceIdiom != .phone ? .title : .title2)
                            .fontWeight(.bold)
                            .foregroundColor(.gold)
                        
                        Text("\(userTaskRecords.records[task.object]?["highScore"] ?? 0)")
                            .font(.system(size: UIDevice.current.userInterfaceIdiom != .phone ? 50 : 25))
                            .fontWeight(.bold)
                            .foregroundColor(.gold)
                    }
                    
                    Spacer()
                }
                .padding(.top)
                
                Spacer()
                
                HStack {
                    Button(action: {
                        // Award the Enter The Dojo achievement
                        reportAchievementProgress("Enter_The_Dojo")
                        
                        // Show the practice view
                        isShowingPracticeView = true
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
                        .padding(.horizontal)
                        .modifier(RectangleWrapper(fixedHeight: UIDevice.current.userInterfaceIdiom != .phone ? 60 : 50, color: .green, opacity: 1.0))
                    }
                    .fullScreenCover(isPresented: $isShowingPracticeView) {
                        PracticeView(task: task, index: index)
                    }

                    Button(action: {
                        // Set the Gallery View's state variable
                        taskToPresent = task
                        
                        // Award the Interactive Exhibit achievement
                        reportAchievementProgress("Interactive_Art")
                        
                        // Dismiss this modal
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                                .foregroundColor(.white)
                                .imageScale(.large)

                            Text("New Game")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                        .modifier(RectangleWrapper(fixedHeight: UIDevice.current.userInterfaceIdiom != .phone ? 60 : 50, color: .blue, opacity: 1.0))
                    }
                    
                    Button(action: {
                        isShowingDrawingCentral = true
                    }) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.white)
                                .imageScale(.large)

                            Text("Drawing Central")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.1)
                        }
                        .padding(.horizontal)
                        .modifier(RectangleWrapper(fixedHeight: UIDevice.current.userInterfaceIdiom != .phone ? 60 : 50, color: .teal, opacity: 1.0))
                    }
                    .fullScreenCover(isPresented: $isShowingDrawingCentral) {
                        DrawingCentralView(task: task)
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
        .dynamicTypeSize(.medium).statusBar(hidden: true)
    }
}

struct TaskDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TaskDetailView(taskToPresent: .constant(nil), isTaskDetailAutoDismissing: .constant(false), task: Task.taskList[2], index: 2)
            .previewInterfaceOrientation(.landscapeLeft)
            .navigationViewStyle(StackNavigationViewStyle())
    }
}
