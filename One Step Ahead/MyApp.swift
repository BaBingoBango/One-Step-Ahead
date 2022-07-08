import SwiftUI
import UIKit
import GameKit

@main
struct MyApp: App {
    
    /// The system-provided ScenePhase object  used for app launching.
    @Environment(\.scenePhase) var scenePhase
    /// A custom app delegate which launches the root view.
    @UIApplicationDelegateAdaptor(MyAppDelegate.self) var appDelegate
    /// Whether or not GameKit has started the Game Center authentication process for this run of the app.
    @State var hasStartedAuthenticatingWithGameCenter: Bool = false
    /// Whether or not GameKit has completed the Game Center authentication process.
    @AppStorage("hasAuthenticatedWithGameCenter") var hasAuthenticatedWithGameCenter: Bool = false
    
    /// The names of the keys from UserDefaults that will sync across the user's devices via iCloud.
    var userDefaultsKeysToSync = ["hasFinishedTutorial", "userTaskRecords", "gamesWon", "isUnlockAssistOn", "practiceDrawingsMade"]
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // This invisible "view" authenticates the user with Game Center when the app is opened
                RepresentableGameCenterAuthenticationController()
                    .onAppear {
                        // Set the flag so authentication is not attempted multiple times
                        hasStartedAuthenticatingWithGameCenter = true
                    }
                
                // MARK: Entry Point View
                // The entry point view is actually provided below in the MyAppDelegate class.
                // TitleScreenView()
            }
        }
        .onChange(of: scenePhase) { phase in
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

/// A custom app delegate class which helps dim the home indicator.
///
/// This class was downloaded from https://stackoverflow.com/questions/57260051/iphone-x-home-indicator-dimming-undimming
class MyAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: "My Scene Delegate", sessionRole: connectingSceneSession.role)
        config.delegateClass = MySceneDelegate.self
        return config
    }
}

/// A custom scene delegate class which helps dim the home indicator.
///
/// This class was downloaded from https://stackoverflow.com/questions/57260051/iphone-x-home-indicator-dimming-undimming
class MySceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let rootView = TitleScreenView()
            let hostingController = HostingController(rootView: rootView)
            window.rootViewController = hostingController
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}

/// A custom hosting controller class which helps dim the home indicator.
///
/// This class was downloaded from https://stackoverflow.com/questions/57260051/iphone-x-home-indicator-dimming-undimming
class HostingController: UIHostingController<TitleScreenView> {
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return [.bottom]
     }
}
