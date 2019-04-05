import UIKit

protocol PetUserActionDelegate: class {
    func handle(_ action: UserAction<PetModel, PetsCompletion>, vetId: Int)
    func petSelected(_ model: PetModel, vetId: Int, completion: @escaping PetsCompletion)
}

typealias PetsCompletion = ([PetModel]?) -> Void

class PetsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    weak var delegate: PetUserActionDelegate!
    var dataDelegate: TableViewDelegate<PetModel, UITableViewCell>!
    var vetId: Int!
    lazy var dataCompletion: PetsCompletion = { models in
        self.dataDelegate.data = models
        self.tableView.reloadOnMain()
    }
    func model(_ ip: IndexPath) -> PetModel? { return dataDelegate.data?[ip.row] }

    @objc func addPetButtonTap() {
        delegate.handle(.add(dataCompletion), vetId: vetId)
    }

    final func setup(delegate: PetUserActionDelegate, vetId: Int) {
        self.delegate = delegate
        self.vetId = vetId
        let decorator: (UITableViewCell, PetModel) -> Void = { cell, model in
            cell.textLabel?.text = "\(model.firstName) \(model.lastName)"
            cell.accessoryType = .disclosureIndicator
        }
        let touchDelegate: (IndexPath, PetModel) -> Void = { indexPath, model in
            self.delegate.petSelected(model, vetId: vetId, completion: self.dataCompletion)
        }
        dataDelegate = TableViewDelegate (cellType: nil, decorator: decorator, touchDelegate: touchDelegate)
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            guard let model = self.model(indexPath) else { return }
            self.delegate.handle(.delete(model, self.dataCompletion), vetId: vetId)
        }
        dataDelegate.swipeActions = [deleteAction/*, editAction*/]
        tableView.setAutoSizeHeight()
        dataDelegate.setDelegate(tableView)
        navigationController?.setLargeNavigation()
        rightButton(systemItem: .add, target: self, action: #selector(addPetButtonTap))
        title = "Pets"
    }
}
