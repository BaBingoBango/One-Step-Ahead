import SwiftUI
import UIKit
import GameKit

@main
struct MyApp: App {
    
    /// The system-provided `ScenePhase` object  used for app launching.
    @Environment(\.scenePhase) var scenePhase
    /// A custom app delegate which installs the scene delegate.
    @UIApplicationDelegateAdaptor(MyAppDelegate.self) var appDelegate
    /// Whether or not GameKit has completed the Game Center authentication process.
    @AppStorage("hasAuthenticatedWithGameCenter") var hasAuthenticatedWithGameCenter: Bool = false
    /// Whether or not GameKit has started the Game Center authentication process for this run of the app.
    @State var hasStartedAuthenticatingWithGameCenter: Bool = false
    /// The names of the keys from UserDefaults that will sync across the user's devices via iCloud.
    var userDefaultsKeysToSync = ["hasFinishedTutorial", "userTaskRecords", "gamesWon", "isUnlockAssistOn", "practiceDrawingsMade"]
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // This invisible "view" authenticates the user with Game Center when the app is opened
                RepresentableGameCenterAuthenticationController()
                    .frame(width: 0, height: 0)
                    .onAppear {
                        // Set the flag so authentication is not attempted multiple times
                        hasStartedAuthenticatingWithGameCenter = true
                    }
                
                // MARK: Entry Point View
                TitleScreenView()
            }
            // Ask the system to require a second swipe before the Home indicator leaves the game
            .measuringScreenLayout()
            .defersSystemGestures(on: .bottom)
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            // MARK: Application Life Cycle Code
            case .active:
                print("[Application Life Cycle] The app is active!")
    
                if !hasStartedAuthenticatingWithGameCenter {
                    // Reset the Game Center authentication status if authentication has not yet happened
                    hasAuthenticatedWithGameCenter = false
                }
                
                // Use Zephyr to sync data across the user's devices with iCloud
                Zephyr.sync(keys: userDefaultsKeysToSync)
                
            case .background:
                print("[Application Life Cycle] The app is in the background!")
                
            case .inactive:
                print("[Application Life Cycle] The app is inactive!")
                
                // Use Zephyr to sync data across the user's devices with iCloud
                Zephyr.sync(keys: userDefaultsKeysToSync)
            
            default:
                print("[Application Life Cycle] Unknown application life cycle value received.")
            }
        }
    }
}

/// A custom app delegate class which installs the scene delegate below.
class MyAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: "My Scene Delegate", sessionRole: connectingSceneSession.role)
        config.delegateClass = MySceneDelegate.self
        return config
    }
}

/// A custom scene delegate class which sets the minimum window size for macOS and resizable iPad windows.
class MySceneDelegate: UIResponder, UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        // Keep the game's windows from getting too small on the Mac; on iPad the system's own minimum applies, and every screen adapts down to it
        if ProcessInfo.processInfo.isiOSAppOnMac || UIDevice.current.userInterfaceIdiom == .mac {
            windowScene.sizeRestrictions?.minimumSize = CGSize(width: 1200, height: 800)
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            // Anything smaller cannot fit the game's screens, even with their phone-sized layouts
            windowScene.sizeRestrictions?.minimumSize = CGSize(width: 560, height: 440)
        }
    }
}
