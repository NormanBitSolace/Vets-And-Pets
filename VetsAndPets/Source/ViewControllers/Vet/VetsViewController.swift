import UIKit

protocol VetUserActionDelegate: class {
    func handle(_ action: UserAction<VetModel, VetsCompletion>)
    func vetSelected(_ model: VetModel)
}

enum UserAction<M, C> {
    case add(C)
    case update(M, C)
    case delete(M, C)

    var message: String {
        switch self {
        case .add:
            return "Adding"
        case .update:
            return "Updating"
        case .delete:
            return "Deleting"
        }
    }
}
typealias VetsCompletion = ([VetModel]?) -> Void

class VetsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    weak var delegate: VetUserActionDelegate!
    var dataDelegate: TableViewDelegate<VetModel, UITableViewCell>!
    lazy var dataCompletion: VetsCompletion = { models in
        self.dataDelegate.data = models
        self.tableView.reloadOnMain()
    }
    func model(_ ip: IndexPath) -> VetModel? { return dataDelegate.data?[ip.row] }

    @objc func addVetButtonTap() {
        delegate.handle(.add(dataCompletion))
    }

    final override func viewDidLoad() {
        super.viewDidLoad()
        dataDelegate = TableViewDelegate(
            cellType: nil,
            decorator: { (cell, model) in
                cell.textLabel?.text = "\(model.firstName) \(model.lastName)"
                cell.accessoryType = .disclosureIndicator
        }, touchDelegate: { (indexPath, model) in
            self.delegate.vetSelected(model)
         })
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            guard let model = self.model(indexPath) else { return }
            self.delegate.handle(.delete(model, self.dataCompletion))
        }
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            guard let model = self.model(indexPath) else { return }
            self.delegate.handle(.update(model, self.dataCompletion))
        }
        dataDelegate.swipeActions = [deleteAction, editAction]
        tableView.setAutoSizeHeight()
        dataDelegate.setDelegate(tableView)
        navigationController?.setLargeNavigation()
        rightButton(systemItem: .add, target: self, action: #selector(addVetButtonTap))
        title = "Vets"
    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        printTransitionStates()
//    }
}
