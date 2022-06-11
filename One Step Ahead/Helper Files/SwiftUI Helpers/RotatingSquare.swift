//
//  RotatingSquare.swift
//  
//
//  Created by Ethan Marshall on 4/17/22.
//

import SwiftUI

/// A rotating rectangle with a gradient color fill and text.
struct RotatingSquare: View {
    
    // Pass-In Variables
    /// The direction the square is rotating.
    var direction: RotationDirection
    /// The bottom color of the square's color gradient.
    var firstColor: Color
    /// The top color of the square's color gradient.
    var secondColor: Color
    /// The text written in the square.
    var text: String
    /// The name of the optional SF Symbol above the text in the square.
    var iconName: String?
    /// The Asset Catalog name of the optional image to include instead of text.
    var imageAssetName: String?
    /// The current amount of degrees that each square button is rotated.
    @Binding var rotationDegrees: Double
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                    gradient: .init(colors: [firstColor, secondColor]),
                    startPoint: .init(x: 0.5, y: 0),
                    endPoint: .init(x: 0.5, y: 0.6)
                    
                ))
                .aspectRatio(1.0, contentMode: .fit)
                .rotationEffect(.degrees(rotationDegrees))
                .overlay(
                    VStack(spacing: 0) {
                        if iconName != nil {
                            Image(systemName: iconName!)
                                .foregroundColor(.white)
                                .font(.largeTitle)
                                .offset(y: -10)
                        }
                        
                        if imageAssetName == nil {
                            Text(text)
                                .foregroundColor(.white)
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .multilineTextAlignment(.center)
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)
                                .padding(5)
                        }
                    }
                )
            
            if imageAssetName == nil {
//                if iconName != nil {
//                    Image(systemName: iconName!)
//                        .foregroundColor(.white)
//                        .font(.largeTitle)
//                        .offset(y: -10)
//                }
            } else {
                Image(imageAssetName!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .padding()
            }
        }
    }
    
    // Enumeration
    /// The two ways in which a rotating square can turn.
    enum RotationDirection {
        case clockwise
        case counterclockwise
    }
    
}

struct RotatingRectangle_Previews: PreviewProvider {
    static var previews: some View {
        RotatingSquare(direction: .clockwise, firstColor: .blue, secondColor: .cyan, text: "NEW GAME", rotationDegrees: .constant(0))
    }
}
