import UIKit

protocol PetsViewControllerDelegate: class {
    func actionRequest(_ request: ActionRequest<PetModel>, vetId: Int)
}

typealias PetsCompletion = ([PetModel]?) -> Void

class PetsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    weak var delegate: PetsViewControllerDelegate?
    var dataDelegate: TableViewDelegate<PetModel, UITableViewCell>!
    var vetId: Int?
    lazy var dataCompletion: PetsCompletion = { models in
        self.dataDelegate.data = models
        self.tableView.reloadOnMain()
    }
    func model(_ ip: IndexPath) -> PetModel? { return dataDelegate.data?[ip.row] }

    func sendRequest(_ action: Action<PetModel>) {
        guard let delegate = delegate else { return }
        var request: ActionRequest<PetModel>
        switch action {
        case .add:
            request = ActionRequest(action: .add(nil), completion: dataCompletion)
        case .list:
            request = ActionRequest(action: .list, completion: dataCompletion)
        case .update(let model):
            request = ActionRequest(action: .update(model), completion: dataCompletion)
        case .delete(let model):
            request = ActionRequest(action: .delete(model), completion: dataCompletion)
        case .select(let model):
            request = ActionRequest(action: .select(model), completion: dataCompletion)
        }
        guard let id = vetId else { preconditionFailure("Assumes vetId has been set.")}
        delegate.actionRequest(request, vetId: id)
    }

    @objc func addPetButtonTap() {
        sendRequest(.add(nil))
    }

    final func setup(delegate: PetsViewControllerDelegate, vetId: Int) {
        self.delegate = delegate
        self.vetId = vetId
        let decorator: (UITableViewCell, PetModel) -> Void = { cell, model in
            cell.textLabel?.text = "\(model.firstName) \(model.lastName)"
            cell.accessoryType = .disclosureIndicator
        }
        let touchDelegate: (IndexPath, PetModel) -> Void = { indexPath, model in
            self.sendRequest(.select(model))
        }
        dataDelegate = TableViewDelegate (cellType: nil, decorator: decorator, touchDelegate: touchDelegate)
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            guard let model = self.model(indexPath) else { return }
            self.sendRequest(.delete(model))
        }
//        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
//            guard let model = self.model(indexPath) else { return }
//            self.sendRequest(.update(model))
//        }
        dataDelegate.swipeActions = [deleteAction/*, editAction*/]
        tableView.setAutoSizeHeight()
        dataDelegate.setDelegate(tableView)
        navigationController?.setLargeNavigation()
        rightButton(systemItem: .add, target: self, action: #selector(addPetButtonTap))
        title = "Pets"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard isMovingToParent else { return }
        sendRequest(.list)
    }
}
