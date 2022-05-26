//
//  MatchDelegateView.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 5/26/22.
//

import Foundation
import SwiftUI
import GameKit

struct MatchDelegateView: UIViewControllerRepresentable {
    
    // MARK: View Controller Generator
    func makeUIViewController(context: Context) -> UIViewController {
        // MARK: View Controller Settings
        let matchDelegateController = UIViewController()
        
        return matchDelegateController
    }
    
    // MARK: View Controller Updater
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    // MARK: Coordinator Generator
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
        
    // MARK: Coordinator Class
    class Coordinator: NSObject, GKMatchDelegate, UINavigationControllerDelegate {
        var parent: MatchDelegateView
        
        init(_ viewController: MatchDelegateView) {
            // Perform the instantiation
            self.parent = viewController
            super.init()
            
//            viewController.delegate = self
        }
        
        // MARK: Delegate Functions
        func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
            
        }
    }
    
}
