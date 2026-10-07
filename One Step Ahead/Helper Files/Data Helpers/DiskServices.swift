//
//  DiskServices.swift
//  
//
//  Created by Ethan Marshall on 4/9/22.
//

import Foundation
import UIKit

/// Returns a URL to the user's documents directory for the app.
nonisolated func getDocumentsDirectory() -> URL {
    URL.documentsDirectory
}

/// Saves the given image to the disk's documents directory with the given name.
nonisolated func saveImageToDocuments(_ image: UIImage, name: String?) {
    if let data = image.pngData() {
        let filename = getDocumentsDirectory().appending(path: name ?? "image.png")
        try? data.write(to: filename)
    }
}

/// Saves the given image to the disk's temp directory with the given name.
nonisolated func saveImageToTemp(_ image: UIImage, name: String?) {
    if let data = image.pngData() {
        let filename = URL.temporaryDirectory.appending(path: name ?? "image.png")
        try? data.write(to: filename)
    }
}

/// Retrieves an image file stored in the documents directory.
/// - Parameter fileName: The name of the image file (with extension) stored in the documents directory.
/// - Returns: The image file as a UIImage, or the default artwork if the file is missing.
nonisolated func getImageFromDocuments(_ fileName: String) -> UIImage? {
    let imageURL = getDocumentsDirectory().appending(path: fileName)
    return UIImage(contentsOfFile: imageURL.path()) ?? UIImage(named: "default artwork")
}

/// Clears the entire directory located at the given path.
nonisolated func clearFolder(_ atPath: String) {
    do {
        for eachFile in try FileManager.default.contentsOfDirectory(atPath: atPath) {
            try FileManager.default.removeItem(at: URL(fileURLWithPath: atPath + "/" + eachFile))
        }
    } catch {
        print("Could not clear folder: \(error)")
    }
}
