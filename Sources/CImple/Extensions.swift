import Foundation
import SwiftUI

public protocol ImageConvertible {
    var ciImage: CIImage? { get }
}

public protocol FilterConvertible {
    var filters: [CIFilter] { get }
}

extension CIImage: ImageConvertible {
    public var ciImage: CIImage? { return self }
}

extension UIImage: ImageConvertible {
    public var ciImage: CIImage? { return CIImage(image: self) }
}

extension CIFilter: FilterConvertible {
    public var filters: [CIFilter] { return [self] }
}

extension Array: FilterConvertible where Element == CIFilter {
    public var filters: [CIFilter] { return self }
}

@available(iOS 13.0, *)
extension Image: ImageConvertible {
    public var ciImage: CIImage? { return self.asCIImage() }
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
extension ImageConvertible {
    public func CIApply(_ input: ImageConvertible? = nil, @FilterBuilder _ instructions: () throws -> Any?) rethrows -> UIImage? {
        do {
            let result = try instructions()

            let filteredImage: CIImage = try {
                if let filters = result as? [CIFilter] {
                    if filters.isEmpty {
                        throw FilterError.missingReturn
                    }
                    guard let appliedImage = CImple().applyFilters(input?.ciImage, filters: filters) else {
                        throw FilterError.missingInput
                    }
                    return appliedImage
                } else if let ciImage = result as? CIImage {
                    if input != nil {
                        print("Caution: The input within FilterKit() is disregarded when using chaining syntax.")
                    }
                    return ciImage
                } else if result == nil {
                    throw FilterError.missingFilterInput
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
            return ErrorView(errorMessage: errorDescription).asUIImage()
        } catch {
            print("\(error): Unknown error")
            return nil
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
