import Foundation
import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

public typealias FilterClosure = () -> [CIFilter]

@available(iOS 13.0, *)
public struct CImple {

    public init() { }

    public func filters(_ input: ImageConvertible? = nil, @FilterBuilder _ instructions: () throws -> Any?) rethrows -> UIImage {
        do {
            let result = try instructions()

            let filteredImage: CIImage = try {
                if let filters = result as? [CIFilter] {
                    guard let appliedImage = applyFilters(input?.ciImage, filters) else {
                        throw FilterError.missingInput
                    }
                    if filters.isEmpty {
                        throw FilterError.missingReturn
                    }
                    return appliedImage
                } else if let ciImage = result as? CIImage {
                    if input != nil {
                        print("Caution: The input within FilterKit() is disregarded when using chaining syntax.")
                    }
                    return ciImage
//                }
//                else if result == nil {
//                    throw FilterError.missingFilterInput
                } else {
                    throw FilterError.unknownError
                }
            }()

            guard let cgImage = CIContext(options: nil).createCGImage(filteredImage, from: filteredImage.extent) else {
                throw FilterError.renderingError
            }

            return UIImage(cgImage: cgImage)
            
        } catch let error as FilterError {
            let errorDescription = "Error: \(error.description)"
            print(errorDescription)
            return ErrorView(errorMessage: errorDescription).asUIImage()!
        } catch {
            print("\(error): Unknown error")
            return UIImage()
        }
    }

    public func chain( _ input: ImageConvertible? = nil, @FilterBuilder _ filterClosure: FilterClosure ) -> CIImage? {
        let filters = filterClosure()
        let effectiveInput = input ?? filters.compactMap { $0.outputImage }.first
        return applyFilters(effectiveInput?.ciImage, filters)
    }

    func convertToCIImage( _ input: Any? ) throws -> CIImage? {
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

    internal func applyFilters( _ input: CIImage?, _ filters: [CIFilter]) -> CIImage? {
        
        var filteredImage = input

        for filter in filters {
            
            if filter.value(forKey: kCIInputImageKey) == nil {
                filter.setValue(filteredImage, forKey: kCIInputImageKey)
            }
            
            if let outputImage = filter.outputImage {
                filteredImage = outputImage
            }
        }

        if let output = filteredImage {
            return output
        } else {
            return nil
        }
        
    }
}
