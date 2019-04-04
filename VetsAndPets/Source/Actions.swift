import Foundation

enum Action<T> {
    case list
    case add(T?)
    case update(T)
    case delete(T)
    case select(T)

    var message: String {
        switch self {
        case .list:
            return "Getting"
        case .add:
            return "Adding"
        case .update:
            return "Updating"
        case .delete:
            return "Deleting"
        case .select:
            return "Selecting"
        }
    }
}

struct ActionRequest<T> {
    let action: Action<T>
    let completion: ActionCompletion<T>?
}

typealias ActionCompletion<T> = ([T]?) -> Void
