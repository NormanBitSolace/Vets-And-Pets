import UIKit

protocol VetsViewControllerDelegate: class {
    func actionRequest(_ request: ActionRequest<VetModel>)
}

protocol VetUserActionDelegate: class {
    func handle(action: VetUserAction)
}

enum VetUserAction {
    case add(VetsCompletion)
    case update(VetModel, VetsCompletion)
    case delete(VetModel, VetsCompletion)
    case select(VetModel)

    var action: String {
        switch self {
        case .add:
            return "Adding"
        case .update:
            return "Updating"
        case .delete:
            return "Deleting"
        case .select:
            return "Selecting"
        }
    }
}
typealias VetsCompletion = ([VetModel]?) -> Void

class VetsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    weak var delegate: VetsViewControllerDelegate?
    var dataDelegate: TableViewDelegate<VetModel, UITableViewCell>!
    lazy var dataCompletion: VetsCompletion = { models in
        self.dataDelegate.data = models
        self.tableView.reloadOnMain()
    }
    func model(_ ip: IndexPath) -> VetModel? { return dataDelegate.data?[ip.row] }

    func sendRequest(_ action: Action<VetModel>) {
        guard let delegate = delegate else { return }
        var request: ActionRequest<VetModel>
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
        delegate.actionRequest(request)
    }

    @objc func addVetButtonTap() {
        sendRequest(.add(nil))
    }
    final override func viewDidLoad() {
        super.viewDidLoad()
        dataDelegate = TableViewDelegate(
            cellType: nil,
            decorator: { (cell, model) in
                cell.textLabel?.text = "\(model.firstName) \(model.lastName)"
                cell.accessoryType = .disclosureIndicator
        }, touchDelegate: { (indexPath, model) in
            self.sendRequest(.select(model))
         })
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            guard let model = self.model(indexPath) else { return }
            self.sendRequest(.delete(model))
        }
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            guard let model = self.model(indexPath) else { return }
            self.sendRequest(.update(model))
        }
        dataDelegate.swipeActions = [deleteAction, editAction]
        tableView.setAutoSizeHeight()
        dataDelegate.setDelegate(tableView)
        navigationController?.setLargeNavigation()
        rightButton(systemItem: .add, target: self, action: #selector(addVetButtonTap))
        title = "Vets"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sendRequest(.list)
   }
}
