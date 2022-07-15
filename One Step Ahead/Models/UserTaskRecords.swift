//
//  UserTaskRecords.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 5/19/22.
//

import Foundation

/// A wrapper structure for the user's save data for the number of times a game has been finished with each task and the high score for each task.
///
/// To access the save data, use the `records` member, which is a `[String: [String : Int]]` dictionary.
///
/// To retrieve the data from a view, using `@AppStorage` as follows:
///
/// `@AppStorage("userTaskRecords") var userTaskRecords: UserTaskRecords = UserTaskRecords()`
struct UserTaskRecords: RawRepresentable {
    
    // MARK: - Variables
    /// The user's save data for the number of times a game has been finished with each task and the high score for each task.
    ///
    /// The outermost key is the object name of a `Task`. If a key is not present, the `Task` is locked.
    ///
    /// The inner key is either `"timesPlayed"` or `"highScore"`. Both should exist for an unlocked `Task`.
    ///
    /// The inner value is the corresponding `Int` for the inner key.
    var records: [String: [String : Int]] = [:]
    /// The JSON string representation of the  `records` dictionary.
    var rawValue: String {
        let jsonData = try! JSONSerialization.data(withJSONObject: records, options: .prettyPrinted)
        return String(data: jsonData, encoding: .utf8)!
    }
    
    // MARK: Initalizers
    // Default Initalizer
    init() {
        records = [:]
    }
    
    // RawRepresentable Initalizer
    init?(rawValue: String) {
        records = try! JSONSerialization.jsonObject(with: rawValue.data(using: .utf8)!, options: []) as! [String: [String : Int]]
    }
    
    // MARK: Type Alias
    typealias RawValue = String
    
}
