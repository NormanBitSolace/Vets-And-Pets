import Foundation

// TODO vet api should return single value, not entire list
protocol DataService: class {

//    func vet(id: Int, completion: @escaping (VetModel?)->Void)
    func vets(completion: @escaping ([VetModel]?)->Void)
    func addVet(_ model: VetModel, completion: @escaping (VetModel?)->Void)
    func updateVet(_ model: VetModel, completion: @escaping (VetModel?)->Void)
    func deleteVet(_ id: Int, completion: @escaping ()->Void)

    //    func pet(id: Int, completion: @escaping (PetModel?)->Void)
//    func pets(completion: @escaping ([PetModel]?)->Void)
    func pets(forVet vet: Int, completion: @escaping ([PetModel]?)->Void)

    func addPet(_ model: PetModel, completion: @escaping (PetModel?)->Void)
    func updatePet(_ model: PetModel, completion: @escaping (PetModel?)->Void)
    func deletePet(_ id: Int, completion: @escaping ()->Void)

    func petOwner(id: Int, completion: @escaping (PetOwnerModel?)->Void)
    func addPetOwner(_ model: PetOwnerModel, completion: ((PetOwnerModel?)->Void)?)
    func updatePetOwner(_ model: PetOwnerModel, completion: ((PetOwnerModel?)->Void)?)
}
