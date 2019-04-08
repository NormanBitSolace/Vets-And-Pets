import UIKit

protocol PetOwnerInfoViewControllerDelegate: class {
    func addPetOwner(model: PetOwnerModel)
    func updatePetOwner(model: PetOwnerModel)
}

/* TODO
 Should PetOwnerInfoViewControllerDelegate and PetInfoViewControllerDelegate use UserAction to be consistent with other VC?
 */
final class PetOwnerInfoViewController: UIViewController {

    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!

    var model: PetOwnerModel? { return createViewModel() }
    var id: Int?
    var petId: Int?
    weak var delegate: PetOwnerInfoViewControllerDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func actionButtonTap(_ sender: UIButton) {
        guard let model = model else { return }
        let addingOwner = id == nil
        if addingOwner {
            delegate.addPetOwner(model: model)
        } else {
            delegate.updatePetOwner(model: model)
        }
    }

    private func createViewModel() -> PetOwnerModel? {
        guard let first = firstName.text,
            let last = lastName.text else { return nil }
        return PetOwnerModel(id: self.id,
                    petId: petId,
                    firstName: first,
                    lastName: last
        )
    }

    private func applyModel(_ model: PetOwnerModel) {
        id = model.id
        petId = model.petId
        firstName.text = model.firstName
        lastName.text = model.lastName
    }

    func setup(action: String, model: PetOwnerModel? = nil) {
        title = "\(action) Pet Owner"
        navigationController?.setLargeNavigation()
        actionButton.setTitle("\(action)", for: .normal)
        if let model = model {
            applyModel(model)
        }
    }
}
