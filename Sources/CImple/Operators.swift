import SwiftUI


infix operator =>: AdditionPrecedence
infix operator =>>: AdditionPrecedence
infix operator +: AdditionPrecedence
infix operator -: AdditionPrecedence
infix operator <+>: AdditionPrecedence
infix operator <->: AdditionPrecedence

@available(iOS 13.0, *)
extension ImageConvertible {
    
    static public func =>(lhs: Self, rhs: FilterConvertible) -> Self {
        
        let filteredImage = CImple().applyFilters(lhs.ciImage, rhs.filters)
        guard let cgImage = CIContext(options: nil).createCGImage(filteredImage!, from: filteredImage!.extent) else {
            return UIImage(ciImage: lhs.ciImage!) as! Self
        }
        return UIImage(cgImage: cgImage) as! Self
        
    }

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

    static public func +(lhs: Self, rhs: Self) -> UIImage {
        return applyCompositing(lhs.ciImage, rhs.ciImage, filter: CIFilter.sourceOverCompositing())
    }

    static public func -(lhs: Self, rhs: Self) -> UIImage {
        return applyCompositing(lhs.ciImage, rhs.ciImage, filter: CIFilter.sourceOutCompositing())
    }

    static public func <+>(lhs: Self, rhs: Self) -> UIImage {
        return applyCompositing(lhs.ciImage, rhs.ciImage, filter: CIFilter.sourceAtopCompositing())
    }

    static public func <->(lhs: Self, rhs: Self) -> UIImage {
        return applyCompositing(lhs.ciImage, rhs.ciImage, filter: CIFilter.sourceInCompositing())
    }

    static private func applyCompositing( _ background: CIImage?, _ input: CIImage?, filter: CIFilter ) -> UIImage {
        
        filter.setValue(background, forKey: kCIInputBackgroundImageKey)
        filter.setValue(input, forKeyPath: kCIInputImageKey)
        guard let filterOutput = filter.outputImage else { return UIImage(ciImage: background!) }
        
        guard let cgImage = CIContext(options: nil).createCGImage(filterOutput, from: filterOutput.extent) else {
            return UIImage(ciImage: background!)
        }
        return UIImage(cgImage: cgImage)
    }
}
