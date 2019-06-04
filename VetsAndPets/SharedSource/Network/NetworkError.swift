import Foundation

enum NetworkError: Error {
    case noDataError
    case unknownError
    case messageError(String)
}

protocol NetworkObserver {
    func setModels<T>(_ models: [T]?)
}
