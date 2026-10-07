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
struct UserTaskRecords: RawRepresentable, Equatable {
    
    // MARK: - Variables
    /// The user's save data for the number of times a game has been finished with each task and the high score for each task.
    ///
    /// The outermost key is the object name of a `DrawingTask`. If a key is not present, the `DrawingTask` is locked.
    ///
    /// The inner key is either `"timesPlayed"` or `"highScore"`. Both should exist for an unlocked `DrawingTask`.
    ///
    /// The inner value is the corresponding `Int` for the inner key.
    var records: [String: [String : Int]] = [:]
    /// The JSON string representation of the  `records` dictionary.
    var rawValue: String {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: records, options: .prettyPrinted),
              let json = String(data: jsonData, encoding: .utf8) else {
            return "{}"
        }
        return json
    }
    
    // MARK: Initalizers
    // Default Initalizer
    init() {
        records = [:]
    }
    
    // RawRepresentable Initalizer
    init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let records = try? JSONSerialization.jsonObject(with: data) as? [String: [String : Int]] else {
            return nil
        }
        self.records = records
    }
    
    // MARK: Type Alias
    typealias RawValue = String
    
    // MARK: Equatable
    /// Two records are equal when they hold the same save data, regardless of the order the JSON serializer wrote the keys in.
    static func == (lhs: UserTaskRecords, rhs: UserTaskRecords) -> Bool {
        lhs.records == rhs.records
    }
    
}
