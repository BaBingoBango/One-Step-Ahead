////
////  MLServices.swift
////
////
////  Created by Ethan Marshall on 4/12/22.
////
//
//import Foundation
//import UIKit
//import CreateML
//
//extension GameView {
//    /// Uses machine learning and the player's guesses to assign the AI a numerical score for the round.
//    ///
//    /// Before judging the AI, the function first loads all training and testing data, save for training data for the current task object, onto the disk. This is so that the files can be accessed by Create ML.
//    ///
//    /// Training files are stored in the documents directory, while testing files are stored in the temporary directory.
//    ///
//    /// There are 2 training images for each drawing (save for the current task object, of which there is no built-in testing data) and 10 testing images for each drawing type.
//    ///
//    /// The process by which the AI is judged depends on whether or not it is the first round of play. If it is, the score is simply copied from the player's first-round score.
//    ///
//    /// If it is not the first round, the model is trained on the built-in testing data, plus the user's drawings. It is then evalauted on the built-in testing data. The returned score is the model's precision for the current task object.
//    ///
//    /// - Returns: The AI's score for the current round.
//    func getAIscore() -> Double {
//
//        // Get all the drawing objects
//        let drawingTypes = ["Apple", "Axe", "Bird", "Bowtie", "Broom", "Calculator", "Cat", "Clock", "Crown", "Door"]
//
//        // If this is the first round, add the training and testing data for all the drawings to the app's disk
//        if game.currentRound == 1 {
//            for eachDrawingType in drawingTypes {
//                // Add the training data for the drawing type
//                if game.task.object != eachDrawingType {
//                    saveImageToDocuments(UIImage(named: "\(eachDrawingType).1.png")!, name: "\(eachDrawingType).1.png")
//                    saveImageToDocuments(UIImage(named: "\(eachDrawingType).2.png")!, name: "\(eachDrawingType).2.png")
//                }
//
//                // Add the testing data for the drawing type
//                for eachFile in 0...9 {
//                    saveImageToTemp(UIImage(named: "\(eachDrawingType.lowercased())_500\(eachFile).png")!, name: "\(eachDrawingType).\(eachFile + 1).png")
//                }
//            }
//        }
//
//        // Load the training and testing files
//        let trainingData: MLImageClassifier.DataSource = .labeledFiles(at: getDocumentsDirectory())
//        let testingData: MLImageClassifier.DataSource = .labeledFiles(at: FileManager.default.temporaryDirectory)
//
//        // Set up the parameters for the training session
//        let trainingParameters = MLImageClassifier.ModelParameters(
//            featureExtractor: .scenePrint(revision: 1),
//            validationData: nil,
//            maxIterations: 20,
//            augmentationOptions: []
//        )
//
//        // Train a new ML model
//        let AImodel = try! MLImageClassifier(trainingData: trainingData, parameters: trainingParameters)
//
//        // Test the model on the testing data
//        let testingMetrics = AImodel.evaluation(on: testingData)
//
//        // If we are in round 1, stop here and return the player's first score
//        if game.currentRound == 1 {
//            return game.playerScores[0]
//        }
//
//        // Return the recall score for the current task object
//        return testingMetrics.precisionRecall["precision"][drawingTypes.firstIndex(of: game.task.object)!] * 100
//
//    }
//}
//
//extension TutorialGameView {
//    /// Uses machine learning and the player's guesses to assign the AI a numerical score for the round.
//    ///
//    /// Before judging the AI, the function first loads all training and testing data, save for training data for the current task object, onto the disk. This is so that the files can be accessed by Create ML.
//    ///
//    /// Training files are stored in the documents directory, while testing files are stored in the temporary directory.
//    ///
//    /// There are 2 training images for each drawing (save for the current task object, of which there is no built-in testing data) and 10 testing images for each drawing type.
//    ///
//    /// The process by which the AI is judged depends on whether or not it is the first round of play. If it is, the score is simply copied from the player's first-round score.
//    ///
//    /// If it is not the first round, the model is trained on the built-in testing data, plus the user's drawings. It is then evalauted on the built-in testing data. The returned score is the model's precision for the current task object.
//    ///
//    /// - Returns: The AI's score for the current round.
//    func getAIscore() -> Double {
//
//        // Get all the drawing objects
//        let drawingTypes = ["Apple", "Axe", "Bird", "Bowtie", "Broom", "Calculator", "Cat", "Clock", "Crown", "Door"]
//
//        // If this is the first round, add the training and testing data for all the drawings to the app's disk
//        if game.currentRound == 1 {
//            for eachDrawingType in drawingTypes {
//                // Add the training data for the drawing type
//                if game.task.object != eachDrawingType {
//                    saveImageToDocuments(UIImage(named: "\(eachDrawingType).1.png")!, name: "\(eachDrawingType).1.png")
//                    saveImageToDocuments(UIImage(named: "\(eachDrawingType).2.png")!, name: "\(eachDrawingType).2.png")
//                }
//
//                // Add the testing data for the drawing type
//                for eachFile in 0...9 {
//                    saveImageToTemp(UIImage(named: "\(eachDrawingType.lowercased())_500\(eachFile).png")!, name: "\(eachDrawingType).\(eachFile + 1).png")
//                }
//            }
//        }
//
//        // Load the training and testing files
//        let trainingData: MLImageClassifier.DataSource = .labeledFiles(at: getDocumentsDirectory())
//        let testingData: MLImageClassifier.DataSource = .labeledFiles(at: FileManager.default.temporaryDirectory)
//
//        // Set up the parameters for the training session
//        let trainingParameters = MLImageClassifier.ModelParameters(
//            featureExtractor: .scenePrint(revision: 1),
//            validationData: nil,
//            maxIterations: 20,
//            augmentationOptions: []
//        )
//
//        // Train a new ML model
//        let AImodel = try! MLImageClassifier(trainingData: trainingData, parameters: trainingParameters)
//
//        // Test the model on the testing data
//        let testingMetrics = AImodel.evaluation(on: testingData)
//
//        // If we are in round 1, stop here and return the player's first score
//        if game.currentRound == 1 {
//            return game.playerScores[0]
//        }
//
//        // Return the recall score for the current task object
//        return testingMetrics.precisionRecall["precision"][drawingTypes.firstIndex(of: game.task.object)!] * 100
//
//    }
//}
