import UIKit

final class PetInfoViewController: UIViewController {

    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var breedTextField: UITextField!
    @IBOutlet weak var isFemale: UISwitch!
    @IBOutlet weak var isSpayedOrNeutered: UISwitch!

    let breedPicker = UIPickerView()
    let datePicker = UIDatePicker()
    let toolbar = UIToolbar()

    var model: PetModel? { return createViewModel() }
    var id: Int?
    var vetId: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        breedPicker.delegate = self
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()

        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(hidePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)

        toolbar.setItems([spaceButton,doneButton], animated: false)
    }

    private func createViewModel() -> PetModel? {
//        guard isValid else { return nil }
        guard let first = firstName.text,
            let last = lastName.text,
            let pid = vetId,
            let breed = breedTextField.text,
            let dob = dateTextField.text else { return nil }
        return PetModel(id: self.id,
                        practitionerId: pid,
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
//    var isValid: Bool { return validate() == nil }

    func validate() -> [String]? {
        return Pet.validate(
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
    }

    private var missingFieldsMessage: String? {
        if let missing = validate() {
            return "The field(s): " + missing.joined(separator: ", ") + " are required."
        }
        return nil
    }

    func setup(action: String, model: PetModel? = nil) {
        title = "\(action) Pet"
        navigationController?.setLargeNavigation()
        actionButton.setTitle("\(action)", for: .normal)
        if let model = model {
            applyModel(model)
        }
    }

    private func showDatePicker(){
        dateTextField.inputAccessoryView = toolbar
        dateTextField.inputView = datePicker
        toolbar.sizeToFit()
    }

    private func showBreedPicker() {
        breedTextField.inputAccessoryView = toolbar
        breedTextField.inputView = breedPicker
        toolbar.sizeToFit()
    }
    @IBAction func dateEditingEnd(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        dateTextField.text = formatter.string(from: datePicker.date)
    }
    @IBAction func dateEditingBegin(_ sender: Any) {
        showDatePicker()
    }
    @IBAction func breedEditingEnd(_ sender: Any) {
        breedTextField.text = Breeds.dogList[breedPicker.selectedRow(inComponent: 0)]
        self.view.endEditing(true)
    }
    @IBAction func breedEditingBegin(_ sender: Any) {
        showBreedPicker()
    }
   @objc func hidePicker(){
        self.view.endEditing(true)
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
