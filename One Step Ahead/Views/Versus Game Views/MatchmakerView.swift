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
import PencilKit

/// A SwiftUI view for displaying the Game Center matchmaker via a modal.
struct MatchmakerView: UIViewControllerRepresentable {
    
    // MARK: View Variables
    @Binding var isShowingVersusGameSequence: Bool
    @Binding var match: GKMatch
    @Binding var game: GameState
    @Binding var opponentCanvasView: PKCanvasView
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
    class Coordinator: NSObject, GKMatchmakerViewControllerDelegate, GKLocalPlayerListener, GKMatchDelegate, UINavigationControllerDelegate {
        var parent: MatchmakerView
        
        init(_ matchmakerController: MatchmakerView) {
            // Perform the instantiation
            self.parent = matchmakerController
            super.init()
            
            // Register for GKLocalPlayerListener callbacks
            GKLocalPlayer.local.register(self)
        }
        
        // MARK: Match Delegate Functions
        func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
            print("[Match Player Connection State Change]")
            switch state {
            case .unknown:
                print("\(player.displayName) did something unknown.")
            case .connected:
                print("\(player.displayName) connected!")
            case .disconnected:
                print("\(player.displayName) disconnected.")
            @unknown default:
                print("\(player.displayName) exists in an unknown player connection state!")
            }
        }
        
        func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
            print("[Match Data Received From \(player.displayName)]")
            
            // Attempt to decode the data as a set of match rules
            do {
                let rulesData = try JSONDecoder().decode(MatchRules.self, from: data)
                print("The data was decoded as a set of rules!")
                
                // If successful, set the user's rules to match the received ones
                parent.game.task = rulesData.task
                parent.game.gameMode = rulesData.gameMode
                parent.game.difficulty = rulesData.difficulty
                parent.game.defaultCommandText = rulesData.defaultCommandText
            } catch {
                print("The data couldn't be decoded as a set of rules.")
            }
            
            // Attempt to decode the data as a canvas drawing
            do {
                let drawingData = try JSONDecoder().decode(PKDrawing.self, from: data)
                print("The data was decoded as a PencilKit drawing!")
                
                // If successful, update the opponent's canvas
                parent.opponentCanvasView.drawing = drawingData
            } catch {
                print("The data couldn't be decoded as a PencilKit drawing.")
            }
        }
        
        func match(_ match: GKMatch, shouldReinviteDisconnectedPlayer player: GKPlayer) -> Bool {
            // Sets the match to not allow reinvitations after a disconnect
            return false
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
            match.delegate = self
            parent.match = match
            parent.match.delegate = self
            
            // Create an sorted list of players by display name
            var playerNameList: [String] = []
            playerNameList.append(GKLocalPlayer.local.displayName)
            for eachOpponent in match.players {
                playerNameList.append(eachOpponent.displayName)
            }
            playerNameList.sort(by: { $0 > $1 })
            
            // Using seed 925, choose a random player to get the rules from
            var seededGenerator = SeededGenerator(seed: 925)
            let randomIndex = Int.random(in: 0...(playerNameList.count - 1), using: &seededGenerator)
            
            // If the user is chosen, transmit the rules to everyone else
            if playerNameList[randomIndex] == GKLocalPlayer.local.displayName {
                // Prepare the data
                let matchRules = MatchRules(task: parent.game.task, gameMode: parent.game.gameMode, difficulty: parent.game.difficulty, defaultCommandText: parent.game.defaultCommandText)
                let rulesData = try! JSONEncoder().encode(matchRules)
                
                // Transmit the data
                print("[Rules Data Transmission]")
                do {
                    try match.sendData(toAllPlayers: rulesData, with: .reliable)
                    print("Data succesfully sent!")
                } catch {
                    // FIXME: Handle rules transmission error
                    print("Data failed to send.")
                }
            } else {
                // If the user is not chosen, set the GameState object to a template state to await receipt of rules data
                parent.game.task = Task(category: .drawing, object: "", commandPhrase: "something!", genericDescription: "Waiting for rules transmission...", emoji: "")
            }
            
            // Execute a three second delay
            sleep(3)
            
            // Present the Versus game sequence
            parent.isShowingVersusGameSequence = true
        }
    }
    
}
