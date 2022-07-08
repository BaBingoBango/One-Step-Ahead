//
//  AudioServices.swift
//  
//
//  Created by Ethan Marshall on 4/13/22.
//

import Foundation
import AVFoundation

// Global Variable
/// The global audio player for the app.
var audioPlayer: AVAudioPlayer?

// Global Functions
/// Uses the global player to play the given audio file on a loop.
/// - Parameters:
///   - fileName: The name of the audio file to play.
///   - type: The file extension of the audio file to play, without the dot, e.g. `"wav"`
func playAudio(fileName: String, type: String) {
    
    if let path = Bundle.main.path(forResource: fileName, ofType: type) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            // Set the audio player to infinite loop
            audioPlayer?.numberOfLoops = -1
            // FIXME: FIX!
//            audioPlayer?.play()
        } catch {
            print("Could not locate and play the sound file.")
        }
    }
}

/// Uses the global player to play the given audio file once.
func playAudioOnce(fileName: String, type: String) {
    
    if let path = Bundle.main.path(forResource: fileName, ofType: type) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            // Set the audio player to not loop
            audioPlayer?.numberOfLoops = 0
            // FIXME: FIX!
//            audioPlayer?.play()
        } catch {
            print("Could not locate and play the sound file.")
        }
    }
}

/// Stops whatever is playing on the global player.
func stopAudio() {
    audioPlayer?.stop()
}

/// Chooses one of the seven battle themes at random and returns its filename.
/// - Returns: The filename of the audio file for the selected theme.
func getRandomBattleThemeFilename() -> String {
    return ["Acceleron", "Autobahn", "Dancing Racoons", "Dragonfly", "Protection of Me", "Scandinavianz Palmtrees", "Synthwave 80s"].randomElement()!
}
