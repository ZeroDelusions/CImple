import Foundation
import CoreImage

@resultBuilder
struct FilterBuilder {
    static func buildBlock(_ components: [CIFilter]...) -> [CIFilter] {
        components.flatMap { $0 }
    }
    
    static func buildExpression(_ expression: CIFilter) -> [CIFilter] {
        [expression]
    }
    
    static func buildExpression(_ expression: [CIFilter]) -> [CIFilter] {
        expression
    }
}
