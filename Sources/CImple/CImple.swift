import Foundation
import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

/// A closure that returns an array of `CIFilters`.
public typealias FilterClosure = () -> [CIFilter]

/// A struct that simplifies the application of `Core Image` filters to images.
@available(iOS 13.0, *)
public struct CImple {
    
    /// The `Core Image` context used for rendering.
    private let context = CIContext(options: nil)
    
    /// Initializes a new `CImple` instance.
    public init() { }
    
    /// Applies filters to an image.
    /// - Parameters:
    ///   - input: An optional input image. If nil, the input image should be provided within the filters.
    ///   - instructions: A closure that returns the filters to be applied.
    /// - Returns: A `UIImage` with the filters applied.
    public func filters(_ input: ImageConvertible? = nil, _ instructions: () throws -> Any?) -> UIImage {
        do {
            let result = try instructions()
            let filteredImage: CIImage = try processFilters(input: input, result: result)
            return try renderImage(filteredImage, input: input)
        } catch {
            return handleError(error)
        }
    }
    
    // TODO: Use type-safe implementation instead of Any in the input
    
    /// Processes filters accounting for nested `.chain()` funcitons. Provides contextual errors.
    /// - Parameters:
    ///   - input: Optional input passed to override result
    ///   - result: `CIImage` or `[CIFIlter]`
    /// - Returns: `CIImage`
    private func processFilters(input: ImageConvertible?, result: Any?) throws -> CIImage {
        switch result {
        case let filters as [CIFilter]:
            guard let appliedImage = applyFilters(input?.ciImage, filters) else {
                throw FilterError.missingInput
            }
            return appliedImage
        case let ciImage as CIImage:
            return ciImage
        case nil:
            guard let inputImage = input?.ciImage else {
                throw FilterError.missingFilterInput
            }
            return inputImage
        default:
            throw FilterError.unknownError
        }
    }
    
    
    /// Renders `CIImage` to `UIImage`, optionaly using original Image metadata
    /// - Parameters:
    ///   - filteredImage: `CIImage` with applied `CIFIlters`
    ///   - input: Original, unfiltered image of type` ImageConvertible`
    /// - Returns: `UIImage` with applied filters
    private func renderImage(_ filteredImage: CIImage, input: ImageConvertible?) throws -> UIImage {
        guard let cgImage = context.createCGImage(filteredImage, from: filteredImage.extent) else {
            throw FilterError.renderingError
        }
        return UIImage(cgImage: cgImage, scale: (input?.uiImage?.scale) ?? 1.0, orientation: (input?.uiImage?.imageOrientation) ?? .up)
    }
    
    private func handleError(_ error: Error) -> UIImage {
        let errorDescription = "Error: \(error.localizedDescription)"
        print(errorDescription)
        return ErrorView(errorMessage: errorDescription).asUIImage() ?? UIImage()
    }
    
    public func chain(_ input: ImageConvertible? = nil, @FilterBuilder _ filterClosure: FilterClosure) -> CIImage? {
        let filters = filterClosure()
        return applyFilters(input?.ciImage, filters)
    }
    
    // TODO: Use type-safe implementation instead of Any in the input
    
    /// Converts input to `CIImage`
    /// - Parameter input: `Image` / `UIImage` / `CIImage` / `View`
    /// - Returns: `CIImage`
    func convertToCIImage(_ input: Any?) throws -> CIImage? {
        if let unwrappedInput = input {
            if let inputCIImage = unwrappedInput as? CIImage {
                return inputCIImage
            } else if let inputUIImage = unwrappedInput as? UIImage, let inputCIImage = CIImage(image: inputUIImage) {
                return inputCIImage
            } else if let inputImage = (unwrappedInput as? Image)?.asCIImage() {
                return inputImage
            } else if let inputView = (unwrappedInput as? (any View))?.asCIImage() {
                return inputView
            } else {
                throw FilterError.wrongInputType
            }
        } else {
            return nil
        }
    }

    /// Applies filters to input or, if present, image passed in `kCIInputImageKey`
    /// - Parameters:
    ///   - input: `CIImage`
    ///   - filters: `[CIFilter]`
    /// - Returns: Optional `CIImage`
    internal func applyFilters(_ input: CIImage?, _ filters: [CIFilter]) -> CIImage? {
        var filteredImage = input
        
        for filter in filters {
            if filter.value(forKey: kCIInputImageKey) == nil {
                filter.setValue(filteredImage, forKey: kCIInputImageKey)
            }
            
            if let outputImage = filter.outputImage {
                filteredImage = outputImage
            }
        }
        
        return filteredImage
    }
}
