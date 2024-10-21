import SwiftUI

/// Custom infix operators for image operations
infix operator =>: AdditionPrecedence
infix operator =>>: AdditionPrecedence
infix operator +: AdditionPrecedence
infix operator -: AdditionPrecedence
infix operator <+>: AdditionPrecedence
infix operator <->: AdditionPrecedence

/// Extension for applying various filters and compositing operations on image types.
@available(iOS 13.0, *)
extension ImageConvertible {

    /// Applies the given filters to the image.
    ///
    /// - Parameters:
    ///   - lhs: The source image to be filtered.
    ///   - rhs: A `FilterConvertible` object representing the filters to apply.
    /// - Returns: A new image with the filters applied.
    static public func =>(lhs: Self, rhs: FilterConvertible) -> Self {
        let filteredImage = CImple().applyFilters(lhs.ciImage, rhs.filters)
        guard let cgImage = CIContext(options: nil).createCGImage(filteredImage!, from: filteredImage!.extent) else {
            return UIImage(ciImage: lhs.ciImage!) as! Self
        }
        return UIImage(cgImage: cgImage) as! Self
    }

    /// Applies the given filters and ensures the result is returned in the appropriate image type.
    ///
    /// - Parameters:
    ///   - lhs: The source image to be filtered.
    ///   - rhs: A `FilterConvertible` object representing the filters to apply.
    /// - Returns: A new image with the filters applied, adjusted based on the type of the original image.
    static public func =>>(lhs: Self, rhs: FilterConvertible) -> Self {
        let filteredImage = CImple().applyFilters(lhs.ciImage, rhs.filters)
        guard let cgImage = CIContext(options: nil).createCGImage(filteredImage!, from: filteredImage!.extent) else {
            return lhs
        }
        
        if lhs is UIImage {
            return UIImage(cgImage: cgImage) as! Self
        } else if lhs is CIImage {
            return CIImage(cgImage: cgImage) as! Self
        } else if lhs is Image {
            return Image(uiImage: UIImage(cgImage: cgImage)) as! Self
        }
        
        return lhs
    }

    /// Combines two images by using a source-over compositing filter.
    ///
    /// - Parameters:
    ///   - lhs: The background image.
    ///   - rhs: The foreground image.
    /// - Returns: A new image where the `rhs` image is composited over the `lhs` image.
    static public func +(lhs: Self, rhs: Self) -> UIImage {
        return applyCompositing(lhs.ciImage, rhs.ciImage, filter: CIFilter.sourceOverCompositing())
    }

    /// Combines two images by using a source-out compositing filter.
    ///
    /// - Parameters:
    ///   - lhs: The background image.
    ///   - rhs: The foreground image.
    /// - Returns: A new image where the `rhs` image is subtracted from the `lhs` image.
    static public func -(lhs: Self, rhs: Self) -> UIImage {
        return applyCompositing(lhs.ciImage, rhs.ciImage, filter: CIFilter.sourceOutCompositing())
    }

    /// Combines two images by using a source-atop compositing filter.
    ///
    /// - Parameters:
    ///   - lhs: The background image.
    ///   - rhs: The foreground image.
    /// - Returns: A new image where the `rhs` image is composited atop the `lhs` image.
    static public func <+>(lhs: Self, rhs: Self) -> UIImage {
        return applyCompositing(lhs.ciImage, rhs.ciImage, filter: CIFilter.sourceAtopCompositing())
    }

    /// Combines two images by using a source-in compositing filter.
    ///
    /// - Parameters:
    ///   - lhs: The background image.
    ///   - rhs: The foreground image.
    /// - Returns: A new image where only the overlapping regions of the `lhs` and `rhs` images are kept.
    static public func <->(lhs: Self, rhs: Self) -> UIImage {
        return applyCompositing(lhs.ciImage, rhs.ciImage, filter: CIFilter.sourceInCompositing())
    }

    /// Applies a compositing filter to combine two images.
    ///
    /// - Parameters:
    ///   - background: The background image as a `CIImage`.
    ///   - input: The input image as a `CIImage`.
    ///   - filter: A `CIFilter` object to apply for compositing the images.
    /// - Returns: A `UIImage` object representing the composited image.
    static private func applyCompositing(_ background: CIImage?, _ input: CIImage?, filter: CIFilter) -> UIImage {
        filter.setValue(background, forKey: kCIInputBackgroundImageKey)
        filter.setValue(input, forKeyPath: kCIInputImageKey)
        guard let filterOutput = filter.outputImage else { return UIImage(ciImage: background!) }
        
        guard let cgImage = CIContext(options: nil).createCGImage(filterOutput, from: filterOutput.extent) else {
            return UIImage(ciImage: background!)
        }
        return UIImage(cgImage: cgImage)
    }
}
