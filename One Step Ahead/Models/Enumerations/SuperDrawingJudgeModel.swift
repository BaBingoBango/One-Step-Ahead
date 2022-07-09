//
//  SuperDrawingJudgeModel.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 7/9/22.
//

import Foundation

/// One of the four seperate models that make up the Super Drawing Judge.
enum SuperDrawingJudgeModel {
    /// The first model of the Super Drawing Judge. Alphabetically, it can classify "Aircraft Carrier" through "Duck".
    case I
    
    /// The second model of the Super Drawing Judge. Alphabetically, it can classify "Dumbbell" through "Ocean".
    case II
    
    /// The third model of the Super Drawing Judge. Alphabetically, it can classify "Octagon" through "Sword".
    case III
    
    /// The fourth model of the Super Drawing Judge. Alphabetically, it can classify "Syringe" through "Zigzag".
    case IV
}
