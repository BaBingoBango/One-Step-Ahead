//
//  MathServices.swift
//  
//
//  Created by Ethan Marshall on 4/8/22.
//

import Foundation

extension Double {
    /// Truncates the given decimal to the specified number of places.
    /// - Parameter places: The number of decimal places to include in the returned value.
    /// - Returns: The passed-in Double, truncated to the specified number of places, as a Double.
    func truncate(places : Int)-> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
