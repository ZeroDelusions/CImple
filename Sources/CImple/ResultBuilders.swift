import Foundation
import CoreImage

@resultBuilder
internal struct FilterBuilder {
    internal static func buildBlock(_ components: [CIFilter]...) -> [CIFilter] {
        components.flatMap { $0 }
    }
    
    internal static func buildExpression(_ expression: CIFilter) -> [CIFilter] {
        [expression]
    }
    
    internal static func buildExpression(_ expression: [CIFilter]) -> [CIFilter] {
        expression
    }
}
