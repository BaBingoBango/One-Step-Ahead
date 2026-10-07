//
//  GeometryServices.swift
//  One Step Ahead
//

import UIKit

/// The width, in points, of the screen the app's window is on.
///
/// This replaces the deprecated `UIScreen.main`: the window scene's screen is the device screen on iPhone, and on iPadOS 27's resizable windows it reflects the window's own size.
var screenWidth: CGFloat {
    let windowScenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let windowScene = windowScenes.first(where: { $0.activationState == .foregroundActive }) ?? windowScenes.first
    return windowScene?.screen.bounds.width ?? 0
}
