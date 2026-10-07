//
//  One_Step_AheadTests.swift
//  One Step AheadTests
//
//  Created by Ethan Marshall on 5/16/22.
//

import TabularData
import Testing
@testable import One_Step_Ahead

/// Tests for the way drawing types are divided among the Ultra Drawing Judge's models.
struct UltraDrawingJudgeModelTests {
    
    @Test func drawingTypesAreAssignedAlphabetically() {
        #expect(UltraDrawingJudgeModel(forObject: "Apple") == .one)
        #expect(UltraDrawingJudgeModel(forObject: "Backpack") == .one)
        #expect(UltraDrawingJudgeModel(forObject: "Banana") == .two)
        #expect(UltraDrawingJudgeModel(forObject: "Cat") == .five)
        #expect(UltraDrawingJudgeModel(forObject: "Ladder") == .thirteen)
        #expect(UltraDrawingJudgeModel(forObject: "Wine Glass") == .twentysix)
        #expect(UltraDrawingJudgeModel(forObject: "Zigzag") == .twentyseven)
    }
    
    @Test func everyModelJudgesAtLeastOneDrawingType() {
        let coveredModels = Set(DrawingTask.taskList.map { UltraDrawingJudgeModel(forObject: $0.object) })
        #expect(coveredModels.count == UltraDrawingJudgeModel.allCases.count)
    }
    
    @Test func modelsNeverSkipBackwardsThroughTheAlphabet() {
        let sortedObjects = DrawingTask.taskList.map(\.object).sorted()
        let modelNumbers = sortedObjects.map { UltraDrawingJudgeModel(forObject: $0).rawValue }
        #expect(modelNumbers == modelNumbers.sorted())
    }
    
    @Test func resourceNamesMatchTheBundledModels() {
        #expect(UltraDrawingJudgeModel.one.resourceName == "Ultra Drawing Judge 1")
        #expect(UltraDrawingJudgeModel.twentyseven.resourceName == "Ultra Drawing Judge 27")
    }
}

/// Tests for the scoring rules of a game.
@MainActor
struct GameStateTests {
    
    @Test func firstRoundScoreIgnoresTheMachine() {
        var game = GameState()
        game.playerScores = [80.0]
        game.AIscores = [95.0]
        #expect(game.gameScore == Int(((80.0 * 100.0) + 10_000) * 5.0))
    }
    
    @Test func laterRoundsSubtractTheMachineAndDivideByRound() {
        var game = GameState()
        game.currentRound = 2
        game.playerScores = [50.0, 90.0]
        game.AIscores = [50.0, 40.0]
        #expect(game.gameScore == Int(((9_000.0 - 4_000.0 + 10_000.0) / 2.0) * 5.0))
    }
    
    @Test(arguments: [
        (Difficulty.easy, 80, 90), (Difficulty.normal, 90, 90), (Difficulty.hard, 97, 80), (Difficulty.lunatic, 99, 50)
    ])
    func winThresholdsFollowTheDifficulty(difficulty: Difficulty, playerThreshold: Int, AIthreshold: Int) {
        var game = GameState()
        game.difficulty = difficulty
        #expect(game.playerWinThreshold == playerThreshold)
        #expect(game.AIwinThreshold == AIthreshold)
    }
}

/// Tests for the persistence of the user's gallery save data.
@MainActor
struct UserTaskRecordsTests {
    
    @Test func recordsSurviveARoundTripThroughTheirRawValue() throws {
        var records = UserTaskRecords()
        records.records["Apple"] = ["timesPlayed": 2, "highScore": 12_345]
        records.records["Ladder"] = ["timesPlayed": 1, "highScore": 99_000]
        
        let decoded = try #require(UserTaskRecords(rawValue: records.rawValue))
        #expect(decoded == records)
    }
    
    @Test func malformedSaveDataIsRejectedInsteadOfCrashing() {
        #expect(UserTaskRecords(rawValue: "not json") == nil)
        #expect(UserTaskRecords(rawValue: "[1, 2, 3]") == nil)
    }
}

/// Tests for the way the Machine's score is read from Create ML's evaluation results.
struct MachineOpponentTests {
    
    /// A precision and recall table laid out the way Create ML produces it: one row per class, sorted by class name.
    private func precisionTable() -> DataFrame {
        var table = DataFrame()
        table.append(column: Column(name: "class", contents: ["Apple", "Banana", "Cat"]))
        table.append(column: Column(name: "precision", contents: [0.75, 0.5, 0.25]))
        table.append(column: Column(name: "recall", contents: [0.5, 0.5, 0.5]))
        return table
    }
    
    @Test func precisionComesFromTheDrawingTypesOwnRow() {
        let table = precisionTable()
        #expect(MachineOpponent.precisionPercentage(forDrawingType: "Cat", in: table) == 25)
        #expect(MachineOpponent.precisionPercentage(forDrawingType: "Banana", in: table) == 50)
        #expect(MachineOpponent.precisionPercentage(forDrawingType: "Apple", in: table) == 75)
    }
    
    @Test func drawingTypesMissingFromTheTableHaveNoPrecision() {
        #expect(MachineOpponent.precisionPercentage(forDrawingType: "Ladder", in: precisionTable()) == nil)
    }
    
    @Test func undefinedPrecisionCountsAsZero() {
        var table = DataFrame()
        table.append(column: Column(name: "class", contents: ["Apple"]))
        table.append(column: Column(name: "precision", contents: [Double.nan]))
        #expect(MachineOpponent.precisionPercentage(forDrawingType: "Apple", in: table) == 0)
    }
}
