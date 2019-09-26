import UIKit
import BlackLabsDate

typealias PetInfoCompletion = () -> Void

protocol PetInfoViewControllerDelegate: class {
    func addPet(model: PetModel, vetId: Int, completion: @escaping PetInfoCompletion)
    func updatePet(model: PetModel, vetId: Int, completion: @escaping PetInfoCompletion)
    func petValidationFailed(message: String)
    func petInfoDismiss(vetId: Int, vc: UIViewController)
    func showBreedChooser(_ currentBreed: String?)
}

final class PetInfoViewController: UIViewController {

    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var breedTextField: UITextField!
    @IBOutlet weak var isFemale: UISwitch!
    @IBOutlet weak var isSpayedOrNeutered: UISwitch!

    @IBOutlet weak var datePicker: UIDatePicker!

    var model: PetModel? { return createViewModel() }
    var id: Int?
    var ownerId: Int? {
        didSet {
            // Occurs when an owner is added, so update Owner button action
            // to show newly added Owner
            let completion: PetInfoCompletion = {
                self.delegate.petInfoDismiss(vetId: self.vetId, vc: self)
            }
            actionButton.addAction {
                self.delegate.addPet(model: self.model!, vetId: self.vetId, completion: completion)
            }
        }
    }
    var vetId: Int!
    weak var delegate: PetInfoViewControllerDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.maximumDate = Date()
    }

    private func createViewModel() -> PetModel? {
        guard let first = firstName.text,
            let last = lastName.text,
            let pid = vetId,
            let breed = breedTextField.text,
            let dob = dateTextField.text else { return nil }
        return PetModel(id: self.id,
                        practitionerId: pid,
                        ownerId: ownerId,
                        firstName: first,
                        lastName: last,
                        breed: breed,
                        dob: dob,
                        isFemale: isFemale.isOn,
                        isSpayedOrNeutered: isSpayedOrNeutered.isOn
        )
    }

    var validateModel: ModelValidationResult<PetModel, String> {
        if let message = missingFieldsMessage {
            return .failure(message)
        } else if let model = self.model {
            return .sucssess(model)
        } else {
            return .failure("Unknown error.")
        }
    }

    func validate() -> [String]? {
        return PetModel.validate(
            first: firstName?.text,
            last: lastName?.text,
            breed: breedTextField?.text,
            dob: dateTextField?.text
        )
    }

    private func applyModel(_ model: PetModel) {
        firstName.text = model.firstName
        lastName.text = model.lastName
        breedTextField.text = model.breed
        dateTextField.text = model.dob.dateString("MM/dd/yyyy")
        isFemale.isOn = model.isFemale
        isSpayedOrNeutered.isOn = model.isSpayedOrNeutered
        id = model.id
        vetId = model.practitionerId
        ownerId = model.ownerId
    }

     private var missingFieldsMessage: String? {
        if let missing = validate() {
            return "The field(s): " + missing.joined(separator: ", ") + " are required."
        }
        return nil
    }

    func setup(action: String, model: PetModel? = nil) {
        title = "\(action) Pet"
        setLargeNavigation()
        actionButton.setTitle("\(action)", for: .normal)
        if let model = model {
            applyModel(model)
        }

        let isNewPet = model == nil
        let completion: PetInfoCompletion = {
            self.delegate.petInfoDismiss(vetId: self.vetId, vc: self)
        }
        actionButton.addAction {
            switch self.validateModel {
            case let .sucssess(model):
                if isNewPet {
                    self.delegate.addPet(model: model, vetId: self.vetId, completion: completion)
                } else {
                    self.delegate.updatePet(model: model, vetId: self.vetId, completion: completion)
                }
            case let .failure(message):
                self.delegate.petValidationFailed(message: message)
            }
        }
    }

    @IBAction func dateChanged(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        dateTextField.text = formatter.string(from: datePicker.date)
    }

    @IBAction func dateEditingBegin(_ sender: Any) {
        dateTextField.inputView = datePicker
    }

    @IBAction func dateEditingEnd(_ sender: Any) {
        self.view.endEditing(true)
    }

    @IBAction func breedEditingBegin(_ sender: Any) {
        delegate.showBreedChooser(breedTextField.text)
    }
}

extension PetInfoViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Breeds.dogList.count
    }
}

extension PetInfoViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Breeds.dogList[row]
    }
}
