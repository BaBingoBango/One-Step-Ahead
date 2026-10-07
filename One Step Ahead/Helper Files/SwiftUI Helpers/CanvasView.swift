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
struct CanvasView: UIViewRepresentable {
    
    /// The underlying UIKit view from PencilKit.
    @Binding var canvasView: PKCanvasView
    /// The function to call after every new stroke on the canvas.
    let onSaved: () -> Void
    
    /// Creates, configures, and returns the UIKit canvas view object.
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 5)
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
        Coordinator(onSaved: onSaved)
    }
    
    /// The view's mechanism for interfacing between SwiftUI and UIKit.
    final class Coordinator: NSObject, PKCanvasViewDelegate {
        /// The function to call after every new stroke on the canvas.
        let onSaved: () -> Void
        
        init(onSaved: @escaping () -> Void) {
            self.onSaved = onSaved
        }
        
        /// Calls the passed-in on-change method after every canvas update.
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            if !canvasView.drawing.bounds.isEmpty {
                onSaved()
            }
        }
    }
}
