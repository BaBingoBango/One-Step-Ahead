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
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            guard let self else { return }
            
            // Handle an authentication error
            if let error {
                print(error.localizedDescription)
                
                // Enable the Start Game button
                hasAuthenticatedWithGameCenter = true
                return
            }
            
            // If a view controller is received from GameKit, present it as long as the user hasn't blocked Game Center pop-ups
            if let viewController {
                present(viewController, animated: true)
            }
            
            // Enable the Start Game button
            hasAuthenticatedWithGameCenter = true
        }
    }
    
}

/// A SwiftUI view which attempts to authenticate the user with Game Center and may present an authentication view controller.
struct RepresentableGameCenterAuthenticationController: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> GameCenterAuthenticationController {
        GameCenterAuthenticationController()
    }
    
    func updateUIViewController(_ uiViewController: GameCenterAuthenticationController, context: Context) {}
    
}
