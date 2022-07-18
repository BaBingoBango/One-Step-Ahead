//
//  Drawing.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 7/9/22.
//

import Foundation
import CloudKit

/// A drawing dowloaded from Drawing Central. It corresponds to the Drawing CloudKit record type.
struct Drawing {
    /// A unique ID for this object.
    var ID = UUID()
    
    /// The actual drawing image produced by the user.
    var image: CKAsset
    
    /// The object of the task the drawing was completed for.
    var object: String
    
    /// The accuracy score the Ultra Drawing Judge assigned this drawing.
    var score: Double
}
