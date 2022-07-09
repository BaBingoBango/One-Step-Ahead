//
//  RoundedCornerServices.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 7/9/22.
//

import Foundation
import SwiftUI

/// A rounded corners view used in the custom `cornerRadius` modifier.
struct RoundedCorners: View {
    
    // MARK: View Variables
    var color: Color = .blue
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0

    // MARK: View Body
    public var body: some View {
        GeometryReader { geometry in
            Path { path in

                let w = geometry.size.width
                let h = geometry.size.height

                // Make sure we do not exceed the size of the rectangle
                let tr = min(min(self.tr, h/2), w/2)
                let tl = min(min(self.tl, h/2), w/2)
                let bl = min(min(self.bl, h/2), w/2)
                let br = min(min(self.br, h/2), w/2)

                path.move(to: CGPoint(x: w / 2.0, y: 0))
                path.addLine(to: CGPoint(x: w - tr, y: 0))
                path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
                path.addLine(to: CGPoint(x: w, y: h - br))
                path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
                path.addLine(to: CGPoint(x: bl, y: h))
                path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
                path.addLine(to: CGPoint(x: 0, y: tl))
                path.addArc(center: CGPoint(x: tl, y: tl), radius: tl, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
            }
            .fill(self.color)
        }
    }
}

/// A rounded corner shape used in the custom `cornerRadius` modifier.
///
/// > Important: This structure relies on UIKit, meaning it cannot be built for a native macOS app. However, it will still work for Mac Catalyst apps or iPad apps run on Apple silicon Macs.
public struct RoundedCorner: Shape {

    // MARK: Variables
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    // MARK: Functions
    public func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
    
}

public extension View {
    /// Clips this view to its bounding frame on the specified corners with the specified corner radius.
    ///
    /// This modifier is a custom version of the built-in `cornerRadius` modifier which allows the selection of individual corners to round.
    /// > Important: This view relies on UIKit, meaning it cannot be built for a native macOS app. However, it will still work for Mac Catalyst apps or iPad apps run on Apple silicon Macs.
    /// - Parameters:
    ///   - radius: The radius of the corners to round.
    ///   - corners: An array of corners (`UIRectCorner`) to round, e.g. `[.topRight, .bottomRight]`.
    /// - Returns: The modified view, although it should be noted that this function is used as a SwiftUI modifier rather than as a normal function.
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}
