import Foundation

struct TaskBuilder {
//
//    static func build(_ dataService: DataService, _ request: ActionRequest<PetModel>, _ model: PetModel? = nil, vetId: Int) -> Task {
//        guard let completion = request.completion else { preconditionFailure("Completion routine expected.") }
//        switch request.action {
//        case .list:
//            return ListPetsTask(dataService: dataService, vetId: vetId, message: "\(request.action.message) Pets", completion: completion)
//        case .add:
//            return CreatePetTask(dataService: dataService, vetId: vetId, model: model!, message: "\(request.action.message) Pet", completion: completion)
//        case .update(_):
//            return UpdatePetTask(dataService: dataService, vetId: vetId, model: model!, message: "\(request.action.message) Pets", completion: completion)
//        case .delete(_):
//            return DeletePetTask(dataService: dataService, vetId: vetId, model: model!, message: "\(request.action.message) Pet", completion: completion)
//        case .select(_):
//            preconditionFailure("No associated Task for .select.")
//        }
//    }
}
