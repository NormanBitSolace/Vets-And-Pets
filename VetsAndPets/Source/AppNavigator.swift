import UIKit
import os
import BlackLabsViewController

struct LOG {
    static func info(_ string: String) {
        os_log("%@", log: .default, type: .info, string)
    }
}
class AppNavigator: Navigator {

    let customLog = OSLog(subsystem: "com.your_company.your_subsystem_name.plist", category: "Navigator")

    func showVetList(completion: ((VetsViewController) -> ())? = nil) {
        root(type: VetsViewController.self, storyboardName: "Vets") { vc in
            LOG.info("VetsViewController \(self.rootNavigationController.viewControllers.count)")
            completion?(vc)
        }
    }

    func showPetList(completion: @escaping (PetsViewController) -> ()) {
        let _: PetsViewController = push(storyboardName: "Pets", animated: true) { vc in
            LOG.info("PetsViewController \(self.rootNavigationController.viewControllers.count)")
            completion(vc)
        }
    }

    func showVetInfo(completion: @escaping (VetInfoViewController) -> ()) {
        let _: VetInfoViewController = presentModal(storyboardName: "VetInfo", wrap: true) { vc in
            LOG.info("VetInfoViewController \(self.rootNavigationController.viewControllers.count)")
            completion(vc)
        }
    }

    func showPetInfo(completion: @escaping (PetInfoViewController) -> ()) {
        let _: PetInfoViewController = presentModal(storyboardName: "PetInfo", wrap: true) { vc in
            vc.rightButton(systemItem: .cancel, target: vc, action: #selector(vc.dismissViewController))
            LOG.info("PetInfoViewController/modal \(self.rootNavigationController.viewControllers.count)")
            completion(vc)
        }
    }

    func pushPetInfo(completion: @escaping (PetInfoViewController) -> ()) {
        let _: PetInfoViewController = push(storyboardName: "PetInfo") { vc in
            LOG.info("PetInfoViewController/push \(self.rootNavigationController.viewControllers.count)")
            completion(vc)
        }
    }

    func showPetOwner(completion: @escaping (PetOwnerInfoViewController) -> ()) {
        let _: PetOwnerInfoViewController = push(storyboardName: "PetOwnerInfo") { vc in
            LOG.info("PetOwnerInfoViewController \(self.rootNavigationController.viewControllers.count)")
            completion(vc)
        }
    }

    func showBreedSearch(completion: @escaping (SearchViewController) -> ()) {
        let _: SearchViewController = presentModal(storyboardName: "Search", wrap: true) { vc in
            LOG.info("SearchViewController \(self.rootNavigationController.viewControllers.count)")
            completion(vc)
        }
    }

    func showAlert(message: String) {
        Navigator.presentModalOnCurrent(type: ModalAlertViewController.self, storyboardName: "ModalAlert") { vc in
            LOG.info("Alert \(self.rootNavigationController.viewControllers.count)")
            vc.alertTitle = message
            vc.circleView.borderWidth = 18
            vc.circleView.borderColor = .orange
            vc.titleLabel.textColor = .orange
        }
    }
}
