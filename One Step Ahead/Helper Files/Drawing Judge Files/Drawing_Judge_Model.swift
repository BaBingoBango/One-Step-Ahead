//
// Drawing_Judge_Model.swift
//
// This file was automatically generated and should not be edited.
//

import CoreML


/// Model Prediction Input Type
@available(macOS 10.14, iOS 12.0, tvOS 12.0, *)
@available(watchOS, unavailable)
class Drawing_Judge_ModelInput : MLFeatureProvider {

    /// Input image to be classified as color (kCVPixelFormatType_32BGRA) image buffer, 299 pixels wide by 299 pixels high
    var image: CVPixelBuffer

    var featureNames: Set<String> {
        get {
            return ["image"]
        }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "image") {
            return MLFeatureValue(pixelBuffer: image)
        }
        return nil
    }
    
    init(image: CVPixelBuffer) {
        self.image = image
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    convenience init(imageWith image: CGImage) throws {
        self.init(image: try MLFeatureValue(cgImage: image, pixelsWide: 299, pixelsHigh: 299, pixelFormatType: kCVPixelFormatType_32BGRA, options: nil).imageBufferValue!)
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    convenience init(imageAt image: URL) throws {
        self.init(image: try MLFeatureValue(imageAt: image, pixelsWide: 299, pixelsHigh: 299, pixelFormatType: kCVPixelFormatType_32BGRA, options: nil).imageBufferValue!)
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func setImage(with image: CGImage) throws  {
        self.image = try MLFeatureValue(cgImage: image, pixelsWide: 299, pixelsHigh: 299, pixelFormatType: kCVPixelFormatType_32BGRA, options: nil).imageBufferValue!
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func setImage(with image: URL) throws  {
        self.image = try MLFeatureValue(imageAt: image, pixelsWide: 299, pixelsHigh: 299, pixelFormatType: kCVPixelFormatType_32BGRA, options: nil).imageBufferValue!
    }

}


/// Model Prediction Output Type
@available(macOS 10.14, iOS 12.0, tvOS 12.0, *)
@available(watchOS, unavailable)
class Drawing_Judge_ModelOutput : MLFeatureProvider {

    /// Source provided by CoreML
    private let provider : MLFeatureProvider

    /// Probability of each category as dictionary of strings to doubles
    lazy var classLabelProbs: [String : Double] = {
        [unowned self] in return self.provider.featureValue(for: "classLabelProbs")!.dictionaryValue as! [String : Double]
    }()

    /// Most likely image category as string value
    lazy var classLabel: String = {
        [unowned self] in return self.provider.featureValue(for: "classLabel")!.stringValue
    }()

    var featureNames: Set<String> {
        return self.provider.featureNames
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        return self.provider.featureValue(for: featureName)
    }

    init(classLabelProbs: [String : Double], classLabel: String) {
        self.provider = try! MLDictionaryFeatureProvider(dictionary: ["classLabelProbs" : MLFeatureValue(dictionary: classLabelProbs as [AnyHashable : NSNumber]), "classLabel" : MLFeatureValue(string: classLabel)])
    }

    init(features: MLFeatureProvider) {
        self.provider = features
    }
}


/// Class for model loading and prediction
@available(macOS 10.14, iOS 12.0, tvOS 12.0, *)
@available(watchOS, unavailable)
class Drawing_Judge_Model {
    let model: MLModel
    let ultraDrawingJudgeModel: UltraDrawingJudgeModel = .one

    /// URL of model assuming it was installed in the same bundle as this class
    class var urlOfModelInThisBundle : URL {
        let bundle = Bundle(for: self)
        return bundle.url(forResource: "Drawing Judge", withExtension: "mlmodelc")!
    }

    /**
        Construct Drawing_Judge_Model instance with an existing MLModel object.

        Usually the application does not use this initializer unless it makes a subclass of Drawing_Judge_Model.
        Such application may want to use `MLModel(contentsOfURL:configuration:)` and `Drawing_Judge_Model.urlOfModelInThisBundle` to create a MLModel object to pass-in.

        - parameters:
          - model: MLModel object
    */
    init(model: MLModel) {
        self.model = model
    }

    /**
        Construct Drawing_Judge_Model instance by automatically loading the model from the app's bundle.
    */
    @available(*, deprecated, message: "Use init(configuration:) instead and handle errors appropriately.")
    convenience init() {
        try! self.init(contentsOf: type(of:self).urlOfModelInThisBundle)
    }

    /**
        Construct a model with configuration

        - parameters:
           - configuration: the desired model configuration

        - throws: an NSError object that describes the problem
    */
    convenience init(configuration: MLModelConfiguration) throws {
        try self.init(contentsOf: type(of:self).urlOfModelInThisBundle, configuration: configuration)
    }
    
    /**
        Construct a model from a configuration and with a custom Ultra Drawing Judge model.

        - parameters:
           - configuration: the desired model configuration
           - ultraDrawingJudgeModel: The Ultra Drawing Judge model to use.

        - throws: an NSError object that describes the problem
    */
    convenience init(configuration: MLModelConfiguration, ultraDrawingJudgeModel: UltraDrawingJudgeModel) throws {
        // Get the URL to the specified model file
        let bundle = Bundle.main
        let URL = bundle.url(forResource: {
            switch ultraDrawingJudgeModel {
            case .one:
                return "Ultra Drawing Judge 1"
            case .two:
                return "Ultra Drawing Judge 2"
            case .three:
                return "Ultra Drawing Judge 3"
            case .four:
                return "Ultra Drawing Judge 4"
            case .five:
                return "Ultra Drawing Judge 5"
            case .six:
                return "Ultra Drawing Judge 6"
            case .seven:
                return "Ultra Drawing Judge 7"
            case .eight:
                return "Ultra Drawing Judge 8"
            case .nine:
                return "Ultra Drawing Judge 9"
            case .ten:
                return "Ultra Drawing Judge 10"
            case .eleven:
                return "Ultra Drawing Judge 11"
            case .tweleve:
                return "Ultra Drawing Judge 12"
            case .thirteen:
                return "Ultra Drawing Judge 13"
            case .fourteen:
                return "Ultra Drawing Judge 14"
            case .fifteen:
                return "Ultra Drawing Judge 15"
            case .sixteen:
                return "Ultra Drawing Judge 16"
            case .seventeen:
                return "Ultra Drawing Judge 17"
            case .eighteen:
                return "Ultra Drawing Judge 18"
            case .nineteen:
                return "Ultra Drawing Judge 19"
            case .twenty:
                return "Ultra Drawing Judge 20"
            case .twentyone:
                return "Ultra Drawing Judge 21"
            case .twentytwo:
                return "Ultra Drawing Judge 22"
            case .twentythree:
                return "Ultra Drawing Judge 23"
            case .twentyfour:
                return "Ultra Drawing Judge 24"
            case .twentyfive:
                return "Ultra Drawing Judge 25"
            case .twentysix:
                return "Ultra Drawing Judge 26"
            case .twentyseven:
                return "Ultra Drawing Judge 27"
            }
        }(), withExtension: "mlmodelc")!
        
        // Continue the instantiation process with this URL instead of the default
        try self.init(contentsOf: URL, configuration: configuration)
    }

    /**
        Construct Drawing_Judge_Model instance with explicit path to mlmodelc file
        - parameters:
           - modelURL: the file url of the model

        - throws: an NSError object that describes the problem
    */
    convenience init(contentsOf modelURL: URL) throws {
        try self.init(model: MLModel(contentsOf: modelURL))
    }

    /**
        Construct a model with URL of the .mlmodelc directory and configuration

        - parameters:
           - modelURL: the file url of the model
           - configuration: the desired model configuration

        - throws: an NSError object that describes the problem
    */
    convenience init(contentsOf modelURL: URL, configuration: MLModelConfiguration) throws {
        try self.init(model: MLModel(contentsOf: modelURL, configuration: configuration))
    }

    /**
        Construct Drawing_Judge_Model instance asynchronously with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    class func load(configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<Drawing_Judge_Model, Error>) -> Void) {
        return self.load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration, completionHandler: handler)
    }

    /**
        Construct Drawing_Judge_Model instance asynchronously with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - configuration: the desired model configuration
    */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    class func load(configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> Drawing_Judge_Model {
        return try await self.load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct Drawing_Judge_Model instance asynchronously with URL of the .mlmodelc directory with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<Drawing_Judge_Model, Error>) -> Void) {
        MLModel.load(contentsOf: modelURL, configuration: configuration) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))
            case .success(let model):
                handler(.success(Drawing_Judge_Model(model: model)))
            }
        }
    }

    /**
        Construct Drawing_Judge_Model instance asynchronously with URL of the .mlmodelc directory with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
    */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> Drawing_Judge_Model {
        let model = try await MLModel.load(contentsOf: modelURL, configuration: configuration)
        return Drawing_Judge_Model(model: model)
    }

    /**
        Make a prediction using the structured interface

        - parameters:
           - input: the input to the prediction as Drawing_Judge_ModelInput

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as Drawing_Judge_ModelOutput
    */
    func prediction(input: Drawing_Judge_ModelInput) throws -> Drawing_Judge_ModelOutput {
        return try self.prediction(input: input, options: MLPredictionOptions())
    }

    /**
        Make a prediction using the structured interface

        - parameters:
           - input: the input to the prediction as Drawing_Judge_ModelInput
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as Drawing_Judge_ModelOutput
    */
    func prediction(input: Drawing_Judge_ModelInput, options: MLPredictionOptions) throws -> Drawing_Judge_ModelOutput {
        let outFeatures = try model.prediction(from: input, options:options)
        return Drawing_Judge_ModelOutput(features: outFeatures)
    }

    /**
        Make a prediction using the convenience interface

        - parameters:
            - image: Input image to be classified as color (kCVPixelFormatType_32BGRA) image buffer, 299 pixels wide by 299 pixels high

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as Drawing_Judge_ModelOutput
    */
    func prediction(image: CVPixelBuffer) throws -> Drawing_Judge_ModelOutput {
        let input_ = Drawing_Judge_ModelInput(image: image)
        return try self.prediction(input: input_)
    }

    /**
        Make a batch prediction using the structured interface

        - parameters:
           - inputs: the inputs to the prediction as [Drawing_Judge_ModelInput]
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as [Drawing_Judge_ModelOutput]
    */
    func predictions(inputs: [Drawing_Judge_ModelInput], options: MLPredictionOptions = MLPredictionOptions()) throws -> [Drawing_Judge_ModelOutput] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results : [Drawing_Judge_ModelOutput] = []
        results.reserveCapacity(inputs.count)
        for i in 0..<batchOut.count {
            let outProvider = batchOut.features(at: i)
            let result =  Drawing_Judge_ModelOutput(features: outProvider)
            results.append(result)
        }
        return results
    }
}
