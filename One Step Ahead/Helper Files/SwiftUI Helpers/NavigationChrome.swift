//
//  NavigationChrome.swift
//  One Step Ahead
//

import SwiftUI

/// Measurements of the system navigation bar in landscape on iOS 26, so custom chrome lines up with it exactly.
///
/// The game's immersive screens draw their content right up to the top edge. Since iOS 26, the (transparent) system navigation bar claims every touch in its area, which left the top row of menu squares and the in-game Undo button unreachable. Those screens hide the system bar and draw the few controls they need with these helpers instead.
///
/// The values were measured from the system bar's view hierarchy on the iPhone 17e and the iPad Pro 11-inch running iOS 27. The bar's controls are 44 points tall and the bar ends 10 points below them on both devices. Measured from the window's top-leading corner, the controls sit 24 points down and 38 points in on iPhone, and 10 points down and 10 points in on iPad.
enum NavigationChrome {
    /// Whether the app is running on an iPhone, where the bar sits lower and further from the leading edge than on iPad.
    private static var isPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }
    /// The distance from the top of the window to the top of the bar's controls.
    static var topInset: CGFloat { isPhone ? 24 : 10 }
    /// The distance from the leading edge of the window to the bar's leading control.
    static var leadingInset: CGFloat { isPhone ? 38 : 10 }
    /// The distance from the leading edge of an iPad window that does not fill the screen to the bar's leading control, which leaves room for the system's window controls in the corner.
    static let windowedLeadingInset: CGFloat = 77
    /// The height of the bar's controls.
    static let controlSize: CGFloat = 44
    /// The space between the bottom of the bar's controls and the content below the bar.
    static let bottomInset: CGFloat = 10
}

/// A row of controls that stands in for the navigation bar on screens that hide it.
///
/// Attach it with `safeAreaInset(edge: .top, spacing: 0)` so it occupies exactly the space the system bar did, which keeps the screen's layout unchanged. The bar anchors itself to the window's edges rather than the safe area, because the system bar keeps its position even when the top safe area changes.
struct NavigationChromeBar<Leading: View>: View {
    @Environment(\.screenLayout) private var layout
    /// The title shown in the center of the bar, if any.
    var title: String? = nil
    /// The control shown at the leading edge of the bar.
    @ViewBuilder var leading: () -> Leading
    
    /// Where the leading control sits: where the system bar would put it, or further in when the system's window controls occupy that corner.
    private var leadingInset: CGFloat {
        layout.isPhone || layout.isFullScreenWindow ? NavigationChrome.leadingInset : NavigationChrome.windowedLeadingInset
    }
    
    var body: some View {
        ZStack {
            if let title {
                Text(title)
                    .font(.headline)
            }
            
            HStack {
                leading()
                Spacer()
            }
            .padding(.leading, leadingInset)
        }
        .frame(maxWidth: .infinity)
        .frame(height: NavigationChrome.controlSize)
        .padding(.top, NavigationChrome.topInset)
        .padding(.bottom, NavigationChrome.bottomInset)
        .ignoresSafeArea(edges: [.horizontal, .top])
    }
}

/// A circular Liquid Glass button that matches the system navigation bar's buttons.
struct GlassCircleButton: View {
    /// The name of the SF Symbol shown in the button.
    let systemImage: String
    /// The accessibility label for the button.
    let accessibilityLabel: String
    /// The point size of the symbol.
    var symbolSize: CGFloat = 17
    /// The color of the symbol.
    var tint: Color = .primary
    /// The action to perform when the button is tapped.
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: symbolSize, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: NavigationChrome.controlSize, height: NavigationChrome.controlSize)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .circle)
        .accessibilityLabel(accessibilityLabel)
    }
}

/// A capsule Liquid Glass button with a text label that matches the system navigation bar's text buttons.
struct GlassCapsuleButton: View {
    /// The text shown in the button.
    let title: String
    /// The color of the text.
    var tint: Color = .primary
    /// The action to perform when the button is tapped.
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.bold)
                .foregroundStyle(tint)
                .padding(.horizontal, 16)
                .frame(height: NavigationChrome.controlSize)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .capsule)
    }
}

#Preview(traits: .landscapeLeft) {
    Color.black
        .ignoresSafeArea()
        .safeAreaInset(edge: .top, spacing: 0) {
            NavigationChromeBar(title: "Main Menu") {
                GlassCircleButton(systemImage: "chevron.backward", accessibilityLabel: "Back") {}
            }
        }
}
