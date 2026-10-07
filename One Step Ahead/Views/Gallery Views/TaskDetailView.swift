//
//  TaskDetailView.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 5/19/22.
//

import SwiftUI

/// A view for showing details of a task. It is presented via modal.
struct TaskDetailView: View {
    @Environment(\.screenLayout) private var layout
    
    // MARK: View Variables
    /// A wrapper for the user's task-related save data. This value is presisted inside UserDefaults.
    @AppStorage("userTaskRecords") var userTaskRecords: UserTaskRecords = UserTaskRecords()
    /// The action that dismisses this view.
    @Environment(\.dismiss) private var dismiss
    /// The task that should be sent to a New Game view by the Gallery View.
    @Binding var taskToPresent: DrawingTask?
    /// Whether or not the Practice is being presented.
    @State var isShowingPracticeView = false
    /// Whether or not the New Game view is being presented.
    @State var isShowingNewGameView = false
    /// Whether or not the Drawing Central view is being presented.
    @State var isShowingDrawingCentral = false
    /// The task represented by this view.
    var task: DrawingTask
    /// The task list index of the task represented by this view.
    var index: Int
    
    /// The arrangement of the buttons below the task's records, which stack vertically in narrow portrait windows.
    private var taskButtonsLayout: AnyLayout {
        layout.isCompact && layout.isPortrait ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout())
    }
    
    // MARK: - View Body
    var body: some View {
        NavigationStack {
            VStack {
                if layout.isRegular {
                    Spacer()
                }
                
                Text(task.emoji)
                    .font(.system(size: layout.isRegular ? 100 : 50))
                
                Text(task.object)
                    .font(layout.isRegular ? .largeTitle : .title)
                    .fontWeight(.bold)
                
                Text("No. \(index + 1)")
                    .font(layout.isRegular ? .title : .title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.gray)
                
                HStack(spacing: 0) {
                    Spacer()
                    
                    VStack {
                        Text("Times Played")
                            .font(layout.isRegular ? .title : .title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.cyan)
                        
                        Text("\(userTaskRecords.records[task.object]?["timesPlayed"] ?? 0)")
                            .font(.system(size: layout.isRegular ? 50 : 25))
                            .fontWeight(.bold)
                            .foregroundStyle(.cyan)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("High Score")
                            .font(layout.isRegular ? .title : .title2)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.gold)
                        
                        Text("\(userTaskRecords.records[task.object]?["highScore"] ?? 0)")
                            .font(.system(size: layout.isRegular ? 50 : 25))
                            .fontWeight(.bold)
                            .foregroundStyle(Color.gold)
                    }
                    
                    Spacer()
                }
                .padding(.top)
                
                Spacer()
                
                taskButtonsLayout {
                    Button(action: {
                        // Award the Enter The Dojo achievement
                        reportAchievementProgress("Enter_The_Dojo")
                        
                        // Show the practice view
                        isShowingPracticeView = true
                    }) {
                        HStack {
                            Image(systemName: "scribble.variable")
                                .foregroundStyle(.white)
                                .imageScale(.large)
                            
                            Text("Practice")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal)
                        .modifier(RectangleWrapper(fixedHeight: layout.isRegular ? 60 : 50, color: .green, opacity: 1.0))
                    }
                    .fullScreenCover(isPresented: $isShowingPracticeView) {
                        PracticeView(task: task, index: index)
                            .measuringScreenLayout()
                    }

                    Button(action: {
                        // Set the Gallery View's state variable
                        taskToPresent = task
                        
                        // Award the Interactive Exhibit achievement
                        reportAchievementProgress("Interactive_Art")
                        
                        // Dismiss this modal
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                                .foregroundStyle(.white)
                                .imageScale(.large)

                            Text("New Game")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal)
                        .modifier(RectangleWrapper(fixedHeight: layout.isRegular ? 60 : 50, color: .blue, opacity: 1.0))
                    }
                    
                    Button(action: {
                        isShowingDrawingCentral = true
                    }) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundStyle(.white)
                                .imageScale(.large)

                            Text("Drawing Central")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.1)
                        }
                        .padding(.horizontal)
                        .modifier(RectangleWrapper(fixedHeight: layout.isRegular ? 60 : 50, color: .teal, opacity: 1.0))
                    }
                    .fullScreenCover(isPresented: $isShowingDrawingCentral) {
                        DrawingCentralView(task: task)
                            .measuringScreenLayout()
                    }
                }
                .padding([.leading, .bottom, .trailing])
            }
            
            // MARK: Navigation View Settings
            .navigationBarTitleDisplayMode(.inline)
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
    }
}

#Preview(traits: .landscapeLeft) {
    TaskDetailView(taskToPresent: .constant(nil), task: DrawingTask.taskList[2], index: 2)
}
