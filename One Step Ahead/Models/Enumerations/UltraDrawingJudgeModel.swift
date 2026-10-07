//
//  UltraDrawingJudgeModel.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 7/9/22.
//

import Foundation

/// One of the separate Core ML models that make up the Ultra Drawing Judge.
///
/// Each model covers an alphabetical slice of the drawing types; use ``init(forObject:)`` to find the model that judges a particular drawing.
nonisolated enum UltraDrawingJudgeModel: Int, CaseIterable, Sendable {
    case one = 1
    case two
    case three
    case four
    case five
    case six
    case seven
    case eight
    case nine
    case ten
    case eleven
    case twelve
    case thirteen
    case fourteen
    case fifteen
    case sixteen
    case seventeen
    case eighteen
    case nineteen
    case twenty
    case twentyone
    case twentytwo
    case twentythree
    case twentyfour
    case twentyfive
    case twentysix
    case twentyseven
    
    /// The alphabetically last drawing type covered by each model, except for the final model, which covers everything after "Wine Glass".
    private static let upperBounds = [
        "Backpack", "Bed", "Bowtie", "Cake", "Cat", "Computer", "Diving Board", "Elephant", "Fish", "Giraffe", "Helicopter", "Hurricane", "Leg",
        "Matches", "Mug", "Palm Tree", "Pickup Truck", "Power Outlet", "Rollerskates", "Shoe", "Snowman", "Stereo", "Swing Set", "Toe", "Trumpet", "Wine Glass"
    ]
    
    /// Creates the model that judges the given drawing type.
    /// - Parameter object: The name of a drawing type, such as `"Apple"`.
    init(forObject object: String) {
        // Each upper bound the object sorts after pushes it into the next model
        let index = Self.upperBounds.filter { object > $0 }.count
        self = Self.allCases[index]
    }
    
    /// The name of the model's compiled Core ML resource in the app bundle.
    var resourceName: String {
        "Ultra Drawing Judge \(rawValue)"
    }
}
