//
//  DiskServices.swift
//  
//
//  Created by Ethan Marshall on 4/9/22.
//

import Foundation
import UIKit

/// Returns a URL to the user's documents directory for the app.
func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

/// Saves the given image to the disk's documents directory with the given name.
func saveImageToDocuments(_ image: UIImage, name: String?) {
    if let data = image.pngData() {
        let filename = getDocumentsDirectory().appendingPathComponent(name ?? "image.png")
        try? data.write(to: filename)
//        print("Image saved to \(getDocumentsDirectory())")
    }
}

/// Saves the given image to the disk's temp directory with the given name.
func saveImageToTemp(_ image: UIImage, name: String?) {
    if let data = image.pngData() {
        let filename = FileManager.default.temporaryDirectory.appendingPathComponent(name ?? "image.png")
        try? data.write(to: filename)
//        print("Image saved to \(FileManager.default.temporaryDirectory)")
    }
}

/// Retrieves an image file stored in the documents directory.
/// - Parameter fileName: The name of the image file (with extension) stored in the documents directory.
/// - Returns: The image file as a UIImage.
func getImageFromDocuments(_ fileName: String) -> UIImage? {
    let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
    let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
    let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
    if let dirPath = paths.first {
       let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
        return UIImage(contentsOfFile: imageURL.path) ?? UIImage(named: "default artwork")
    } else {
        return nil
    }
}

/// Clears the entire directory located at the given path.
func clearFolder(_ atPath: String) {
    do {
        for eachFile in try FileManager.default.contentsOfDirectory(atPath: atPath) {
            try FileManager.default.removeItem(at: URL(fileURLWithPath: atPath + "/" + eachFile))
        }
    } catch {
        print("Could not clear folder: \(error)")
    }
}
