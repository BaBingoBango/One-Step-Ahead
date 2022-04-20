//
//  GameEndView.swift
//  
//
//  Created by Ethan Marshall on 4/19/22.
//

import SwiftUI
import SpriteKit

/// The screen displayed when a game finishes.
struct GameEndView: View {
    var body: some View {
        ZStack {
            SpriteView(scene: SKScene(fileNamed: "Game End View Graphics")!)
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                Text("You win!")
                    .foregroundColor(.gold)
                    .font(.system(size: 70))
                    .fontWeight(.black)
                    .padding(.top)
                
                HStack(alignment: .center) {
                    Spacer()
                    
                    VStack {
                        HStack(alignment: .center) {
                            VStack {
                                Rectangle()
                                    .aspectRatio(1.0, contentMode: .fit)
                                    .frame(width: 175)
                                    .padding(.trailing)
                                Text("\"Door\"")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .padding(.top)
                                    .padding(.trailing)
                            }
                            
                            VStack {
                                PercentCircle(percent: 30.5)
                                    .padding(.leading)
                                
                                Text("\"Door\"")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .padding(.top)
                                    .hidden()
                            }
                        }
                        .frame(height: 350)
                        
                        Text("View Previous Scores")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .modifier(RectangleWrapper(fixedHeight: 60, color: .blue, opacity: 1.0))
                            .frame(width: 425)
                    }
                    
                    Spacer()
                    
                    Rectangle()
                        .foregroundColor(.white)
                        .frame(width: 7)
                        .cornerRadius(10)
                        .padding(.vertical, 70)
                    
                    Spacer()
                    
                    VStack {
                        HStack(alignment: .center) {
                            VStack {
                                ZStack {
                                    Rectangle()
                                        .fill(
                                            LinearGradient(
                                                gradient: .init(colors: [.gray.opacity(0.6), .gray]),
                                                startPoint: .init(x: 0.25, y: 0.25),
                                            endPoint: .init(x: 0.5, y: 1)
                                            
                                        ))
                                        .aspectRatio(1.0, contentMode: .fit)
                                        .frame(width: 175)
                                    
                                    Image("robot")
                                        .scaleEffect(0.8)
                                }
                                .padding(.trailing)
                                
                                Text("\"You got me!\"")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .padding(.top)
                                    .padding(.trailing)
                            }
                            
                            VStack {
                                PercentCircle(percent: 30.5)
                                    .padding(.leading)
                                
                                Text("\"Door\"")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .padding(.top)
                                    .hidden()
                            }
                        }
                        .frame(height: 350)
                        
                        Text("View AI Training Drawings")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .modifier(RectangleWrapper(fixedHeight: 60, color: .blue, opacity: 1.0))
                            .frame(width: 425)
                    }
                    
                    Spacer()
                }
            }
            .padding(.top)
        }
    }
}

struct GameEndView_Previews: PreviewProvider {
    static var previews: some View {
        GameEndView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}

struct PercentCircle: View {
    
    // Variables
    var percent: Double
    
    var body: some View {
        HStack(spacing: 50) {
            ZStack {
                Circle()
                    .foregroundColor(.green)
                    .frame(width: 150)
                
                Text("\(percent.description)%")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
            }
        }
    }
}
