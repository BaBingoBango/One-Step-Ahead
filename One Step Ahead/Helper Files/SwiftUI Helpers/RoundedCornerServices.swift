//
//  RoundedCornerServices.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 7/9/22.
//

import Foundation
import SwiftUI

/// A rounded corner shape used in the custom `cornerRadius` modifier.
///
/// > Important: This structure relies on UIKit, meaning it cannot be built for a native macOS app. However, it will still work for Mac Catalyst apps or iPad apps run on Apple silicon Macs.
nonisolated public struct RoundedCorner: Shape {

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
    /// This modifier is a custom version of the built-in corner radius clipping which allows the selection of individual corners to round.
    /// > Important: This view relies on UIKit, meaning it cannot be built for a native macOS app. However, it will still work for Mac Catalyst apps or iPad apps run on Apple silicon Macs.
    /// - Parameters:
    ///   - radius: The radius of the corners to round.
    ///   - corners: An array of corners (`UIRectCorner`) to round, e.g. `[.topRight, .bottomRight]`.
    /// - Returns: The modified view, although it should be noted that this function is used as a SwiftUI modifier rather than as a normal function.
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}
