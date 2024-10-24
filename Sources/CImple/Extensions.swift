import Foundation
import SwiftUI

// MARK: - Protocols

/// A protocol for types that can be converted to `CIImage` and `UIImage`.
public protocol ImageConvertible {
    var ciImage: CIImage? { get }
    var uiImage: UIImage? { get }
}

/// A protocol for types that can be converted to `CIFilters`.
public protocol FilterConvertible {
    var filters: [CIFilter] { get }
}

// MARK: - Extensions

extension CIFilter: FilterConvertible {
    public var filters: [CIFilter] { return [self] }
}

extension Array: FilterConvertible where Element == CIFilter {
    public var filters: [CIFilter] { return self }
}

@available(iOS 13.0, macOS 10.15, *)
extension CIImage: ImageConvertible {
    public var ciImage: CIImage? { return self }
    public var uiImage: UIImage? { return UIImage(ciImage: self) }
    
    /// Applies filters to the `CIImage`.
    /// - Parameters:
    ///   - input: An optional input image. If `nil`, self is used.
    ///   - filterClosure: A closure that returns the filters to be applied.
    /// - Returns: A new `CIImage` with the filters applied.
    public func filters(_ input: ImageConvertible? = nil, @FilterBuilder _ filterClosure: () -> Any?) -> CIImage? {
        let uiImg = CImple().filters(input ?? self, filterClosure)
        return CIImage(image: uiImg)
    }
    
    /// Chains filters to the `CIImage`.
    /// - Parameters:
    ///   - input: An optional input image. If `nil`, `self` is used.
    ///   - filterClosure: A closure that returns the filters to be applied.
    /// - Returns: A new `CIImage` with the filters applied.
    public func chain(_ input: ImageConvertible? = nil, @FilterBuilder _ filterClosure: FilterClosure) -> CIImage? {
        let filters = filterClosure()
        return CImple().applyFilters(input?.ciImage ?? self, filters)
    }
}


@available(iOS 13.0, *)
extension UIImage: ImageConvertible {
    public var ciImage: CIImage? { return CIImage(image: self) }
    public var uiImage: UIImage? { return self }
    
    
    /// Applies filters to the `UIImage`.
    /// - Parameters:
    ///   - input: An optional input image. If `nil`, `self` is used.
    ///   - filterClosure: A closure that returns the filters to be applied.
    /// - Returns: A new `UIImage` with the filters applied.
    public func filters(_ input: ImageConvertible? = nil, @FilterBuilder _ filterClosure: () -> Any?) -> UIImage? {
        let uiImg = CImple().filters(input ?? self, filterClosure)
        return uiImg
    }
    
    /// Chains filters to the `UIImage`.
    /// - Parameters:
    ///   - input: An optional input image. If `nil`, `self` is used.
    ///   - filterClosure: A closure that returns the filters to be applied.
    /// - Returns: A new `CIImage` with the filters applied.
    public func chain(_ input: ImageConvertible? = nil, @FilterBuilder _ filterClosure: FilterClosure) -> CIImage? {
        let filters = filterClosure()
        return CImple().applyFilters(input?.ciImage ?? self.ciImage, filters)
    }
}

@available(iOS 14.0, *)
extension Image: ImageConvertible {
    public var ciImage: CIImage? { return self.asCIImage() }
    public var uiImage: UIImage? { return self.asUIImage() }
    
    /// Chains filters to the `Image`.
    /// - Parameters:
    ///   - input: An optional input image. If `nil`, `self` is used.
    ///   - filterClosure: A closure that returns the filters to be applied.
    /// - Returns: A new `View` containing `Image` with the filters applied.
    public func filters(_ input: ImageConvertible? = nil, @FilterBuilder _ filterClosure: @escaping () -> Any?) -> some View {
        FilteredImageView(content: { self }, filterClosure: filterClosure)
    }
    
    /// Chains filters to the `Image`.
    /// - Parameters:
    ///   - input: An optional input image. If `nil`, `self` is used.
    ///   - filterClosure: A closure that returns the filters to be applied.
    /// - Returns: A new `CIImage` with the filters applied.
    public func chain( _ input: ImageConvertible? = nil, @FilterBuilder _ filterClosure: FilterClosure ) -> CIImage? {
        let filters = filterClosure()
        return CImple().applyFilters(input?.ciImage ?? self.ciImage, filters)
    }
}

@available(iOS 14.0, *)
extension View {
    public var ciImage: CIImage? { return self.asCIImage() }
    
    /// Chains filters to the `View`.
    /// - Parameters:
    ///   - input: An optional input image. If `nil`, `self` is used.
    ///   - filterClosure: A closure that returns the filters to be applied.
    /// - Returns: A new `View` containing Image with the filters applied.
    public func filters(_ input: ImageConvertible? = nil, @FilterBuilder _ filterClosure: @escaping () -> Any?) -> some View {
        FilteredImageView(content: { self }, filterClosure: filterClosure)
    }
    
    /// Chains filters to the `Image`.
    /// - Parameters:
    ///   - input: An optional input image. If `nil`, `self` is used.
    ///   - filterClosure: A closure that returns the filters to be applied.
    /// - Returns: A new `CIImage` with the filters applied.
    public func chain( _ input: ImageConvertible? = nil, @FilterBuilder _ filterClosure: FilterClosure ) -> CIImage? {
        let filters = filterClosure()
        return CImple().applyFilters(input?.ciImage ?? self.ciImage, filters)
    }
}

@available(iOS 13.0, *)
extension CIFilter {
    /// Sets multiple parameters for the filter.
    /// - Parameter parameters: A dictionary of parameter keys and values.
    /// - Returns: The filter with the parameters applied.
    public func params(_ parameters: [String: Any]) -> Self {
        do {
            for (key, value) in parameters {
                if key == kCIInputImageKey {
                    if let ciImage = try CImple().convertToCIImage(value) {
                        setValue(ciImage, forKey: key)
                    } else {
                        throw FilterError.renderingError
                    }
                } else {
                    setValue(value, forKey: key)
                }
            }
        } catch {
            return self
        }
        
        return self
    }
}

@available(iOS 13.0, *)
extension View {
    
    /// Creates `UIImage` representation of a `View`
    /// - Returns: Optional `UIImage` representation of a `View`
    public func asUIImage() -> UIImage? {
        let semaphore = DispatchSemaphore(value: 0)
        var uiImage: UIImage?
        
        DispatchQueue.main.async {
            let controller = UIHostingController(rootView: self)
            let view = controller.view
            
            let targetSize = controller.view.intrinsicContentSize
            view?.bounds = CGRect(origin: .zero, size: targetSize)
            view?.backgroundColor = .clear
            
            let renderer = UIGraphicsImageRenderer(size: targetSize)
            
            uiImage = renderer.image { _ in
                view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
            }
            
            semaphore.signal()
        }
        
        semaphore.wait()
        return uiImage
    }
    
    
    /// Creates `CIImage` representation of a `View`
    /// - Returns: Optional `CIImage` representation of a `View`
    public func asCIImage() -> CIImage? {
        if let uiImage = asUIImage() {
            return CIImage(image: uiImage)
        }
        return nil
    }
}

extension UIView {
    /// Creates `UIImage` representation of a `UIView`
    /// - Returns: Optional `UIImage` representation of a `UIView`
    public func asUIImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
