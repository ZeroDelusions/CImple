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
}
