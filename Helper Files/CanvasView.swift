//
//  CanvasView.swift
//  
//
//  Created by Ethan Marshall on 4/8/22.
//

import Foundation
import SwiftUI
import PencilKit

/// A SwiftUI view for a PencilKit canvas.
struct CanvasView {
    
    /// The underlying UIKit view from PencilKit.
    @Binding var canvasView: PKCanvasView
    /// The function to call after every new stroke on the canvas.
    let onSaved: () -> Void
    /// The PencilKit tool picker that can be displayed on the canvas.
    @State var toolPicker = PKToolPicker()
    
}

private extension CanvasView {
    /// Shows the canvas's tool picker on the user's screen.
    func showToolPicker() {
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        toolPicker.showsDrawingPolicyControls = false
        canvasView.becomeFirstResponder()
    }
}

extension CanvasView: UIViewRepresentable {
    /// Creates, configures, and returns the UIKit canvas view object.
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 10)
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        
        canvasView.delegate = context.coordinator
        return canvasView
    }
    
    /// Updates the view from a passed-in Context.
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
    
    /// Returns a Coordinator for use in the view.
    func makeCoordinator() -> Coordinator {
        Coordinator(canvasView: $canvasView, onSaved: onSaved)
    }
}

/// The view's  mechanism for interfacing between SwiftUI and UIKit.
class Coordinator: NSObject {
    var canvasView: Binding<PKCanvasView>
    let onSaved: () -> Void

    init(canvasView: Binding<PKCanvasView>, onSaved: @escaping () -> Void) {
        self.canvasView = canvasView
        self.onSaved = onSaved
    }
}

extension Coordinator: PKCanvasViewDelegate {
    /// Calls the passed-in on-change method after every canvas update.
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        if !canvasView.drawing.bounds.isEmpty {
            onSaved()
        }
    }
}
