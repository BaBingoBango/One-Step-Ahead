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
        }
        .onReceive(timer) { input in
            rotationDegrees += 0.1
        }
    }
}

struct RotatingRectangle_Previews: PreviewProvider {
    static var previews: some View {
        RotatingSquare(firstColor: .blue, secondColor: .cyan, text: "NEW\nGAME")
    }
}
