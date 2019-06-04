import Foundation

enum UserAction<ModelType, CompletionType> {
    case add(CompletionType)
    case update(ModelType, CompletionType)
    case delete(ModelType, CompletionType)

    var message: String {
        switch self {
        case .add:
            return "Adding"
        case .update:
            return "Updating"
        case .delete:
            return "Deleting"
        }
    }
}
