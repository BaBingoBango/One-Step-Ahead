//
//  DiskServices.swift
//  
//
//  Created by Ethan Marshall on 4/9/22.
//

import Foundation
import UIKit

/// Saves the given image to the disk with the given name.
func saveImage(_ image: UIImage, name: String?) {
    if let data = image.pngData() {
        let filename = getDocumentsDirectory().appendingPathComponent(name ?? "image.png")
        try? data.write(to: filename)
        print("Image saved to \(getDocumentsDirectory())")
    }
}

/// Returns a URL to the user's documents directory for the app.
func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}
