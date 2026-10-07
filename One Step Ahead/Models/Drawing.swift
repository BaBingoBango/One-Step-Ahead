//
//  Drawing.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 7/9/22.
//

import Foundation
import CloudKit
import UIKit

/// A drawing downloaded from Drawing Central. It corresponds to the Drawing CloudKit record type.
struct Drawing: Identifiable {
    /// A unique ID for this object.
    let id = UUID()
    
    /// The actual drawing image produced by the user.
    var image: CKAsset
    
    /// The object of the task the drawing was completed for.
    var object: String
    
    /// The accuracy score the Ultra Drawing Judge assigned this drawing.
    var score: Double
}

extension Drawing {
    /// The drawing image, decoded from the CloudKit asset's local file.
    var uiImage: UIImage? {
        guard let fileURL = image.fileURL, let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }
}
