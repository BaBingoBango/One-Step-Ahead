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
    var direction: RotationDirection
    var firstColor: Color
    var secondColor: Color
    var text: String
    
    // Timer Variables
    @State var rotationDegrees = 0.0
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
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
            Text(text)
                .foregroundColor(.white)
                .font(.largeTitle)
                .fontWeight(.heavy)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.1)
                .lineLimit(1)
        }
        .onReceive(timer) { input in
            if direction == .clockwise {
                rotationDegrees += 0.1
            } else {
                rotationDegrees -= 0.1
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
        RotatingSquare(direction: .clockwise, firstColor: .blue, secondColor: .cyan, text: "NEW\nGAME")
    }
}
