import SwiftUI


infix operator =>: AdditionPrecedence
infix operator =>>: AdditionPrecedence
infix operator +: AdditionPrecedence
infix operator -: AdditionPrecedence
infix operator ++: AdditionPrecedence
infix operator --: AdditionPrecedence

@available(iOS 13.0, *)
public func =>(lhs: ImageConvertible, rhs: FilterConvertible) -> UIImage {
    
    let filteredImage = CImple().applyFilters(lhs.ciImage, filters: rhs.filters)
    guard let cgImage = CIContext(options: nil).createCGImage(filteredImage!, from: filteredImage!.extent) else {
        return UIImage(ciImage: lhs.ciImage!)
    }
    return UIImage(cgImage: cgImage)
    
}

@available(iOS 13.0, *)
public func =>>(lhs: ImageConvertible, rhs: FilterConvertible) -> ImageConvertible {
    
    let filteredImage = CImple().applyFilters(lhs.ciImage, filters: rhs.filters)
    guard let cgImage = CIContext(options: nil).createCGImage(filteredImage!, from: filteredImage!.extent) else {
        return lhs
    }
    
    if lhs is UIImage {
        return UIImage(cgImage: cgImage)
    } else if lhs is CIImage {
        return CIImage(cgImage: cgImage)
    } else if lhs is Image {
        return Image(uiImage: UIImage(cgImage: cgImage))
    }
    
    return lhs
    
}

@available(iOS 13.0, *)
public func +(lhs: ImageConvertible, rhs: ImageConvertible) -> UIImage {
    return applyCompositing(lhs.ciImage, rhs.ciImage, filter: CIFilter.sourceOverCompositing())
}

@available(iOS 13.0, *)
public func -(lhs: ImageConvertible, rhs: ImageConvertible) -> UIImage {
    return applyCompositing(lhs.ciImage, rhs.ciImage, filter: CIFilter.sourceOutCompositing())
}

@available(iOS 13.0, *)
public func ++(lhs: ImageConvertible, rhs: ImageConvertible) -> UIImage {
    return applyCompositing(lhs.ciImage, rhs.ciImage, filter: CIFilter.sourceAtopCompositing())
}

@available(iOS 13.0, *)
public func --(lhs: ImageConvertible, rhs: ImageConvertible) -> UIImage {
    return applyCompositing(lhs.ciImage, rhs.ciImage, filter: CIFilter.sourceInCompositing())
}

private func applyCompositing(_ background: ImageConvertible?, _ input: ImageConvertible?, filter: CIFilter) -> UIImage {
    
    filter.setValue(background, forKey: kCIInputBackgroundImageKey)
    filter.setValue(input, forKeyPath: kCIInputImageKey)
    guard let filterOutput = filter.outputImage else { return UIImage(ciImage: (background?.ciImage)!) }
    
    guard let cgImage = CIContext(options: nil).createCGImage(filterOutput, from: filterOutput.extent) else {
        return UIImage(ciImage: (background?.ciImage)!)
    }
    return UIImage(cgImage: cgImage)
}
