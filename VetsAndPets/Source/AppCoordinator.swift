import UIKit
import MapKit

// TODO why isn't pet loading dismissed if asyncAfter is 0?
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
            // TODO this is where we can call get List
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

    func runTask(task: Task) {
        self.loadingPresenter.show(message: task.message)
        task.run {
            self.loadingPresenter.hide()
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

extension AppCoordinator: PetsViewControllerDelegate {

    func runPetActionTask(_ request: ActionRequest<PetModel>, _ vetId: Int, _ model: PetModel? = nil) {
        let task = TaskBuilder.build(dataService, request, model, vetId: vetId)
        runTask(task: task)
    }

    func actionRequest(_ request: ActionRequest<PetModel>, vetId: Int) {
        switch request.action {
        case .list:
            runPetActionTask(request, vetId)
        case .add:
            navigator.showPetInfo { vc in
                vc.setup(action: "Add")
                vc.vetId = vetId
                vc.actionButton.addAction {
                    switch vc.validateModel {
                    case let .sucssess(model):
                        vc.dismiss(animated: true) {
                            self.runPetActionTask(request, vetId, model)
                        }
                    case let .failure(message):
                        self.navigator.showAlert(message: message)
                    }
                }
            }
        case .update(_):
            break // handled by select action
        case .delete(let model):
            runPetActionTask(request, vetId, model)
        case .select(let model):
            navigator.pushPetInfo { vc in
                let button = UIBarButtonItem(title: "Owner", style: .plain, target: nil, action: nil)
                vc.navigationItem.rightBarButtonItem = button
                button.addAction {
                    self.showPetOwner(model.ownerId)
                }
                vc.setup(action: "Update", model: model)
                vc.actionButton.addAction {
                    switch vc.validateModel {
                    case let .sucssess(model):
                        vc.dismiss(animated: true) {
                            self.runPetActionTask(request, vetId, model)
                        }
                    case let .failure(message):
                        self.navigator.showAlert(message: message)
                    }
                }
            }
        }
    }
}

extension AppCoordinator: VetsViewControllerDelegate {

    func runVetActionTask(_ request: ActionRequest<VetModel>, _ model: VetModel? = nil) {
        let task = TaskBuilder.build(dataService, request, model)
        runTask(task: task)
    }

    func actionRequest(_ request: ActionRequest<VetModel>) {

        switch request.action {
        case .list:
            runVetActionTask(request)
        case .add:
            navigator.showVetInfo { vc in
                vc.setup(action: "Add")
                vc.actionButton.addAction {
                    switch vc.validateModel {
                    case let .sucssess(model):
                        vc.dismiss(animated: true) {
                            self.runVetActionTask(request, model)
                        }
                    case let .failure(message):
                        self.navigator.showAlert(message: message)
                    }
                }
            }
        case .update(let model):
            navigator.showVetInfo { vc in
                vc.setup(action: "Update", model: model)
                vc.actionButton.addAction {
                    switch vc.validateModel {
                    case let .sucssess(model):
                        vc.dismiss(animated: true) {
                            self.runVetActionTask(request, model)
                        }
                    case let .failure(message):
                        self.navigator.showAlert(message: message)
                    }
                }
            }
        case .delete(let model):
            runVetActionTask(request, model)
        case .select(let model):
            guard let id = model.id else { preconditionFailure("Model assumed to have an id.")}
            navigator.showPetList { vc in
                vc.setup(delegate: self, vetId: id)
            }
        }
   }
}
