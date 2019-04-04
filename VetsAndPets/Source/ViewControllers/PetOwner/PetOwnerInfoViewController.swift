import UIKit

protocol PetOwnerInfoViewControllerDelegate: class {
    func actionRequest(_ request: ActionRequest<PetOwnerModel>)
}

final class PetOwnerInfoViewController: UIViewController {

    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!

    var model: PetOwnerModel? { return createViewModel() }
    var id: Int?
    weak var delegate: PetOwnerInfoViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func actionButtonTap(_ sender: UIButton) {
        guard let model = model else { return }
        var request: ActionRequest<PetOwnerModel>
        switch sender.title(for: .normal) {
        case "Create":
            request = ActionRequest(action: .add(model), completion: nil)
        default:
            request = ActionRequest(action: .update(model), completion: nil)
        }
        delegate?.actionRequest(request)
        navigationController?.popViewController(animated: true)
    }

    private func createViewModel() -> PetOwnerModel? {
//        guard isValid else { return nil }
        guard let first = firstName.text,
            let last = lastName.text else { return nil }
        return PetOwnerModel(id: self.id,
                    firstName: first,
                    lastName: last
        )
    }

    private func applyModel(_ model: PetOwnerModel) {
        firstName.text = model.firstName
        lastName.text = model.lastName
        id = model.id
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
