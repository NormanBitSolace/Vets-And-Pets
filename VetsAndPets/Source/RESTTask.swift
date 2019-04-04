import Foundation

protocol Task {
    var message: String { get }
    func run(completion: @escaping () -> ())
}

/// Given a model T, perform a REST service (i.e. GET, POST, PUT, or DELETE) and return with an updated list of model T.
class RESTTask<T>: Task {
    let message: String
    let returnDataFunc: ([T]?) -> ()
    let dataService: DataService
    let model: T?

    init(dataService: DataService, model: T, message: String, completion: @escaping ([T]?) -> ()) {
        self.dataService = dataService
        self.model = model
        self.message = message
        returnDataFunc = completion
    }
    init(dataService: DataService, message: String, completion: @escaping ([T]?) -> ()) {
        self.dataService = dataService
        self.model = nil
        self.message = message
        returnDataFunc = completion
    }
    func run(completion: @escaping () -> ()) {
        preconditionFailure("Must be overriden.")
    }
}

final class ListVetsTask: RESTTask<VetModel> {
    override func run(completion: @escaping () -> ()) {
        dataService.vets { models in
            self.returnDataFunc(models)
            completion()
        }
    }
}

final class CreateVetTask: RESTTask<VetModel> {
    override func run(completion: @escaping () -> ()) {
        guard let model = model else { completion(); return }
        dataService.addVet(model) { models in
            self.dataService.vets { models in
                self.returnDataFunc(models)
                completion()
            }
        }
    }
}

final class DeleteVetTask: RESTTask<VetModel> {
    override func run(completion: @escaping () -> ()) {
        guard let model = model,
            let id = model.id else { completion(); return }
        dataService.deleteVet(id) {
            self.dataService.vets { models in
                self.returnDataFunc(models)
                completion()
            }
        }
    }
}

final class UpdateVetTask: RESTTask<VetModel> {
    override func run(completion: @escaping () -> ()) {
        guard let model = model else { completion(); return }
        dataService.updateVet(model) { models in
            self.dataService.vets { models in
                self.returnDataFunc(models)
                completion()
            }
        }
    }
}

class PetsTask: RESTTask<PetModel> {
    let vetId: Int

    init(dataService: DataService, vetId: Int, model: PetModel, message: String, completion: @escaping ([PetModel]?) -> ()) {
        self.vetId = vetId
        super.init(dataService: dataService, model: model, message: message, completion: completion)
    }
    init(dataService: DataService, vetId: Int, message: String, completion: @escaping ([PetModel]?) -> ()) {
        self.vetId = vetId
        super.init(dataService: dataService, message: message, completion: completion)
    }
}

final class ListPetsTask: PetsTask {

    override func run(completion: @escaping () -> ()) {
        dataService.pets(forVet: vetId) { models in
            self.returnDataFunc(models)
            completion()
        }
    }
}

final class CreatePetTask: PetsTask {
    override func run(completion: @escaping () -> ()) {
        guard let model = model else { completion(); return }
        dataService.addPet(model) { _ in
            self.dataService.pets(forVet: self.vetId) { models in
                self.returnDataFunc(models)
                completion()
            }
        }
    }
}

final class DeletePetTask: PetsTask {
    override func run(completion: @escaping () -> ()) {
        guard let model = model,
            let id = model.id else { completion(); return }
        dataService.deletePet(id) {
            self.dataService.pets(forVet: self.vetId) { models in
                self.returnDataFunc(models)
                completion()
            }
        }
    }
}

final class UpdatePetTask: PetsTask {
    override func run(completion: @escaping () -> ()) {
        guard let model = model else { completion(); return }
        dataService.updatePet(model) { _ in
            self.dataService.pets(forVet: self.vetId) { models in
                self.returnDataFunc(models)
                completion()
            }
        }
    }
}
