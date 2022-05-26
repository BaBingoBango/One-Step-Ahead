//
//  GameCenterMatchmakerView.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 5/22/22.
//

import Foundation
import SwiftUI
import UIKit
import GameKit

/// A SwiftUI view for displaying the Game Center matchmaker via a modal.
struct GameCenterMatchmakerView: UIViewControllerRepresentable {
    
    // MARK: View Variables
    @Binding var isShowingVersusGameSequence: Bool
    @Binding var match: GKMatch
    var matchRequest: GKMatchRequest
    
    // MARK: View Controller Generator
    func makeUIViewController(context: Context) -> GKMatchmakerViewController {
        // MARK: Matchmaker Settings
        let matchmakerController = GKMatchmakerViewController(matchRequest: matchRequest)!
        matchmakerController.matchmakerDelegate = context.coordinator
        
        matchmakerController.isHosted = false
        
        let backgroundView = UIImageView(image: UIImage(named: "small space background"))
        matchmakerController.view.addSubview(backgroundView)
        matchmakerController.view.sendSubviewToBack(backgroundView)
        
        return matchmakerController
    }
    
    // MARK: View Controller Updater
    func updateUIViewController(_ uiViewController: GKMatchmakerViewController, context: Context) {}
    
    // MARK: Coordinator Generator
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: Coordinator Class
    class Coordinator: NSObject, GKMatchmakerViewControllerDelegate, GKLocalPlayerListener, UINavigationControllerDelegate {
        var parent: GameCenterMatchmakerView
        
        init(_ matchmakerController: GameCenterMatchmakerView) {
            // Perform the instantiation
            self.parent = matchmakerController
            super.init()
            
            // Register for GKLocalPlayerListener callbacks
            GKLocalPlayer.local.register(self)
        }
        
        // MARK: Matchmaker Delegate Functions
        func matchmakerViewControllerWasCancelled(_ matchmakerController: GKMatchmakerViewController) {
            // Dismiss the view controller
            matchmakerController.dismiss(animated: true)
        }
        
        func matchmakerViewController(_ matchmakerController: GKMatchmakerViewController, didFailWithError error: Error) {
            // Print the error
            print(error.localizedDescription)
            
            // Dismiss the view controller
            matchmakerController.dismiss(animated: true)
        }
        
        func matchmakerViewController(_ matchmakerController: GKMatchmakerViewController, didFind match: GKMatch) {
            // Dismiss the view controller
            matchmakerController.dismiss(animated: true)
            
            // Set up the GKMatch object
            parent.match = match
            
            // Execute a three second delay
            sleep(3)
            
            // Present the Versus game sequence
            parent.isShowingVersusGameSequence = true
        }
    }
    
}
