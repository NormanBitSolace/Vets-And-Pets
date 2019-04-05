import UIKit

enum ModelValidationResult<T, String> {
    case sucssess(T)
    case failure(String)
}

typealias VetInfoCompletion = () -> Void

protocol VetInfoViewControllerDelegate: class {
    func addVet(model: VetModel, completion: @escaping VetInfoCompletion)
    func updateVet(model: VetModel, completion: @escaping VetInfoCompletion)
    func vetValidationFailed(message: String)
    func vetInfoDismiss()
}

final class VetInfoViewController: UIViewController {

    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var vetTitle: UITextField!
    @IBOutlet weak var mission: UITextField!

    var model: VetModel? { return createViewModel() }
    var id: Int?
    weak var delegate: VetInfoViewControllerDelegate!

    private func createViewModel() -> VetModel? {
//        guard isValid else { return nil }
        return VetModel(id: id,
                        username: userName.text!,
                        firstName: firstName.text!,
                        lastName: lastName.text!,
                        title: vetTitle.text!,
                        mission: mission.text!
        )
    }
    var validateModel: ModelValidationResult<VetModel, String> {
        if let message = missingFieldsMessage {
            return .failure(message)
        } else if let model = self.model {
            return .sucssess(model)
        } else {
            return .failure("Unknown error.")
        }
    }
//    var isValid: Bool { return validate() == nil }

    private func validate() -> [String]? {
        return Practitioner.validate(
            first: firstName?.text,
            last: lastName?.text,
            user: userName?.text,
            title: vetTitle?.text,
            mission: mission?.text
        )
    }

    private func applyModel(_ model: VetModel) {
        firstName.text = model.firstName
        lastName.text = model.lastName
        userName.text = model.username
        vetTitle.text = model.title
        mission.text = model.mission
        id = model.id
    }

    private var missingFieldsMessage: String? {
        if let missing = validate() {
            return "The field(s): " + missing.joined(separator: ", ") + " are required."
        }
        return nil
    }

    func setup(action: String, model: VetModel? = nil) {
        title = "\(action) Vet"
        id = model?.id
        navigationController?.setLargeNavigation()
        rightButton(systemItem: .cancel, target: self, action: #selector(self.dismissViewController))
        actionButton.setTitle("\(action)", for: .normal)
        if let model = model {
            applyModel(model)
        }

        let isNewVet = id == nil
        actionButton.addAction {
            let completion: () -> Void = { self.delegate.vetInfoDismiss() }
            switch self.validateModel {
            case let .sucssess(model):
                if isNewVet {
                    self.delegate.addVet(model: model, completion: completion)
                } else {
                    self.delegate.updateVet(model: model, completion: completion)
                }
            case let .failure(message):
                self.delegate.vetValidationFailed(message: message)
            }
        }
    }
}
