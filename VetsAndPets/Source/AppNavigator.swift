import UIKit

class AppNavigator: Navigator {

    func showVetList(completion: ((VetsViewController) -> ())? = nil) {
        root(type: VetsViewController.self, storyboardName: "Vets") { vc in
            completion?(vc)
        }
    }

    func showPetList(completion: @escaping (PetsViewController) -> ()) {
        let _: PetsViewController = push(storyboardName: "Pets", animated: true) { vc in
            completion(vc)
        }
    }

    func showVetInfo(completion: @escaping (VetInfoViewController) -> ()) {
        let _: VetInfoViewController = presentModal(storyboardName: "VetInfo", wrap: true) { vc in
            completion(vc)
        }
    }

    func showPetInfo(completion: @escaping (PetInfoViewController) -> ()) {
        let _: PetInfoViewController = presentModal(storyboardName: "PetInfo", wrap: true) { vc in
            vc.rightButton(systemItem: .cancel, target: vc, action: #selector(vc.dismissViewController))
            completion(vc)
        }
    }

    func pushPetInfo(completion: @escaping (PetInfoViewController) -> ()) {
        let _: PetInfoViewController = push(storyboardName: "PetInfo") { vc in
            completion(vc)
        }
    }

    func showPetOwner(completion: @escaping (PetOwnerInfoViewController) -> ()) {
        let _: PetOwnerInfoViewController = push(storyboardName: "PetOwnerInfo") { vc in
            completion(vc)
        }
    }

    func showAlert(message: String) {
        Navigator.presentModalOnCurrent(type: ModalAlertViewController.self, storyboardName: "ModalAlert") { vc in
            vc.alertTitle = message
            vc.circleView.borderWidth = 18
            vc.circleView.borderColor = .orange
            vc.titleLabel.textColor = .orange
        }
    }
}
