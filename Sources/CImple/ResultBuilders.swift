import Foundation
import CoreImage

@resultBuilder
public struct FilterBuilder {
    public static func buildBlock(_ components: [CIFilter]...) -> [CIFilter] {
        components.flatMap { $0 }
    }
    
    public static func buildExpression(_ expression: CIFilter) -> [CIFilter] {
        [expression]
    }
    
    public static func buildExpression(_ expression: [CIFilter]) -> [CIFilter] {
        expression
    }
    
    public static func buildOptional(_ component: [CIFilter]?) -> [CIFilter] {
        component ?? []
    }
    
    public static func buildEither(first component: [CIFilter]) -> [CIFilter] {
        component
    }
    
    public static func buildEither(second component: [CIFilter]) -> [CIFilter] {
        component
    }
    
    public static func buildArray(_ components: [[CIFilter]]) -> [CIFilter] {
        components.flatMap { $0 }
    }
}
