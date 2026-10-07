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
    
    // MARK: - View Variables
    /// The fixed height of the rectangle, if applicable.
    var fixedHeight: Int?
    /// The color of the rectangle.
    var color: Color?
    /// The opacity of the rectangle.
    var opacity: Double?
    
    // MARK: - View Body
    func body(content: Content) -> some View {
        ZStack {
            if fixedHeight == nil {
                Rectangle()
                    .foregroundStyle(color ?? .primary)
                    .opacity(opacity ?? 0.1)
                    .clipShape(.rect(cornerRadius: 15))
            } else {
                Rectangle()
                    .foregroundStyle(color ?? .primary)
                    .frame(height: CGFloat(fixedHeight!))
                    .opacity(opacity ?? 0.1)
                    .clipShape(.rect(cornerRadius: 15))
            }
            content
        }
    }
}
