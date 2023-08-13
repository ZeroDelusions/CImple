import Foundation
import SwiftUI

public protocol ImageConvertible {
    var ciImage: CIImage? { get }
}

extension CIImage: ImageConvertible {
    public var ciImage: CIImage? { return self }
}

extension UIImage: ImageConvertible {
    public var ciImage: CIImage? { return CIImage(image: self) }
}

@available(iOS 13.0, *)
extension Image: ImageConvertible {
    public var ciImage: CIImage? { return self.asCIImage() }
}

extension ImageConvertible {
    @available(iOS 13.0, *)
    public func processImage<T: ImageConvertible>( _ imageConvertible: T, @FilterBuilder _ filterClosure: @escaping () -> [CIFilter] ) -> ImageConvertible {
        
        let uiImg = CImple().CIApply(imageConvertible) {filterClosure()}
        
        if imageConvertible is UIImage {
            return uiImg!
        } else if imageConvertible is CIImage {
            return CIImage(image: uiImg!)!
        } else if imageConvertible is Image {
            return Image(uiImage: uiImg!)
        }
        
        return imageConvertible
        
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
extension View {
    
    public func asUIImage() -> UIImage? {
        let controller = UIHostingController(rootView: self)
        
        controller.view.backgroundColor = .clear
        
        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
        UIApplication.shared.windows.first?.rootViewController?.view.addSubview(controller.view)
        
        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.sizeToFit()
        
        guard let uiImage = controller.view.asUIImage() else {
            return nil
        }
        
        controller.view.removeFromSuperview()
        
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

@available(iOS 13.0, *)
extension CIFilter {
    func params(_ parameters: [String: Any]) -> Self {
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
            
        }
        
        return self
    }
}
