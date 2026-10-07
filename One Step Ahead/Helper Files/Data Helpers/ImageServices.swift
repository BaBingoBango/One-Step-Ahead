//
//  ImageServices.swift
//  
//
//  Created by Ethan Marshall on 4/11/22.
//

import Foundation
import UIKit

extension UIColor {
    /// Creates a UIImage of a solid color with the given size.
    nonisolated func imageWithColor(width: CGFloat, height: CGFloat) -> UIImage {
        let size = CGSize(width: width, height: height)
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}

extension UIImage {
    /// Merges two images, emulating the effect of a ZStack.
    ///
    /// The merged image is rendered at a scale of 1, so its pixel size matches its point size.
    nonisolated func mergeWith(topImage: UIImage) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let areaSize = CGRect(origin: .zero, size: size)
        
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            self.draw(in: areaSize)
            topImage.draw(in: areaSize, blendMode: .normal, alpha: 1.0)
        }
    }
    
    /// Fills a given image's pixels with a given color.
    /// - Parameter fillColor: The color to fill the image with.
    /// - Returns: The image tinted with the given color.
    nonisolated func tint(with fillColor: UIColor) -> UIImage? {
        let templateImage = withRenderingMode(.alwaysTemplate)
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = false
        
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            fillColor.set()
            templateImage.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    /// Scales the image to the given width, preserving its aspect ratio.
    ///
    /// The resized image is rendered at a scale of 1, so its pixel width matches `newWidth`.
    /// - Parameter newWidth: The width of the returned image.
    nonisolated func resized(toWidth newWidth: CGFloat) -> UIImage? {
        let scaleFactor = newWidth / size.width
        let newSize = CGSize(width: newWidth, height: size.height * scaleFactor)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        return UIGraphicsImageRenderer(size: newSize, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
