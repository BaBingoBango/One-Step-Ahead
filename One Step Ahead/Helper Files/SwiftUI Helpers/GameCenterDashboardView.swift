//
//  GameCenterDashboardController.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 5/21/22.
//

import SwiftUI
import UIKit
import GameKit

/// A SwiftUI view for displaying the Game Center dashboard via a modal.
struct GameCenterDashboardView: UIViewControllerRepresentable {
    
    // MARK: View Controller Generator
    func makeUIViewController(context: Context) -> GKGameCenterViewController {
        // MARK: Dashboard Settings
        let dashboardViewController = GKGameCenterViewController(state: .dashboard)
        dashboardViewController.gameCenterDelegate = context.coordinator
        
        let backgroundView = UIImageView(image: UIImage(named: "small space background"))
        dashboardViewController.view.addSubview(backgroundView)
        dashboardViewController.view.sendSubviewToBack(backgroundView)
        
        return dashboardViewController
    }
    
    // MARK: View Controller Updater
    func updateUIViewController(_ uiViewController: GKGameCenterViewController, context: Context) {}
    
    // MARK: Coordinator Generator
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: Coordinator Class
    class Coordinator: NSObject, GKGameCenterControllerDelegate, UINavigationControllerDelegate {
        var parent: GameCenterDashboardView
        
        init(_ dashboardController: GameCenterDashboardView) {
            self.parent = dashboardController
        }
        
        // MARK: Dashboard Delegate Functions
        func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
            // Dismiss the view controller
            gameCenterViewController.dismiss(animated: true)
        }
    }
    
}
