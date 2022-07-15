//
//  AssetType.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 6/10/22.
//

import Foundation

/// A type of third-party resource used in the app.
enum AssetType {
    /// An image file.
    case image
    
    /// An audio file containing a full song.
    case music
    
    /// An audio file containing a short sound effect.
    case soundEffect
    
    /// A dataset of drawing images.
    case drawingDataset
    
    /// A piece of software.
    case software
}
