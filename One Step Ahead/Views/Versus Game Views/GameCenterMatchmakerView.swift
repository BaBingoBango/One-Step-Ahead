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
    @Binding var game: GameState
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
            
            // Create an sorted list of players by ID
            var playerList = match.players
            playerList.append(GKLocalPlayer.local)
            playerList.sort(by: { $0.teamPlayerID > $1.teamPlayerID })
            
            // Using seed 925, choose a random player to get the rules from
            var seededGenerator = SeededGenerator(seed: 925)
            let randomIndex = Int.random(in: 0...(playerList.count - 1), using: &seededGenerator)
            
            // If the user is chosen, transmit the rules to everyone else
            if playerList[randomIndex].gamePlayerID == GKLocalPlayer.local.teamPlayerID {
                // Prepare the data
                let matchRules = MatchRules(task: parent.game.task, gameMode: parent.game.gameMode, difficulty: parent.game.difficulty, defaultCommandText: parent.game.defaultCommandText)
                let rulesData = try! JSONSerialization.data(withJSONObject: matchRules, options: .prettyPrinted)
                
                // Transmit the data
                do {
                    try match.sendData(toAllPlayers: rulesData, with: .reliable)
                } catch {
                    // FIXME: Handle rules transmission error
                }
            } else {
                // If the user is not chosen, set the GameState object to a template state to await receipt of rules data
                parent.game.task = Task(category: .drawing, object: "", commandPhrase: "something!", genericDescription: "Waiting for rules transmission...", emoji: "")
            }
            // FIXME: Receive rules data https://stackoverflow.com/questions/57281389/implement-delegates-within-swiftui-views
            
            // Execute a three second delay
            sleep(3)
            
            // Present the Versus game sequence
            parent.isShowingVersusGameSequence = true
        }
    }
    
}
