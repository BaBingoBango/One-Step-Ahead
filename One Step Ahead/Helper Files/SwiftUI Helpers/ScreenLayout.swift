//
//  ScreenLayout.swift
//  One Step Ahead
//

import SpriteKit
import SwiftUI

/// The shape of the window or sheet a screen is laid out in.
///
/// The game was designed for landscape phones and iPads, with a larger set of controls for the iPad. Since iPadOS 26, the app's windows can be any size and orientation, so screens read this value to pick which set of controls to use and whether to stack their panels vertically instead of side by side.
nonisolated struct ScreenLayout: Equatable, Sendable {
    /// The size of the container the screen is laid out in, including any safe areas.
    var size: CGSize
    /// Whether the app is running on an iPhone, which always uses the phone-sized controls.
    var isPhone: Bool
    /// Whether the screen uses the phone-sized controls rather than the larger ones designed for iPad.
    var isCompact: Bool
    /// Whether the container is a window that fills the whole screen, as opposed to a smaller window or a sheet.
    var isFullScreenWindow: Bool

    /// Whether the screen uses the larger controls designed for iPad.
    var isRegular: Bool { !isCompact }
    /// Whether the container is taller than it is wide, in which case screens stack their panels vertically.
    var isPortrait: Bool { size.height > size.width }
    /// The width of the container.
    var width: CGFloat { size.width }
    /// The height of the container.
    var height: CGFloat { size.height }

    /// The smallest window that still uses the iPad-sized controls; smaller windows use the phone-sized layouts, which were designed for small screens.
    static let regularMinimumWindowSize = CGSize(width: 700, height: 560)
    /// The smallest sheet that still uses the iPad-sized controls. Sheets are compact by nature, so they keep the iPad styling down to a smaller size than windows do.
    static let regularMinimumSheetSize = CGSize(width: 500, height: 400)
    /// The narrowest container that keeps a six-column grid; narrower ones use three columns.
    static let regularMinimumWidth: CGFloat = 500
    
    /// The layout for a container of the given size on the current device.
    /// - Parameters:
    ///   - containerSize: The size of the window or sheet.
    ///   - isSheet: Whether the container is a sheet rather than a window.
    @MainActor static func measured(containerSize: CGSize, isSheet: Bool = false) -> ScreenLayout {
        let isPhone = UIDevice.current.userInterfaceIdiom == .phone
        let minimum = isSheet ? regularMinimumSheetSize : regularMinimumWindowSize
        let isCompact = isPhone || containerSize.width < minimum.width || containerSize.height < minimum.height
        let screen = screenSize
        let matchesScreen = abs(containerSize.width - screen.width) < 1 && abs(containerSize.height - screen.height) < 1
        let matchesRotatedScreen = abs(containerSize.width - screen.height) < 1 && abs(containerSize.height - screen.width) < 1
        return ScreenLayout(size: containerSize, isPhone: isPhone, isCompact: isCompact, isFullScreenWindow: !isSheet && (matchesScreen || matchesRotatedScreen))
    }
    
    /// The size of the device's screen.
    @MainActor private static var screenSize: CGSize {
        UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first?.screen.bounds.size ?? CGSize(width: 1024, height: 768)
    }
    
    /// The layout to assume before a screen has measured its container: the full screen of the current device.
    @MainActor static var fallback: ScreenLayout {
        measured(containerSize: screenSize)
    }
}

nonisolated private struct ScreenLayoutKey: EnvironmentKey {
    static var defaultValue: ScreenLayout {
        // SwiftUI reads environment defaults on the main thread, where the device can be asked about its screen
        if Thread.isMainThread {
            return MainActor.assumeIsolated { ScreenLayout.fallback }
        }
        return ScreenLayout(size: CGSize(width: 1024, height: 768), isPhone: false, isCompact: false, isFullScreenWindow: true)
    }
}

extension EnvironmentValues {
    /// The shape of the window or sheet the view is laid out in.
    nonisolated var screenLayout: ScreenLayout {
        get { self[ScreenLayoutKey.self] }
        set { self[ScreenLayoutKey.self] = newValue }
    }
}

/// Measures a screen's container and publishes the result as the `screenLayout` environment value for everything inside it.
private struct ScreenLayoutReader: ViewModifier {
    /// Whether the container being measured is a sheet rather than a window.
    var isSheet: Bool
    @State private var layout = ScreenLayout.fallback

    func body(content: Content) -> some View {
        content
            .environment(\.screenLayout, layout)
            .background {
                // The measuring view extends into the safe area so the layout describes the whole window or sheet; the geometry is read inside that extension
                Color.clear
                    .onGeometryChange(for: CGSize.self) { proxy in
                        proxy.size
                    } action: { size in
                        layout = ScreenLayout.measured(containerSize: size, isSheet: isSheet)
                    }
                    .ignoresSafeArea()
            }
    }
}

extension View {
    /// Measures this view's container and makes its shape available to the views inside it through the `screenLayout` environment value.
    ///
    /// Apply it where each screen is presented: on the window's root view, and on the content of each full-screen cover or sheet.
    /// - Parameter asSheet: Whether the view is presented as a sheet, which keeps the iPad styling down to a smaller size than a window would.
    func measuringScreenLayout(asSheet: Bool = false) -> some View {
        modifier(ScreenLayoutReader(isSheet: asSheet))
    }
}

extension SKScene {
    /// Zooms the scene out when its container is narrower than the width its artwork was designed for, so nothing is cut off at the sides.
    ///
    /// The game's scenes resize with their view and keep their artwork anchored to the center, which suits any window that is at least as wide as the artwork. Narrower windows show the artwork a little smaller instead of cropping it.
    /// - Parameters:
    ///   - width: The width of the scene's container.
    ///   - designedWidth: The width the scene's artwork needs to be fully visible.
    func fitArtwork(toWidth width: CGFloat, designedWidth: CGFloat) {
        let camera = self.camera ?? {
            let camera = SKCameraNode()
            addChild(camera)
            self.camera = camera
            return camera
        }()
        camera.setScale(max(1, designedWidth / max(width, 1)))
    }
}

extension SKScene {
    /// Keeps the scene's background sprites covering a container of the given size.
    ///
    /// The backgrounds were sized for landscape screens, so in a taller window the scene's backdrop would show below them. This scales each background up just enough to reach the container's edges, leaving it untouched in windows it already covers. Backgrounds that drift with an animation get extra room so they keep covering as they move, and the backdrop takes on the artwork's own tone so any sliver that still shows blends in.
    /// - Parameter size: The size of the scene's container.
    func coverContainer(size: CGSize) {
        for case let sprite as SKSpriteNode in children where sprite.name?.localizedCaseInsensitiveContains("background") == true {
            // Start from the scale the artwork was designed with, so a window that grows and shrinks again settles back to the original look
            let designedScaleKey = "designedScale"
            let designedScale: CGPoint
            if let stored = sprite.userData?[designedScaleKey] as? NSValue {
                designedScale = stored.cgPointValue
            } else {
                designedScale = CGPoint(x: sprite.xScale, y: sprite.yScale)
                sprite.userData = sprite.userData ?? NSMutableDictionary()
                sprite.userData?[designedScaleKey] = NSValue(cgPoint: designedScale)
            }
            sprite.xScale = designedScale.x
            sprite.yScale = designedScale.y
            
            // How far the sprite reaches from its position on each side, against how far it needs to reach
            let frame = sprite.frame
            let center = sprite.position
            let drifts = sprite.hasActions()
            let reach = [center.x - frame.minX, frame.maxX - center.x, center.y - frame.minY, frame.maxY - center.y]
            let needed = drifts
                ? [size.width * 1.2, size.width * 1.2, size.height * 1.2, size.height * 1.2]
                : [center.x + size.width / 2, size.width / 2 - center.x, center.y + size.height / 2, size.height / 2 - center.y]
            let factor = zip(needed, reach).map { $0 / max($1, 1) }.max() ?? 1
            if factor > 1 {
                sprite.xScale = designedScale.x * factor
                sprite.yScale = designedScale.y * factor
            }
            
            backgroundColor = drifts ? UIColor(red: 8 / 255, green: 10 / 255, blue: 24 / 255, alpha: 1) : UIColor(red: 21 / 255, green: 55 / 255, blue: 89 / 255, alpha: 1)
        }
    }
}

/// The SpriteKit scene behind a screen, kept covering the whole window as the window changes size.
struct GameBackground: View {
    /// The scene to show.
    let scene: SKScene
    
    var body: some View {
        SpriteView(scene: scene)
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { size in
                scene.coverContainer(size: size)
            }
            .ignoresSafeArea()
    }
}
