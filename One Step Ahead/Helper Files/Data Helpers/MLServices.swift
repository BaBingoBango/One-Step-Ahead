//
//  MLServices.swift
//
//
//  Created by Ethan Marshall on 4/12/22.
//

import Foundation
import TabularData
import UIKit
#if canImport(CreateML)
import CreateML
#endif

/// The scores produced by judging one round of play.
nonisolated struct RoundVerdict: Sendable {
    /// The Ultra Drawing Judge's accuracy score for the player's drawing, as a percentage.
    let playerScore: Double
    /// The Machine's score for the round, as a percentage.
    let AIscore: Double
}

/// Scores drawings with the Ultra Drawing Judge and runs the end-of-round judging pipeline.
///
/// Everything here is `nonisolated` so that the expensive model work can run away from the main actor.
nonisolated enum DrawingJudge {
    /// The width, in pixels, of the images that are judged and saved as the Machine's training data.
    static let judgedImageWidth: CGFloat = 256
    
    /// Prepares a rendering of the player's strokes for judging by tinting it black, layering it over a white background, and shrinking it.
    /// - Parameters:
    ///   - strokes: The image of the player's strokes, rendered from the canvas.
    ///   - canvasSize: The size of the canvas the strokes were drawn on.
    static func prepareDrawing(strokes: UIImage, canvasSize: CGSize) -> UIImage {
        let background = UIColor.white.imageWithColor(width: canvasSize.width, height: canvasSize.height)
        let drawing = background.mergeWith(topImage: strokes.tint(with: .black) ?? strokes)
        return drawing.resized(toWidth: judgedImageWidth) ?? drawing
    }
    
    /// Asks the Ultra Drawing Judge how closely an image resembles the given drawing type.
    /// - Parameters:
    ///   - image: A prepared drawing image.
    ///   - object: The drawing type to score the image against.
    /// - Returns: The judge's confidence as a percentage, or `nil` if the prediction fails.
    static func playerScore(for image: UIImage, object: String) -> Double? {
        // Get the probabilities for every drawing type the model knows
        var predictionProbabilities: [String: String] = [:]
        do {
            try ImagePredictor().makePredictions(with: UltraDrawingJudgeModel(forObject: object), for: image) { predictions in
                for eachPrediction in predictions ?? [] {
                    predictionProbabilities[eachPrediction.classification] = eachPrediction.confidencePercentage
                }
            }
        } catch {
            print("[Judge Model Prediction Error]")
            print(error.localizedDescription)
            return nil
        }
        
        // Pull out the score for the requested drawing type
        guard let percentage = predictionProbabilities[object] else { return nil }
        return Double(percentage.replacingOccurrences(of: "%", with: ""))
    }
    
    /// Judges a full round of play: saves the player's drawing as the Machine's training data, scores it, and then scores the Machine.
    ///
    /// This runs on a background thread, since the Machine's Create ML training can take several seconds and would lag the main thread.
    /// - Parameters:
    ///   - strokes: The image of the player's strokes, rendered from the canvas.
    ///   - canvasSize: The size of the canvas the strokes were drawn on.
    ///   - object: The drawing type for the game's task.
    ///   - round: The number of the round being judged.
    ///   - playerScores: The player's scores from the previous rounds.
    @concurrent
    static func judgeRound(strokes: UIImage, canvasSize: CGSize, object: String, round: Int, playerScores: [Double]) async -> RoundVerdict {
        // Prepare the drawing and save it to the Machine's training data
        let drawingImage = prepareDrawing(strokes: strokes, canvasSize: canvasSize)
        saveImageToDocuments(drawingImage, name: "\(object).\(round).png")
        
        // Use the judge model to give the player a score
        let playerScore = playerScore(for: drawingImage, object: object) ?? 0.0
        
        // Train a new AI model and get its testing score. If the AI score to assign is NaN, use 0 as the score.
        let AIscore = MachineOpponent.score(forObject: object, round: round, playerScores: playerScores + [playerScore])
        return RoundVerdict(playerScore: playerScore, AIscore: AIscore.isNaN ? 0.0 : AIscore)
    }
}

/// The Machine: an image classifier that is retrained with Create ML on the player's attempts after every round.
nonisolated enum MachineOpponent {
    /// The number of drawing types, including the game's own, that the Machine learns to tell apart.
    private static let drawingTypesPerGame = 7
    /// The number of built-in testing images for each drawing type.
    private static let testingImagesPerDrawingType = 10
    
    /// Uses machine learning and the player's guesses to assign the AI a numerical score for the round.
    ///
    /// On the first round, the function loads all training and testing data, save for training data for the current task object, onto the disk so that the files can be accessed by Create ML. Training files are stored in the documents directory, while testing files are stored in the temporary directory.
    ///
    /// There are 2 training images for each drawing (save for the current task object, of which there is no built-in training data) and 10 testing images for each drawing type.
    ///
    /// The process by which the AI is judged depends on whether or not it is the first round of play. If it is, the score is simply copied from the player's first-round score.
    ///
    /// If it is not the first round, the model is trained on the built-in training data, plus the user's drawings. It is then evaluated on the built-in testing data. The returned score is the model's precision for the current task object.
    ///
    /// - Parameters:
    ///   - object: The drawing type for the game's task.
    ///   - round: The number of the round being judged.
    ///   - playerScores: The player's scores for every round so far, including the current one.
    /// - Returns: The AI's score for the current round.
    static func score(forObject object: String, round: Int, playerScores: [Double]) -> Double {
        // Get all the drawing objects that the model can classify
        let judgeModel = UltraDrawingJudgeModel(forObject: object)
        var drawingTypes: [String] = [object]
        for eachTask in DrawingTask.taskList where drawingTypes.count < drawingTypesPerGame && eachTask.object != object && UltraDrawingJudgeModel(forObject: eachTask.object) == judgeModel {
            drawingTypes.append(eachTask.object)
        }
        
        // If this is the first round, add the training and testing data for all the drawings to the app's disk
        if round == 1 {
            for eachDrawingType in drawingTypes {
                // Add the training data for the drawing type
                if object != eachDrawingType {
                    for eachFile in 1...2 {
                        if let image = UIImage(named: "\(eachDrawingType).\(eachFile).png") {
                            saveImageToDocuments(image, name: "\(eachDrawingType).\(eachFile).png")
                        }
                    }
                }
                
                // Add the testing data for the drawing type
                for eachFile in 0..<testingImagesPerDrawingType {
                    if let image = UIImage(named: "\(eachDrawingType.lowercased())_500\(eachFile).png") {
                        saveImageToTemp(image, name: "\(eachDrawingType).\(eachFile + 1).png")
                    }
                }
            }
            
            // On the first round, the AI's score always matches the player's
            return playerScores.first ?? 0.0
        }
        
        #if canImport(CreateML)
        do {
            // Load the training and testing files
            let trainingData: MLImageClassifier.DataSource = .labeledFiles(at: getDocumentsDirectory())
            let testingData: MLImageClassifier.DataSource = .labeledFiles(at: FileManager.default.temporaryDirectory)
            
            // Set up the parameters for the training session
            let trainingParameters = MLImageClassifier.ModelParameters(
                validation: .none,
                maxIterations: 20,
                augmentation: [],
                algorithm: .transferLearning(featureExtractor: .scenePrint(revision: 1), classifier: .logisticRegressor)
            )
            
            // Train a new ML model and test it on the testing data
            let AImodel = try MLImageClassifier(trainingData: trainingData, parameters: trainingParameters)
            let testingMetrics = AImodel.evaluation(on: testingData)
            
            // Return the model's precision for the current task object
            return precisionPercentage(forDrawingType: object, in: testingMetrics.precisionRecallDataFrame) ?? 0.0
        } catch {
            print("[AI Training Error]")
            print(error.localizedDescription)
            return 0.0
        }
        #else
        // Create ML is not available on the iOS Simulator, so stand in for the Machine with a fixed score
        return 50.0
        #endif
    }
    
    /// Reads the Machine's precision for a drawing type from Create ML's per-class precision and recall table.
    ///
    /// Create ML sorts the table by class name, so the row has to be found by the drawing type's name rather than by its position in the game's list of drawing types.
    ///
    /// - Parameters:
    ///   - drawingType: The drawing type whose precision to read.
    ///   - precisionRecall: The table of per-class metrics from evaluating the model.
    /// - Returns: The precision as a percentage, or `nil` if the table has no row for the drawing type.
    static func precisionPercentage(forDrawingType drawingType: String, in precisionRecall: DataFrame) -> Double? {
        guard let classColumn = precisionRecall.columns.first(where: { $0.name == "class" }),
              let precisionColumn = precisionRecall.columns.first(where: { $0.name == "precision" }),
              let row = (0..<precisionRecall.shape.rows).first(where: { classColumn[$0] as? String == drawingType }),
              let precision = precisionColumn[row] as? Double else {
            return nil
        }
        
        // A drawing type the model never predicted has no defined precision, which counts as a score of zero
        return precision.isNaN ? 0 : precision * 100
    }
}
