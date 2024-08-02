import Foundation
import SwiftUI

public protocol ImageConvertible {
    var ciImage: CIImage? { get }
    var uiImage: UIImage? { get }
}

@available(iOS 13.0, *)
extension CIImage: ImageConvertible {
    public var ciImage: CIImage? { return self }
    public var uiImage: UIImage? { return UIImage(ciImage: self) }
    
    public func filters( _ input: ImageConvertible? = nil, @FilterBuilder _ filterClosure: () -> Any? ) -> CIImage? {
        
        let uiImg = CImple().filters(input ?? self, filterClosure)
        
        return CIImage(image: uiImg)
    }
    public func chain( _ input: ImageConvertible? = nil, @FilterBuilder _ filterClosure: FilterClosure ) -> CIImage? {
        let filters = filterClosure()
        return CImple().applyFilters(input?.ciImage ?? self, filters)
    }
}

@available(iOS 13.0, *)
extension UIImage: ImageConvertible {
    public var ciImage: CIImage? { return CIImage(image: self) }
    public var uiImage: UIImage? { return self }
    
    public func filters( _ input: ImageConvertible? = nil, @FilterBuilder _ filterClosure: () -> Any? ) -> UIImage? {
        
        let uiImg = CImple().filters(input ?? self, filterClosure)
        
        return uiImg
    }
    public func chain( _ input: ImageConvertible? = nil, @FilterBuilder _ filterClosure: FilterClosure ) -> CIImage? {
        let filters = filterClosure()
        return CImple().applyFilters(input?.ciImage ?? self.ciImage, filters)
    }
}

@available(iOS 15.0, *)
extension Image: ImageConvertible {
    public var ciImage: CIImage? { return self.asCIImage() }
    public var uiImage: UIImage? { return self.asUIImage() }
    
    public func filters(_ input: ImageConvertible? = nil, @FilterBuilder _ filterClosure: @escaping () -> Any?) -> some View {
        FilteredImageView(content: { self }, filterClosure: filterClosure)
    }
    public func chain( _ input: ImageConvertible? = nil, @FilterBuilder _ filterClosure: FilterClosure ) -> CIImage? {
        let filters = filterClosure()
        return CImple().applyFilters(input?.ciImage ?? self.ciImage, filters)
    }
}

@available(iOS 14.0, *)
extension View {
    public var ciImage: CIImage? { return self.asCIImage() }
    
    public func filters(_ input: ImageConvertible? = nil, @FilterBuilder _ filterClosure: @escaping () -> Any?) -> some View {
        FilteredImageView(content: { self }, filterClosure: filterClosure)
    }
    
    public func chain( _ input: ImageConvertible? = nil, @FilterBuilder _ filterClosure: FilterClosure ) -> CIImage? {
        let filters = filterClosure()
        return CImple().applyFilters(input?.ciImage ?? self.ciImage, filters)
    }
}

public protocol FilterConvertible {
    var filters: [CIFilter] { get }
}

extension CIFilter: FilterConvertible {
    public var filters: [CIFilter] { return [self] }
}

extension Array: FilterConvertible where Element == CIFilter {
    public var filters: [CIFilter] { return self }
}

@available(iOS 13.0, *)
extension CIFilter {
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
    func snapshot(size: CGSize? = nil) -> UIImage? {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let targetSize = size ?? controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

@available(iOS 13.0, *)
extension View {
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
    
    public func asCIImage() -> CIImage? {
        if let uiImage = asUIImage() {
            return CIImage(image: uiImage)
        }
        return nil
    }
}

extension UIView {
    public func asUIImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
