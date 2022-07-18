/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Makes predictions from images using the Drawing Judge Model.
*/

import Vision
import UIKit

/// A convenience class that makes image classification predictions.
///
/// The Image Predictor creates and reuses an instance of a Core ML image classifier inside a ``VNCoreMLRequest``.
/// Each time it makes a prediction, the class:
/// - Creates a `VNImageRequestHandler` with an image
/// - Starts an image classification request for that image
/// - Converts the prediction results in a completion handler
/// - Updates the delegate's `predictions` property
/// - Tag: ImagePredictor
class ImagePredictor {
    /// - Tag: name
    static func createImageClassifier(ultraDrawingJudgeModel: UltraDrawingJudgeModel = .one) -> VNCoreMLModel {
        // Use a default model configuration.
        let defaultConfig = MLModelConfiguration()

        // Create an instance of the image classifier's wrapper class.
        let imageClassifierWrapper = try? Drawing_Judge_Model(configuration: defaultConfig, ultraDrawingJudgeModel: ultraDrawingJudgeModel)

        guard let imageClassifier = imageClassifierWrapper else {
            fatalError("App failed to create an image classifier model instance.")
        }

        // Get the underlying model instance.
        let imageClassifierModel = imageClassifier.model

        // Create a Vision instance using the image classifier's model instance.
        guard let imageClassifierVisionModel = try? VNCoreMLModel(for: imageClassifierModel) else {
            fatalError("App failed to create a `VNCoreMLModel` instance.")
        }

        return imageClassifierVisionModel
    }
    
    private static let imageClassifier1 = createImageClassifier(ultraDrawingJudgeModel: .one)
    private static let imageClassifier2 = createImageClassifier(ultraDrawingJudgeModel: .two)
    private static let imageClassifier3 = createImageClassifier(ultraDrawingJudgeModel: .three)
    private static let imageClassifier4 = createImageClassifier(ultraDrawingJudgeModel: .four)
    private static let imageClassifier5 = createImageClassifier(ultraDrawingJudgeModel: .five)
    private static let imageClassifier6 = createImageClassifier(ultraDrawingJudgeModel: .six)
    private static let imageClassifier7 = createImageClassifier(ultraDrawingJudgeModel: .seven)
    private static let imageClassifier8 = createImageClassifier(ultraDrawingJudgeModel: .eight)
    private static let imageClassifier9 = createImageClassifier(ultraDrawingJudgeModel: .nine)
    private static let imageClassifier10 = createImageClassifier(ultraDrawingJudgeModel: .ten)
    private static let imageClassifier11 = createImageClassifier(ultraDrawingJudgeModel: .eleven)
    private static let imageClassifier12 = createImageClassifier(ultraDrawingJudgeModel: .tweleve)
    private static let imageClassifier13 = createImageClassifier(ultraDrawingJudgeModel: .thirteen)
    private static let imageClassifier14 = createImageClassifier(ultraDrawingJudgeModel: .fourteen)
    private static let imageClassifier15 = createImageClassifier(ultraDrawingJudgeModel: .fifteen)
    private static let imageClassifier16 = createImageClassifier(ultraDrawingJudgeModel: .sixteen)
    private static let imageClassifier17 = createImageClassifier(ultraDrawingJudgeModel: .seventeen)
    private static let imageClassifier18 = createImageClassifier(ultraDrawingJudgeModel: .eighteen)
    private static let imageClassifier19 = createImageClassifier(ultraDrawingJudgeModel: .nineteen)
    private static let imageClassifier20 = createImageClassifier(ultraDrawingJudgeModel: .twenty)
    private static let imageClassifier21 = createImageClassifier(ultraDrawingJudgeModel: .twentyone)
    private static let imageClassifier22 = createImageClassifier(ultraDrawingJudgeModel: .twentytwo)
    private static let imageClassifier23 = createImageClassifier(ultraDrawingJudgeModel: .twentythree)
    private static let imageClassifier24 = createImageClassifier(ultraDrawingJudgeModel: .twentyfour)
    private static let imageClassifier25 = createImageClassifier(ultraDrawingJudgeModel: .twentyfive)
    private static let imageClassifier26 = createImageClassifier(ultraDrawingJudgeModel: .twentysix)
    private static let imageClassifier27 = createImageClassifier(ultraDrawingJudgeModel: .twentyseven)

    /// Stores a classification name and confidence for an image classifier's prediction.
    /// - Tag: Prediction
    struct Prediction {
        /// The name of the object or scene the image classifier recognizes in an image.
        let classification: String

        /// The image classifier's confidence as a percentage string.
        ///
        /// The prediction string doesn't include the % symbol in the string.
        let confidencePercentage: String
    }

    /// The function signature the caller must provide as a completion handler.
    typealias ImagePredictionHandler = (_ predictions: [Prediction]?) -> Void

    /// A dictionary of prediction handler functions, each keyed by its Vision request.
    private var predictionHandlers = [VNRequest: ImagePredictionHandler]()

    /// Generates a new request instance that uses the Image Predictor's image classifier model.
    private func createImageClassificationRequest(ultraDrawingJudgeModel: UltraDrawingJudgeModel) -> VNImageBasedRequest {
        // Create an image classification request with an image classifier model.

        let imageClassificationRequest = VNCoreMLRequest(model: {
            switch ultraDrawingJudgeModel {
            case .one:
                return ImagePredictor.imageClassifier1
            case .two:
                return ImagePredictor.imageClassifier2
            case .three:
                return ImagePredictor.imageClassifier3
            case .four:
                return ImagePredictor.imageClassifier4
            case .five:
                return ImagePredictor.imageClassifier5
            case .six:
                return ImagePredictor.imageClassifier6
            case .seven:
                return ImagePredictor.imageClassifier7
            case .eight:
                return ImagePredictor.imageClassifier8
            case .nine:
                return ImagePredictor.imageClassifier9
            case .ten:
                return ImagePredictor.imageClassifier10
            case .eleven:
                return ImagePredictor.imageClassifier11
            case .tweleve:
                return ImagePredictor.imageClassifier12
            case .thirteen:
                return ImagePredictor.imageClassifier13
            case .fourteen:
                return ImagePredictor.imageClassifier14
            case .fifteen:
                return ImagePredictor.imageClassifier15
            case .sixteen:
                return ImagePredictor.imageClassifier16
            case .seventeen:
                return ImagePredictor.imageClassifier17
            case .eighteen:
                return ImagePredictor.imageClassifier18
            case .nineteen:
                return ImagePredictor.imageClassifier19
            case .twenty:
                return ImagePredictor.imageClassifier20
            case .twentyone:
                return ImagePredictor.imageClassifier21
            case .twentytwo:
                return ImagePredictor.imageClassifier22
            case .twentythree:
                return ImagePredictor.imageClassifier23
            case .twentyfour:
                return ImagePredictor.imageClassifier24
            case .twentyfive:
                return ImagePredictor.imageClassifier25
            case .twentysix:
                return ImagePredictor.imageClassifier26
            case .twentyseven:
                return ImagePredictor.imageClassifier27
            }
        }(), completionHandler: visionRequestHandler)

        imageClassificationRequest.imageCropAndScaleOption = .centerCrop
        return imageClassificationRequest
    }

    /// Generates an image classification prediction for a photo.
    /// - Parameter ultraDrawingJudgeModel: The model from the Ultra Drawing Judge to use for predictions.
    /// - Parameter photo: An image, typically of an object or a scene.
    /// - Tag: makePredictions
    func makePredictions(with ultraDrawingJudgeModel: UltraDrawingJudgeModel, for photo: UIImage, completionHandler: @escaping ImagePredictionHandler) throws {
        let orientation = CGImagePropertyOrientation(photo.imageOrientation)

        guard let photoImage = photo.cgImage else {
            fatalError("Photo doesn't have underlying CGImage.")
        }

        let imageClassificationRequest = createImageClassificationRequest(ultraDrawingJudgeModel: ultraDrawingJudgeModel)
        predictionHandlers[imageClassificationRequest] = completionHandler

        let handler = VNImageRequestHandler(cgImage: photoImage, orientation: orientation)
        let requests: [VNRequest] = [imageClassificationRequest]

        // Start the image classification request.
        try handler.perform(requests)
    }

    /// The completion handler method that Vision calls when it completes a request.
    /// - Parameters:
    ///   - request: A Vision request.
    ///   - error: An error if the request produced an error; otherwise `nil`.
    ///
    ///   The method checks for errors and validates the request's results.
    /// - Tag: visionRequestHandler
    private func visionRequestHandler(_ request: VNRequest, error: Error?) {
        // Remove the caller's handler from the dictionary and keep a reference to it.
        guard let predictionHandler = predictionHandlers.removeValue(forKey: request) else {
            fatalError("Every request must have a prediction handler.")
        }

        // Start with a `nil` value in case there's a problem.
        var predictions: [Prediction]? = nil

        // Call the client's completion handler after the method returns.
        defer {
            // Send the predictions back to the client.
            predictionHandler(predictions)
        }

        // Check for an error first.
        if let error = error {
            print("Vision image classification error...\n\n\(error.localizedDescription)")
            return
        }

        // Check that the results aren't `nil`.
        if request.results == nil {
            print("Vision request had no results.")
            return
        }

        // Cast the request's results as an `VNClassificationObservation` array.
        guard let observations = request.results as? [VNClassificationObservation] else {
            // Image classifiers, like MobileNet, only produce classification observations.
            // However, other Core ML model types can produce other observations.
            // For example, a style transfer model produces `VNPixelBufferObservation` instances.
            print("VNRequest produced the wrong result type: \(type(of: request.results)).")
            return
        }

        // Create a prediction array from the observations.
        predictions = observations.map { observation in
            // Convert each observation into an `ImagePredictor.Prediction` instance.
            Prediction(classification: observation.identifier,
                       confidencePercentage: observation.confidencePercentageString)
        }
    }
}

extension CGImagePropertyOrientation {
    /// Converts an image orientation to a Core Graphics image property orientation.
    /// - Parameter orientation: A `UIImage.Orientation` instance.
    ///
    /// The two orientation types use different raw values.
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
            case .up: self = .up
            case .down: self = .down
            case .left: self = .left
            case .right: self = .right
            case .upMirrored: self = .upMirrored
            case .downMirrored: self = .downMirrored
            case .leftMirrored: self = .leftMirrored
            case .rightMirrored: self = .rightMirrored
            @unknown default: self = .up
        }
    }
}

extension VNClassificationObservation {
    /// Generates a string of the observation's confidence as a percentage.
    var confidencePercentageString: String {
        let percentage = confidence * 100

        switch percentage {
            case 100.0...:
                return "100%"
            case 10.0..<100.0:
                return String(format: "%2.1f", percentage)
            case 1.0..<10.0:
                return String(format: "%2.1f", percentage)
            case ..<1.0:
                return String(format: "%1.2f", percentage)
            default:
                return String(format: "%2.1f", percentage)
        }
    }
}
