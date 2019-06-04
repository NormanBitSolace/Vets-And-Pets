import UIKit

protocol VetUserActionDelegate: class {
    func handle(_ action: UserAction<VetModel, VetsCompletion>)
}

typealias VetsCompletion = ([VetModel]?) -> Void

class VetsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    weak var delegate: VetUserActionDelegate!
    var dataDelegate: TableViewDelegate<VetModel, UITableViewCell>!
    lazy var dataCompletion: VetsCompletion = { models in
        self.dataDelegate.data = models
    }

    @objc func addVetButtonTap() {
        delegate.handle(.add(dataCompletion))
    }

    final override func viewDidLoad() {
        super.viewDidLoad()
        tableView.setAutoSizeHeight()
        navigationController?.setLargeNavigation()
        rightButton(systemItem: .add, target: self, action: #selector(addVetButtonTap))
        title = "Vets"
    }

    final func setup(delegate: VetUserActionDelegate, dataDelegate: TableViewDelegate<VetModel, UITableViewCell>) {
        self.delegate = delegate
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            guard let model = self.dataDelegate.model(indexPath) else { return }
            self.delegate.handle(.delete(model, self.dataCompletion))
        }
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            guard let model = self.dataDelegate.model(indexPath) else { return }
            self.delegate.handle(.update(model, self.dataCompletion))
        }
        self.dataDelegate = dataDelegate
        dataDelegate.tableView = tableView
        dataDelegate.swipeActions = [deleteAction, editAction]
    }
}
