import SwiftUI
import GameKit

@main
struct MyApp: App {
    
    /// The system-provided ScenePhase object  used for app launching.
    @Environment(\.scenePhase) var scenePhase
    /// Whether or not GameKit has started the Game Center authentication process for this run of the app.
    @State var hasStartedAuthenticatingWithGameCenter: Bool = false
    /// Whether or not GameKit has completed the Game Center authentication process.
    @AppStorage("hasAuthenticatedWithGameCenter") var hasAuthenticatedWithGameCenter: Bool = false
    
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
                TitleScreenView()
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
