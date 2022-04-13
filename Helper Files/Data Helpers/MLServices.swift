//
//  MLServices.swift
//  
//
//  Created by Ethan Marshall on 4/12/22.
//

import Foundation
import UIKit
import CreateML

extension GameView {
    /// Uses machine learning and the player's guesses to assign the AI a numerical score for the round.
    func assignAIscore() {
        
        // If this is the first round, add the training data for all the drawings to the app's disk
        if game.currentRound == 1 {
            for eachDrawingType in ["Apple", "Axe", "Bird", "Bowtie", "Broom", "Calculator", "Cat", "Crown", "Clock", "Door"] {
                if game.task.object != eachDrawingType {
                    saveImage(UIImage(named: "\(eachDrawingType).1.png")!, name: "\(eachDrawingType).1.png")
                    saveImage(UIImage(named: "\(eachDrawingType).2.png")!, name: "\(eachDrawingType).2.png")
                }
            }
        }
        
        // Load the training and testing files
        let trainingData: MLImageClassifier.DataSource = .labeledFiles(at: getDocumentsDirectory())
        let testingData: MLImageClassifier.DataSource = .labeledDirectories(at: URL(fileURLWithPath: "~/Helper Files"))
        
        if let data = canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale).pngData() {
            let filename = FileManager.default.temporaryDirectory.appendingPathComponent("drawing.png")
            try? data.write(to: filename)
            print("Image saved to \(FileManager.default.temporaryDirectory)")
        }
        
    }
}
