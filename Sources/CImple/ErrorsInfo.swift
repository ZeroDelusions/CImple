import SwiftUI

enum FilterError: Error {
    case wrongInputType
    case missingInput
    case missingReturn
    case missingFilterInput
    case renderingError
    case unknownError
    
    var description: String {
        switch self {
        case .wrongInputType:
            return "Incorrect input type. Acceptable input types include: Image, UIImage, CIImage, and View."
        case .missingInput:
            return "Missing input parameter. Please provide the required input when initializing FilterKit."
        case .missingFilterInput:
            return "Missing input parameter in chaining. Please provide input as a parameter in the chain function, or as a value for the 'kCIInputImageKey'."
        case .missingReturn:
            return "Missing return value. Ensure you return an image when using the chaining syntax."
        case .renderingError:
            return "Error while applying CIFilters"
        case .unknownError:
            return "An unknown error occurred. Please review your code for any syntax errors and refer to the official documentation for guidance."
        }
    }
}

@available(iOS 13.0, *)
internal struct ErrorView: View {
    
    var errorMessage: String
    
    var body: some View {
        VStack {
            Image(systemName: "xmark.circle")
                .font(.system(size: UIScreen.main.bounds.width / 2))
                .foregroundColor(.red)
            Text(errorMessage)
        }
    }
}
