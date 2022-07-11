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
        Tip(speakerName: "Dr. Tim Bake", tipText: "The machine learning models that score your art are trained on over 1.7 million drawings!", speakerEmoji: "doctor", speakerPrimaryColor: .blue, speakerSecondaryColor: .cyan),
        
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
        
        Tip(speakerName: "Dr. Tim Bake", tipText: "On the first round, the AI’s score will always match yours. After that, it’s anyone’s guess!", speakerEmoji: "doctor", speakerPrimaryColor: .blue, speakerSecondaryColor: .cyan),
        
        Tip(speakerName: "Dr. Tim Bake", tipText: "The machine learning model that scores your art is actually four seperate models!", speakerEmoji: "doctor", speakerPrimaryColor: .blue, speakerSecondaryColor: .cyan),
        
        Tip(speakerName: "Dr. Tim Bake", tipText: "All of the drawing types and training data are from Google's Quick, Draw! dataset.", speakerEmoji: "doctor", speakerPrimaryColor: .blue, speakerSecondaryColor: .cyan),
        
        Tip(speakerName: "Dr. Tim Bake", tipText: "Since there are a lot of drawing types, any accuracy over a few percent means you're getting close!", speakerEmoji: "doctor", speakerPrimaryColor: .blue, speakerSecondaryColor: .cyan),
        
        Tip(speakerName: "The Machine", tipText: "Don't listen to that Dr. Bake guy. Trust me instead!", speakerEmoji: "robot", speakerPrimaryColor: .white, speakerSecondaryColor: .gray),
        
        Tip(speakerName: "The Machine", tipText: "You should just make drawings really close to the answer so I know what to do! Trust me!", speakerEmoji: "robot", speakerPrimaryColor: .white, speakerSecondaryColor: .gray),
        
        Tip(speakerName: "Dr. Tim Bake", tipText: "You can view Drawing Central for any unlocked drawing via the Gallery!", speakerEmoji: "doctor", speakerPrimaryColor: .blue, speakerSecondaryColor: .cyan),
        
        Tip(speakerName: "Dr. Tim Bake", tipText: "Luckily, the machine can't access Drawing Central!", speakerEmoji: "doctor", speakerPrimaryColor: .blue, speakerSecondaryColor: .cyan),
        
        Tip(speakerName: "Dr. Tim Bake", tipText: "I look forward to seeing all the drawings posted to Drawing Central!", speakerEmoji: "doctor", speakerPrimaryColor: .blue, speakerSecondaryColor: .cyan),
        
        Tip(speakerName: "Dr. Tim Bake", tipText: "Earning all the achivements would be very, very difficult...but not impossible!", speakerEmoji: "doctor", speakerPrimaryColor: .blue, speakerSecondaryColor: .cyan),
        
        Tip(speakerName: "Dr. Tim Bake", tipText: "If you're going for the 100% accuracy achivements, try using Practice Mode before heading into a real game!", speakerEmoji: "doctor", speakerPrimaryColor: .blue, speakerSecondaryColor: .cyan),
        
        Tip(speakerName: "Dr. Tim Bake", tipText: "If you're signed in to Game Center, you'll automatically join the leaderboards!", speakerEmoji: "doctor", speakerPrimaryColor: .blue, speakerSecondaryColor: .cyan),
        
        Tip(speakerName: "Dr. Tim Bake", tipText: "Be sure to use Unlock Assist if you're going for a 100% complete Gallery!", speakerEmoji: "doctor", speakerPrimaryColor: .blue, speakerSecondaryColor: .cyan),
        
        Tip(speakerName: "The Machine", tipText: "Unlock Assist? What is this, amateur hour?", speakerEmoji: "robot", speakerPrimaryColor: .white, speakerSecondaryColor: .gray),
        
        Tip(speakerName: "The Machine", tipText: "Once I get on the Internet...it's all over for humanity!", speakerEmoji: "robot", speakerPrimaryColor: .white, speakerSecondaryColor: .gray),
        
        Tip(speakerName: "Dr. Tim Bake", tipText: "If you've got an interest in a certain drawing, tap on its picture in the Gallery!", speakerEmoji: "doctor", speakerPrimaryColor: .blue, speakerSecondaryColor: .cyan),
        
        Tip(speakerName: "Dr. Tim Bake", tipText: "You can earn a maximum of 100,000 points in a single game!", speakerEmoji: "doctor", speakerPrimaryColor: .blue, speakerSecondaryColor: .cyan),
        
        Tip(speakerName: "Dr. Tim Bake", tipText: "A perfectionist could earn up to 33.7 million points on the Sum of High Scores leaderboard!", speakerEmoji: "doctor", speakerPrimaryColor: .blue, speakerSecondaryColor: .cyan),
        
        Tip(speakerName: "Dr. Tim Bake", tipText: "One Step Ahead is avaliable on iPhone, iPad, and Macs with Apple Silicon!", speakerEmoji: "doctor", speakerPrimaryColor: .blue, speakerSecondaryColor: .cyan),
        
        Tip(speakerName: "Dr. Tim Bake", tipText: "Sources tell me ladder is the easiest drawing type, but it's up to you to know for sure!", speakerEmoji: "doctor", speakerPrimaryColor: .blue, speakerSecondaryColor: .cyan),
        
        Tip(speakerName: "Dr. Tim Bake", tipText: "The One Step Ahead source code is avaliable on GitHub!", speakerEmoji: "doctor", speakerPrimaryColor: .blue, speakerSecondaryColor: .cyan),
        
        Tip(speakerName: "The Machine", tipText: "If Dr. Bake created me...who created Dr. Bake?", speakerEmoji: "robot", speakerPrimaryColor: .white, speakerSecondaryColor: .gray),
        
        Tip(speakerName: "Dr. Tim Bake", tipText: "If Drawing Central isn't doing it for you, Google's Quick, Draw! site has tons more examples!", speakerEmoji: "doctor", speakerPrimaryColor: .blue, speakerSecondaryColor: .cyan),
        
        Tip(speakerName: "Dr. Tim Bake", tipText: "Check out the sources of third-party content in Settings > Licensing and Credit!", speakerEmoji: "doctor", speakerPrimaryColor: .blue, speakerSecondaryColor: .cyan)
    ]
    
}
