//
//  GameCenterAuthenticationView.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 5/21/22.
//

import SwiftUI
import UIKit
import GameKit

/// A UIKit view controller which attempts to authenticate the user with Game Center and may present an authentication view controller.
class GameCenterAuthenticationController: UIViewController {
    
    // MARK: Variables
    /// Whether or not GameKit has completed the Game Center authentication process.
    @AppStorage("hasAuthenticatedWithGameCenter") var hasAuthenticatedWithGameCenter: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authenticateUserWithGameCenter()
    }
    
    // MARK: Functions
    /// Attempts to authenticate the user with Game Center and may present an authentication view controller.
    func authenticateUserWithGameCenter() {
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            // Handle an authentication error
            guard error == nil else {
                print(error?.localizedDescription ?? "")
                
                // Enable the Start Game button
                self.hasAuthenticatedWithGameCenter = true
                
                return
            }
            
            // If a view controller is received from GameKit, present it as long as the user hasn't blocked Game Center pop-ups
            if viewController != nil {
                self.present(viewController!, animated: true, completion: nil)
            }
            
            // Enable the Game Center access point if the user is authenticated
            GKAccessPoint.shared.location = .bottomLeading
            GKAccessPoint.shared.showHighlights = true
            GKAccessPoint.shared.isActive = GKLocalPlayer.local.isAuthenticated
            
            // Enable the Start Game button
            self.hasAuthenticatedWithGameCenter = true
        }
    }
    
}

/// A SwiftUI view which attempts to authenticate the user with Game Center and may present an authentication view controller.
struct RepresentableGameCenterAuthenticationController: UIViewControllerRepresentable {
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<RepresentableGameCenterAuthenticationController>) -> GameCenterAuthenticationController {
        let viewController = GameCenterAuthenticationController()
        return viewController
        
    }
    
    func updateUIViewController(_ uiViewController: GameCenterAuthenticationController, context: UIViewControllerRepresentableContext<RepresentableGameCenterAuthenticationController>) {}
    
}
