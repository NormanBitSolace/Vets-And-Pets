import Foundation

class PetService: DataService, RestHelper {

    let base = "https://voice-frosty-19170.v2.vapor.cloud/api"
//    let base = "https://wildflower-hidden-35037.v2.vapor.cloud/api"

    private func petUrl(_ id: Int? = nil) -> URL {
        return URL(base, ("pets", id))
    }

    private func petOwnerUrl(_ id: Int? = nil) -> URL {
        return URL(base, ("petowners", id))
    }

    private func vetUrl(_ id: Int? = nil) -> URL {
        return URL(base, ("practitioners", id))
    }

    func addPet(_ model: PetModel, completion: @escaping (PetModel?) -> Void) {
        post(model: model, url: petUrl()) { model in
            DispatchQueue.main.async { completion(model) }
        }
    }

    func updatePet(_ model: PetModel, completion: @escaping (PetModel?) -> Void) {
        put(model: model, url: petUrl(model.id)) { model in
            DispatchQueue.main.async { completion(model) }
        }
    }

    func deletePet(_ id: Int, completion: @escaping () -> Void) {
        delete(url: petUrl(id)) {
            completion()
        }
    }

    func pet(id: Int, completion: @escaping (PetModel?) -> Void) {
        get(type: PetModel.self, url: petUrl(id)) { model in
            DispatchQueue.main.async { completion(model) }
        }
    }

    func pets(forVet vetId: Int, completion: @escaping ([PetModel]?) -> Void) {
        let url = URL(base, RestPath("practitioners", vetId), RestPath("pets", nil))
        get(type: [PetModel].self, url: url) { model in
            DispatchQueue.main.async { completion(model) }

        }
    }
    func pets(completion: @escaping ([PetModel]?) -> Void) {
        get(type: [PetModel].self, url: petUrl()) { model in
            DispatchQueue.main.async { completion(model) }

        }
    }

    func addVet(_ model: VetModel, completion: @escaping (VetModel?) -> Void) {
        post(model: model, url: vetUrl()) { model in
            DispatchQueue.main.async { completion(model) }
        }
    }

    func updateVet(_ model: VetModel, completion: @escaping (VetModel?) -> Void) {
        put(model: model, url: vetUrl(model.id)) { model in
            DispatchQueue.main.async { completion(model) }
        }
    }

    func deleteVet(_ id: Int, completion: @escaping () -> Void) {
        delete(url: vetUrl(id)) {
            completion()
        }
    }

    func vet(id: Int, completion: @escaping (VetModel?) -> Void) {
        get(type: VetModel.self, url: vetUrl(id)) { model in
            DispatchQueue.main.async { completion(model) }
        }
    }

    func vets(completion: @escaping ([VetModel]?) -> Void) {
        get(type: [VetModel].self, url: vetUrl()) { model in
            DispatchQueue.main.async { completion(model) }

        }
    }

    func petOwner(id: Int, completion: @escaping (PetOwnerModel?)->Void) {
        get(type: PetOwnerModel.self, url: petOwnerUrl(id)) { model in
            DispatchQueue.main.async { completion(model) }
        }
    }
    
    func addPetOwner(_ model: PetOwnerModel, completion: ((PetOwnerModel?)->Void)?) {
        post(model: model, url: petOwnerUrl(model.petId)) { model in
            DispatchQueue.main.async { completion?(model) }
        }
    }

    func updatePetOwner(_ model: PetOwnerModel, completion: ((PetOwnerModel?)->Void)?) {
        put(model: model, url: petOwnerUrl(model.id)) { model in
            DispatchQueue.main.async { completion?(model) }
        }
    }
}
