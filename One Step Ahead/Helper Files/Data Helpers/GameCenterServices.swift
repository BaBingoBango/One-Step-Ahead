//
//  GameCenterServices.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 6/5/22.
//

import Foundation
import GameKit

/// Reports the given progress on an achievement to Game Center.
///
/// Some code for this function is taken from https://developer.apple.com/documentation/gamekit/rewarding_players_with_achievements
/// - Parameters:
///   - achievementID: The ID string for the achievement to report on.
///   - progress: The progress to add towards the achievement, where `100.0` represents 100% completion.
func reportAchievementProgress(_ achievementID: String, progress: Double = 100.0) {
    Task {
        // Load the player's active achievements
        var achievements: [GKAchievement] = []
        do {
            achievements = try await GKAchievement.loadAchievements()
        } catch {
            print("[Achievement Loading Error]")
            print(error.localizedDescription)
        }
        
        // Find an existing achievement if one exists; if not, create a new achievement
        let achievement = achievements.first(where: { $0.identifier == achievementID }) ?? GKAchievement(identifier: achievementID)
        
        // Add the new progress to the achievement and enable banner display
        achievement.percentComplete += progress
        achievement.showsCompletionBanner = true
        
        // Report the achievement to Game Center
        do {
            try await GKAchievement.report([achievement])
        } catch {
            print("[Achievement Reporting Error]")
            print(error.localizedDescription)
        }
    }
}

/// Uploads the given score to the given Game Center leaderboard for the local player.
///
/// Source code for this function is taken from https://developer.apple.com/documentation/gamekit/creating_recurring_leaderboards
/// - Parameters:
///   - leaderboardID: The ID of the leaderboard to upload the score to.
///   - score: The score to upload to the leaderboard.
func uploadLeaderboardScore(_ leaderboardID: String, score: Int) {
    Task {
        do {
            try await GKLeaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [leaderboardID])
            print("[Leaderboard Score Upload Finished]")
        } catch {
            print("[Leaderboard Score Upload Error]")
            print(error.localizedDescription)
        }
    }
}
