//
//  AudioServices.swift
//  
//
//  Created by Ethan Marshall on 4/13/22.
//

import Foundation
import AVFoundation

// Variables
/// The global audio player for the app.
var audioPlayer: AVAudioPlayer?

/// Uses the global player to play the given audio file.
func playAudio(fileName: String, type: String) {
    
    if let path = Bundle.main.path(forResource: fileName, ofType: type) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            // Set the audio player to infinite loop
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
        } catch {
            print("Could not locate and play the sound file.")
        }
    }
}

/// Stops whatever is playing on the global player.
func stopAudio() {
    audioPlayer?.stop()
}
