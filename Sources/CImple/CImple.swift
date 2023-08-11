import Foundation
import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

@available(iOS 13.0, *)
public struct CImple {

    public init() { }
    
    public typealias FilterClosure = () -> [CIFilter]

    

    public func chain( _ input: ImageConvertible? = nil, @FilterBuilder _ filterClosure: FilterClosure ) -> CIImage? {
        let filters = filterClosure()
        return applyFilters(input?.ciImage, filters: filters)
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

    internal func applyFilters( _ input: CIImage?, filters: [CIFilter]) -> CIImage? {
        
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
