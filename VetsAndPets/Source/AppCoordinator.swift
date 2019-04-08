import UIKit
import MapKit

enum AppViewControllers {
    case vets
    case vetInfo(String, VetModel?)
    case pets(Int)
    case petInfoPush(String, PetModel)
    case petInfoModal(String, Int)
    case petOwnerInfo(Int?, Int?)
    case breedSearch
}

final class AppCoordinator: NSObject {

    let loadingPresenter: LoadingPresenter
    let navigator: AppNavigator
    let dataService: DataService

    init(appNavigator: AppNavigator, dataService: DataService) {
        self.navigator = appNavigator
        self.dataService = dataService
        loadingPresenter = LoadingPresenter(navigator: navigator)
    }

    func start() {
        navigate(to: .vets)
    }

    func fetchVetsShowLoading(_ vc: VetsViewController) {
        self.loadingPresenter.show(message: "Getting Vets")
        self.dataService.vets { models in
            vc.dataCompletion(models)
            self.loadingPresenter.hide()
        }
    }

    func fetchPetsShowLoading(_ vc: PetsViewController, _ vetId: Int) {
        self.loadingPresenter.show(message: "Getting Pets")
        self.dataService.pets(forVet: vetId) { models in
            vc.dataCompletion(models)
            self.loadingPresenter.hide()
        }
    }

    func runShowLoading(_ task: DataServiceTask, message: String, completion: (() -> Void)? = nil) {
        self.loadingPresenter.show(message: message)
        task.run(dataService) {
            self.loadingPresenter.hide() {
                completion?()
            }
        }
    }
}

extension AppCoordinator: PetOwnerInfoViewControllerDelegate {

    func addPetOwner(model: PetOwnerModel) {
        dataService.addPetOwner(model) { model in
            self.navigator.topViewController?.navigationController?.popViewController(animated: true) {
                if let vc = self.navigator.topViewController as? PetInfoViewController {
                    vc.ownerId = model?.id
                }
            }
        }
    }

    func updatePetOwner(model: PetOwnerModel) {
        dataService.updatePetOwner(model) { _ in
            self.navigator.topViewController?.navigationController?.popViewController(animated: true)
        }
    }
}

extension AppCoordinator: PetUserActionDelegate {

    func handle(_ action: UserAction<PetModel, PetsCompletion>, vetId: Int) {
        switch action {
        case .add(_):
            navigate(to: .petInfoModal("Add", vetId))
        case .update(_, _):
            fatalError("Not implemented yet.")
        case let .delete(model, completion):
            let task = PetTask(.delete(model, completion), vetId: vetId)
            self.runShowLoading(task, message: action.message)
        }
    }

    func petSelected(_ model: PetModel, vetId: Int, completion: @escaping PetsCompletion) {
        navigate(to: .petInfoPush("Update", model))
    }
}

extension AppCoordinator: VetUserActionDelegate {

    func vetSelected(_ model: VetModel) {
        guard let id = model.id else { preconditionFailure("Model assumed to have an id.")}
        navigate(to: .pets(id))
    }

    func handle(_ action: UserAction<VetModel, VetsCompletion>) {
        switch action {
        case .add(_):
            navigate(to: .vetInfo("Add", nil))
        case let .update(model, _):
            navigate(to: .vetInfo("Update", model))
        case let .delete(model, completion):
            let task = VetTask(.delete(model, completion))
            self.runShowLoading(task, message: action.message)
        }
    }
}

extension AppCoordinator: PetInfoViewControllerDelegate, SearchTouchDelegate {


    /// Handles result sent from breed search view controller. This may have been pushed
    /// or presented so the presentingViewController is used to dismiss.
    /// - Parameters:
    ///   - value: Breed of dog selected from search view.
    ///   - vc: The search view controller.
    func handleSearchTouch(value: String, vc: UIViewController) {
        if let nvc = vc.presentingViewController as? UINavigationController {
            nvc.dismiss(animated: true) {
                if let pivc = nvc.topViewController as? PetInfoViewController {
                    pivc.breedTextField.text = value
                }
            }
        }
    }

    func showBreedChooser(_ currentBreed: String?) {
        navigate(to: .breedSearch)
    }

    func petInfoDismiss(vetId: Int, vc: UIViewController) {
        let completion: () -> Void = {
            if let pvc = self.navigator.topViewController as? PetsViewController {
                self.fetchPetsShowLoading(pvc, vetId)
            }
        }
        if let nvc = vc.presentingViewController as? UINavigationController { // adding pet
            nvc.dismiss(animated: true, completion: completion)
        } else { // updating pet
            navigator.rootNavigationController.popViewController(animated: true, completion: completion)
        }
    }

    func addPet(model: PetModel, vetId: Int, completion: @escaping () -> Void) {
        let task = PetTask(.add(model, nil), vetId: vetId)
        self.runShowLoading(task, message: "Adding Pet") {
            completion()
        }
    }

    func updatePet(model: PetModel, vetId: Int, completion: @escaping () -> Void) {
        let task = PetTask(.update(model, nil), vetId: vetId)
        self.runShowLoading(task, message: "Updating Pet") {
            completion()
        }
    }

    func petValidationFailed(message: String) {
        self.navigator.showAlert(message: message)
    }
}

extension AppCoordinator: VetInfoViewControllerDelegate {

    private func vetsIsTopViewController() -> VetsViewController? {
        return navigator.topViewController as? VetsViewController
    }

    func vetInfoDismiss() {
        navigator.topViewController?.dismiss(animated: true) {
            if let vc = self.vetsIsTopViewController() {
                self.fetchVetsShowLoading(vc)
            }
        }
    }

    func addVet(model: VetModel, completion: @escaping () -> Void) {
        let task = VetTask(.add(model, nil))
        self.runShowLoading(task, message: "Adding Vet") {
            completion()
        }
    }

    func updateVet(model: VetModel, completion: @escaping () -> Void) {
        let task = VetTask(.update(model, nil))
        self.runShowLoading(task, message: "Updating Vet") {
            completion()
        }
    }

    func vetValidationFailed(message: String) {
        self.navigator.showAlert(message: message)
    }

}

fileprivate extension AppCoordinator {

    func navigate(to: AppViewControllers) {

        func showRootViewController() {
            navigator.showVetList { vc in
                vc.delegate = self
                self.fetchVetsShowLoading(vc)
            }
        }

        func showVetInfo(action: String, model: VetModel? = nil) {
            navigator.showVetInfo { vc in
                vc.delegate = self
                vc.setup(action: action, model: model)
            }
        }

        func showPetList(_ vetId: Int) {
            navigator.showPetList { vc in
                vc.setup(delegate: self, vetId: vetId)
                self.dataService.pets(forVet: vetId) { models in
                    vc.dataCompletion(models)
                }
            }
        }

        func showPetInfoModal(action: String, vetId: Int) {
            navigator.showPetInfo { vc in
                vc.setup(action: action)
                vc.vetId = vetId
                vc.delegate = self
            }
        }

        func showPetInfoPush(action: String, model: PetModel) {
            navigator.pushPetInfo { vc in
                let button = UIBarButtonItem(title: "Owner", style: .plain, target: nil, action: nil)
                vc.navigationItem.rightBarButtonItem = button
                vc.delegate = self
                button.addAction {
                    self.navigate(to: .petOwnerInfo(model.id, model.ownerId))
                    //                self.showPetOwner(model.ownerId)
                }
                vc.setup(action: "Update", model: model)
            }
        }

        func showPetOwner(_ petId: Int?, _ petOwnerId: Int?) {
            navigator.showPetOwner { vc in
                vc.delegate = self
                vc.petId = petId
                if let id = petOwnerId {
                    self.dataService.petOwner(id: id) { owner in
                        let action = owner == nil ? "Create" : "Update"
                        vc.setup(action: action, model: owner)
                    }
                } else {
                    vc.setup(action: "Create")
                }
            }
        }

        func showBreedSearch() {
            navigator.showBreedSearch { vc in
                vc.navigationController?.setLargeNavigation()
                vc.title = "Breeds"
                vc.data = Breeds.dogList
                vc.delegate = self
                vc.addDoneButton()
                vc.navigationItem.rightBarButtonItem?.addAction {
                    vc.dismissViewController()
                }
            }
        }

        switch to {
        case .vets:
            showRootViewController()
        case let .vetInfo(action, model):
            showVetInfo(action: action, model: model)
        case let .pets(vetId):
            showPetList(vetId)
        case let .petInfoPush(action, model):
            showPetInfoPush(action: action, model: model)
        case let .petInfoModal(action, vetId):
            showPetInfoModal(action: action, vetId: vetId)
        case let .petOwnerInfo(petId, petOwnerId):
            showPetOwner(petId, petOwnerId)
        case .breedSearch:
            showBreedSearch()
        }
    }

}
