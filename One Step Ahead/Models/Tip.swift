//
//  Tip.swift
//  
//
//  Created by Ethan Marshall on 4/23/22.
//

import Foundation
import SwiftUI

/// A helpful tidbit about the game or machine learning, shown on the main menu and on the tips view.
struct Tip {
    
    // MARK: Variables
    /// The name of the tip's speaker.
    let speakerName: String
    /// The text of the tip.
    let tipText: String
    /// The name of the emoji representing the speaker.
    let speakerEmoji: String
    /// The primary color representing the speaker.
    let speakerPrimaryColor: Color
    /// The secondary color representing the speaker.
    let speakerSecondaryColor: Color
    
    // MARK: Included App Data
    /// The complete list of all tips for the app.
    static let tipList: [Tip] = [
        Tip(speakerName: "Dr. Tim Bake", tipText: "The machine learning model that scores your art is trained on 50,000 drawings!", speakerEmoji: "doctor", speakerPrimaryColor: .blue, speakerSecondaryColor: .cyan),
        Tip(speakerName: "Dr. Tim Bake", tipText: "If the AI is getting close to winning, try making a bad drawing to throw it off!", speakerEmoji: "doctor", speakerPrimaryColor: .blue, speakerSecondaryColor: .cyan),
        Tip(speakerName: "Dr. Tim Bake", tipText: "The AI's image classifier model is tested on 10 versions of the correct drawing!", speakerEmoji: "doctor", speakerPrimaryColor: .blue, speakerSecondaryColor: .cyan),
        Tip(speakerName: "The Machine", tipText: "I'll be back...", speakerEmoji: "robot", speakerPrimaryColor: .white, speakerSecondaryColor: .gray),
        Tip(speakerName: "The Machine", tipText: "Your world is doomed!", speakerEmoji: "robot", speakerPrimaryColor: .white, speakerSecondaryColor: .gray),
        Tip(speakerName: "Dr. Tim Bake", tipText: "Watch your back...the AI has been known to swoop from 0% to 100% in a single round!", speakerEmoji: "doctor", speakerPrimaryColor: .blue, speakerSecondaryColor: .cyan),
        Tip(speakerName: "Dr. Tim Bake", tipText: "Never give up! Never give in! Never gonna give you up!", speakerEmoji: "doctor", speakerPrimaryColor: .blue, speakerSecondaryColor: .cyan),
        Tip(speakerName: "Dr. Tim Bake", tipText: "It's easy to get started with ML - try developer.apple.com/machine-learning!", speakerEmoji: "doctor", speakerPrimaryColor: .blue, speakerSecondaryColor: .cyan),
        Tip(speakerName: "Dr. Tim Bake", tipText: "If you ever make a machine learning model, be careful not to let it escape like I did!", speakerEmoji: "doctor", speakerPrimaryColor: .blue, speakerSecondaryColor: .cyan),
        Tip(speakerName: "Dr. Tim Bake", tipText: "If you're not sure where to start, try generic shapes like circles, squares, and rectangles!", speakerEmoji: "doctor", speakerPrimaryColor: .blue, speakerSecondaryColor: .cyan),
        Tip(speakerName: "Dr. Tim Bake", tipText: "Yes, I do run a tech company, it's called Orange. Why do you ask?", speakerEmoji: "doctor", speakerPrimaryColor: .blue, speakerSecondaryColor: .cyan),
        Tip(speakerName: "The Machine", tipText: "Please stop asking me to open the pod bay doors.", speakerEmoji: "robot", speakerPrimaryColor: .white, speakerSecondaryColor: .gray),
        Tip(speakerName: "Dr. Tim Bake", tipText: "If you're having trouble, try watching for when the AI's score goes up.", speakerEmoji: "doctor", speakerPrimaryColor: .blue, speakerSecondaryColor: .cyan),
        Tip(speakerName: "Dr. Tim Bake", tipText: "If you and the AI exactly tie, you’ll always win. Phew!", speakerEmoji: "doctor", speakerPrimaryColor: .blue, speakerSecondaryColor: .cyan),
        Tip(speakerName: "Dr. Tim Bake", tipText: "On the first round, the AI’s score will always match yours. After that, it’s anyone’s guess!", speakerEmoji: "doctor", speakerPrimaryColor: .blue, speakerSecondaryColor: .cyan)
    ]
    
}
