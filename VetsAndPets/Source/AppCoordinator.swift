import UIKit
import MapKit

final class AppCoordinator: NSObject {

    let loadingPresenter: LoadingPresenter
    let navigator: AppNavigator
    let dataService: DataService
    let reachability = Reachability()!

    init(appNavigator: AppNavigator, dataService: DataService) {
        self.navigator = appNavigator
        self.dataService = dataService
        loadingPresenter = LoadingPresenter(navigator: navigator)
    }

    func start() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }

    func showRootViewController() {
        navigator.showVetList { vc in
            vc.delegate = self
            self.fetchVets(vc)
       }
    }

    func fetchVets(_ vc: VetsViewController) {
        self.loadingPresenter.show(message: "Getting Vets")
        self.dataService.vets { models in
            vc.dataCompletion(models)
            self.loadingPresenter.hide()
        }
    }

    func fetchPets(_ vc: PetsViewController, _ vetId: Int) {
        self.loadingPresenter.show(message: "Getting Pets")
        self.dataService.pets(forVet: vetId) { models in
            vc.dataCompletion(models)
            self.loadingPresenter.hide()
        }
    }

    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .wifi, .cellular:
            print("Reachable via WiFi or Cellular")
            showRootViewController()
        case .none:
            navigator.showAlert(message: "Network not reachable")
        }
    }

    func showPetOwner(_ petOwnerId: Int?) {
        navigator.showPetOwner { vc in
            vc.delegate = self
            if let id = petOwnerId {
                self.dataService.petOwner(id: id) { owner in
                    let action = owner == nil ? "Create" : "Update"
                    DispatchQueue.main.async {
                        vc.setup(action: action, model: owner)
                    }
                }
            } else {
                vc.setup(action: "Create")
            }
        }
    }

    func run(_ task: DataServiceTask, message: String, completion: (() -> Void)? = nil) {
        self.loadingPresenter.show(message: message)
        task.run(dataService) {
            self.loadingPresenter.hide() {
                completion?()
            }
        }
    }
}

extension AppCoordinator: PetOwnerInfoViewControllerDelegate {
    func actionRequest(_ request: ActionRequest<PetOwnerModel>) {
        switch request.action {
        case .add(let model):
            dataService.addPetOwner(model!, completion: nil)
        case .update(let model):
            dataService.addPetOwner(model, completion: nil)
        default:
            preconditionFailure("This app currently supports add and update PetOwner only.")
        }
    }

}

extension AppCoordinator: PetUserActionDelegate {

    func handle(_ action: UserAction<PetModel, PetsCompletion>, vetId: Int) {
        switch action {
        case .add(_):
            navigator.showPetInfo { vc in
                vc.setup(action: "Add")
                vc.vetId = vetId
                vc.delegate = self
            }
        case .update(_, _):
            fatalError("Not implemented yet.")
        case let .delete(model, completion):
            let task = PetTask(.delete(model, completion), vetId: vetId)
            self.run(task, message: action.message)
        }
    }

    func petSelected(_ model: PetModel, vetId: Int, completion: @escaping PetsCompletion) {
        navigator.pushPetInfo { vc in
            let button = UIBarButtonItem(title: "Owner", style: .plain, target: nil, action: nil)
            vc.navigationItem.rightBarButtonItem = button
            vc.delegate = self
            button.addAction {
                self.showPetOwner(model.ownerId)
            }
            vc.setup(action: "Update", model: model)
//            vc.actionButton.addAction {
//                switch vc.validateModel {
//                case let .sucssess(model):
//                    vc.dismiss(animated: true) {
//                        let task = PetTask(.update(model, completion), vetId: vetId)
//                        self.run(task, message: "Updating")
//                    }
//                case let .failure(message):
//                    self.navigator.showAlert(message: message)
//                }
//            }
        }
    }
}

extension AppCoordinator: VetUserActionDelegate {

    func vetSelected(_ model: VetModel) {
        guard let id = model.id else { preconditionFailure("Model assumed to have an id.")}
        navigator.showPetList { vc in
            vc.setup(delegate: self, vetId: id)
            self.dataService.pets(forVet: id) { models in
                vc.dataCompletion(models)
            }
        }
    }
    func handle(_ action: UserAction<VetModel, VetsCompletion>) {
        switch action {
        case .add(_):
            navigator.showVetInfo { vc in
                vc.delegate = self
                vc.setup(action: "Add")
            }
        case let .update(model, _):
            navigator.showVetInfo { vc in
                vc.delegate = self
                vc.setup(action: "Update", model: model)
            }
        case let .delete(model, completion):
            let task = VetTask(.delete(model, completion))
            self.run(task, message: action.message)
        }
    }
}

extension AppCoordinator: PetInfoViewControllerDelegate, SearchTouchDelegate {
    func handleSearchTouch(value: String) {
        if let vc = navigator.topViewController as? PetInfoViewController {
            vc.dismissViewController()
            vc.breedTextField.text = value
        }
    }

    func showBreedChooser(_ currentBreed: String?) {
        let _: SearchViewController = navigator.presentModal(storyboardName: "Search", wrap: true) { vc in
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
    func petInfoDismiss(vetId: Int) { // adding pet
        navigator.topViewController?.dismiss(animated: true) {
            if let vc = self.navigator.topViewController as? PetsViewController {
                self.fetchPets(vc, vetId)
            }
        }
    }

    func petInfoPop(vetId: Int) { // updating Pet
        navigator.topViewController?.navigationController?.popViewController(animated: true) {
            // need to refresh here because of potential name change would be stale
            if let vc = self.navigator.topViewController as? PetsViewController {
                self.fetchPets(vc, vetId)
            }
        }
    }

    func addPet(model: PetModel, vetId: Int, completion: @escaping () -> Void) {
        let task = PetTask(.add(model, nil), vetId: vetId)
        self.run(task, message: "Adding Pet") {
            completion()
        }
    }

    func updatePet(model: PetModel, vetId: Int, completion: @escaping () -> Void) {
        let task = PetTask(.update(model, nil), vetId: vetId)
        self.run(task, message: "Updating Pet") {
            completion()
        }
    }

    func petValidationFailed(message: String) {
        self.navigator.showAlert(message: message)
    }

}

extension AppCoordinator: VetInfoViewControllerDelegate {

    func vetInfoDismiss() {
        navigator.topViewController?.dismiss(animated: true) {
            if let vc = self.navigator.topViewController as? VetsViewController {
                self.fetchVets(vc)
            }
        }
    }

    func addVet(model: VetModel, completion: @escaping () -> Void) {
        let task = VetTask(.add(model, nil))
        self.run(task, message: "Adding Vet") {
            completion()
        }
    }

    func updateVet(model: VetModel, completion: @escaping () -> Void) {
        let task = VetTask(.update(model, nil))
        self.run(task, message: "Updating Vet") {
            completion()
        }
    }

    func vetValidationFailed(message: String) {
        self.navigator.showAlert(message: message)
    }

}
