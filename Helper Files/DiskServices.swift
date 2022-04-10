//
//  DiskServices.swift
//  
//
//  Created by Ethan Marshall on 4/9/22.
//

import Foundation

/// Returns a URL to the user's documents directory for the app.
func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}
