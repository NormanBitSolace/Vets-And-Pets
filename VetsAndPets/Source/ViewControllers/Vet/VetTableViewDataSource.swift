import UIKit

protocol VetTableViewDataSourceDelegate: class {
    func vetSelected(_ model: VetModel)
}

class VetTableViewDataSource: TableViewDelegate<VetModel, UITableViewCell> {
    weak var delegate: VetTableViewDataSourceDelegate!

    init(delegate: VetTableViewDataSourceDelegate) {
        self.delegate = delegate
        super.init(
            cellType: nil,
            decorator: { (cell, model) in
                cell.textLabel?.text = "\(model.firstName) \(model.lastName)"
                cell.accessoryType = .disclosureIndicator
        }, touchDelegate: { (indexPath, model) in
            delegate.vetSelected(model)
        })
    }
}
