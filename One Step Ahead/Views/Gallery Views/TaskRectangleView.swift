//
//  TaskRectangleView.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 5/19/22.
//

import SwiftUI

/// A view for a task, meant for display in a list or grid as a button leading to a task detail view.
struct TaskRectangleView: View {
    
    // MARK: View Variables
    /// A wrapper for the user's task-related save data. This value is presisted inside UserDefaults.
    @AppStorage("userTaskRecords") var userTaskRecords: UserTaskRecords = UserTaskRecords()
    /// The task that should be sent to a New Game view by the Gallery View.
    @Binding var taskToPresent: Task?
    /// Whether or not a task detail view is currently being auto-dismissed.
    @Binding var isTaskDetailAutoDismissing: Bool
    /// Whether or not this view is presenting a task detail view as a modal.
    @State var isShowingTaskDetailView = false
    /// The task represented by this view.
    var task: Task
    /// The task list index of the task represented by this view.
    var index: Int
    /// A 3-digit string version of the task list index of the task represented by this view.
    var indexString: String {
        switch String(index + 1).count {
        case 1:
            return "00\(index + 1)"
        case 2:
            return "0\(index + 1)"
        default:
            return String(index + 1)
        }
    }
    
    // MARK: - View Body
    var body: some View {
        /// Whether or not the task represented by this view is unlocked.
        let isTaskUnlocked = userTaskRecords.records.keys.contains(task.object)
        
        Button(action: {
            isShowingTaskDetailView = true
        }) {
            ZStack {
                Rectangle()
                    .foregroundColor(.black)
                    .opacity(0.3)
                    .cornerRadius(10)
                    .frame(height: UIDevice.current.userInterfaceIdiom != .phone ? 150 : 75)
                
                Text(indexString)
                    .foregroundColor(.white)
                    .opacity(0.05)
                    .font(.system(size: UIDevice.current.userInterfaceIdiom != .phone ? 115 : 57.5))
                    .minimumScaleFactor(0.1)
                    .lineLimit(1)
                
                VStack(spacing: 5) {
                    Text(isTaskUnlocked ? task.emoji : "🔒")
                        .font(.system(size: UIDevice.current.userInterfaceIdiom != .phone ? 60 : 30))
                    
                    if isTaskUnlocked {
                        Text(task.object)
                            .font(.system(size: UIDevice.current.userInterfaceIdiom != .phone ? 25 : 12.5))
                            .fontWeight(.bold)
                            .minimumScaleFactor(0.1)
                            .lineLimit(1)
                            .foregroundColor(.white)
                            .padding(.horizontal, 5)
                    }
                }
            }
        }
        .dynamicTypeSize(.medium).statusBar(hidden: true)
        .disabled(!isTaskUnlocked)
        .sheet(isPresented: $isShowingTaskDetailView) {
            TaskDetailView(taskToPresent: $taskToPresent, isTaskDetailAutoDismissing: $isTaskDetailAutoDismissing, task: task, index: index)
        }
    }
}

struct TaskRectangleView_Previews: PreviewProvider {
    static var previews: some View {
        TaskRectangleView(taskToPresent: .constant(nil), isTaskDetailAutoDismissing: .constant(false), task: Task.taskList[0], index: 0)
    }
}
