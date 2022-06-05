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
    // Load the player's active achievements
    GKAchievement.loadAchievements(completionHandler: { (achievements: [GKAchievement]?, error: Error?) in
        var achievement: GKAchievement? = nil
        
        // Find an existing achievement if one exists
        achievement = achievements?.first(where: { $0.identifier == achievementID})
        
        // If not, create a new achievement
        if achievement == nil {
            achievement = GKAchievement(identifier: achievementID)
        }
        
        // Add the new progress to the achievement
        achievement!.percentComplete += progress
        
        // Report the achievement to Game Center
        GKAchievement.report([achievement!], withCompletionHandler: {(error: Error?) in
            if error != nil {
                print("[Achievement Reporting Error]")
                print(error!.localizedDescription)
            }
        })
        
        // Print an error message if there is one
        if error != nil {
            print("[Achievement Loading Error]")
            print(error!.localizedDescription)
        }
    })
}
