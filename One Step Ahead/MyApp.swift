import SwiftUI
import GameKit

@main
struct MyApp: App {
    
    /// The system-provided ScenePhase object  used for app launching.
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // This invisible "view" authenticates the user with Game Center when the app is opened
                RepresentableGameCenterAuthenticationController()
                
                // MARK: Entry Point View
                TitleScreenView()
            }
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            // MARK: Application Life Cycle Code
            case .active:
                print("[Application Life Cycle] The app is active!")
                
            case .background:
                print("[Application Life Cycle] The app is in the background!")
                
            case .inactive:
                print("[Application Life Cycle] The app is inactive!")
            
            default:
                print("[Application Life Cycle] Unknown application life cycle value received.")
            }
        }
    }
}
