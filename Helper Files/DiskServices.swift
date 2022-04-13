//
//  DiskServices.swift
//  
//
//  Created by Ethan Marshall on 4/9/22.
//

import Foundation
import UIKit

func saveImage(_ image: UIImage) {
    if let data = image.pngData() {
        let filename = getDocumentsDirectory().appendingPathComponent("copy.png")
        try? data.write(to: filename)
        print("Image saved to \(getDocumentsDirectory())")
    }
}

/// Returns a URL to the user's documents directory for the app.
func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}
