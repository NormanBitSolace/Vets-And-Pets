import Foundation

protocol DataServiceTask {
    func run(_ dataService: DataService, completion: @escaping () -> ())
}

enum DataServiceTaskType {
    case get, post, put, delete
}

enum TaskAction<Model, Completion> {
    case add(Model, Completion?)
    case update(Model, Completion?)
    case delete(Model, Completion?)
}

class VetTask: DataServiceTask {
    let modelAction: TaskAction<VetModel, VetsCompletion>
    func run(_ dataService: DataService, completion: @escaping () -> ()) {
        switch modelAction {
        case let .add(model, dataCompletion):
            dataService.addVet(model) { _ in
                dataService.vets { models in
                    dataCompletion?(models)
                    completion()
                }
            }
        case let .update(model, dataCompletion):
            dataService.updateVet(model) { models in
                dataService.vets { models in
                    dataCompletion?(models)
                    completion()
                }
            }
        case let .delete(model, dataCompletion):
            dataService.deleteVet(model.id!) {
                dataService.vets { models in
                    dataCompletion?(models)
                    completion()
                }
            }
        }
    }
    func fetch(_ dataService: DataService, completion: @escaping ([VetModel]?) -> ()) {
        dataService.vets { models in
            completion(models)
        }
    }
    init(_ modelAction: TaskAction<VetModel, VetsCompletion>) {
        self.modelAction = modelAction
    }
}

class PetTask: DataServiceTask {
    let modelAction: TaskAction<PetModel, PetsCompletion>
    let vetId: Int
    func run(_ dataService: DataService, completion: @escaping () -> ()) {
        switch modelAction {
        case let .add(model, dataCompletion):
            dataService.addPet(model) { _ in
                dataService.pets(forVet: self.vetId) { models in
                    dataCompletion?(models)
                    completion()
                }
            }
        case let .update(model, dataCompletion):
            dataService.addPet(model) { models in
                dataService.pets(forVet: self.vetId) { models in
                    dataCompletion?(models)
                    completion()
                }
            }
        case let .delete(model, dataCompletion):
            dataService.deletePet(model.id!) {
                dataService.pets(forVet: self.vetId) { models in
                    dataCompletion?(models)
                    completion()
                }
            }
        }
    }
    init(_ modelAction: TaskAction<PetModel, PetsCompletion>, vetId: Int) {
        self.modelAction = modelAction
        self.vetId = vetId
    }
}
