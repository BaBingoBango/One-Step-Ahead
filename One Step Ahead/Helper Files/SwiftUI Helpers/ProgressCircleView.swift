//
//  ProgressCircle.swift
//  
//
//  Created by Ethan Marshall on 5/11/22.
//

import Foundation
import SwiftUI

/// A customizable circular progress view which displays an SF symbol in the center.
public struct ProgressCircleView: View {
    
    // MARK: - View Variables
    /// The amount of the circle to fill in, expressed as a Double between (and including) zero and one.
    var progress: Double
    /// The color of the progress circle.
    var color: Color
    /// The width of the progress circle.
    var lineWidth: Double
    /// The name of the SF symbol to use in the center of the circle.
    var imageName: String
    
    // MARK: - View Body
    public var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: CGFloat(lineWidth))
                .opacity(0.3)
                .foregroundColor(color)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: CGFloat(lineWidth), lineCap: .round, lineJoin: .round))
                .foregroundColor(color)
                .rotationEffect(Angle(degrees: 270.0))
            
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
                .padding()
        }
        .padding(.horizontal)
    }
}
