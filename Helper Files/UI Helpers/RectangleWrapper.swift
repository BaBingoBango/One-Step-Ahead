//
//  RectangleWrapper.swift
//
//
//  Created by Ethan Marshall on 4/7/22.
//

import Foundation
import SwiftUI

/// A modifier which encloses a SwiftUI view in a rectangle of customizable color and height.
struct RectangleWrapper: ViewModifier {
    
    var fixedHeight: Int?
    var color: Color?
    var opacity: Double?
    
    func body(content: Content) -> some View {
        ZStack {
            if fixedHeight == nil {
                Rectangle()
                    .foregroundColor(color == nil ? .primary : color!)
                    .opacity(opacity == nil ? 0.1 : opacity!)
                    .cornerRadius(15)
            } else {
                Rectangle()
                    .foregroundColor(color == nil ? .primary : color!)
                    .frame(height: CGFloat(fixedHeight!))
                    .opacity(opacity == nil ? 0.1 : opacity!)
                    .cornerRadius(15)
            }
            content
        }
    }
}
