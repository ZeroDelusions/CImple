import Foundation
import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

public typealias FilterClosure = () -> [CIFilter]

@available(iOS 13.0, *)
public struct CImple {
    
    public init() { }
    
    private let context = CIContext(options: nil)
    
    public func filters(_ input: ImageConvertible? = nil, @FilterBuilder _ instructions: () throws -> Any?) -> UIImage {
        do {
            let result = try instructions()
            let filteredImage: CIImage = try processFilters(input: input, result: result)
            return try renderImage(filteredImage, input: input)
        } catch {
            return handleError(error)
        }
    }
    
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
