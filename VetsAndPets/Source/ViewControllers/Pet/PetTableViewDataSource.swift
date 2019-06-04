import UIKit

protocol PetTableViewDataSourceDelegate: class {
    func petSelected(_ model: PetModel, vetId: Int, completion: @escaping PetsCompletion)
}

class PetTableViewDataSource: TableViewDelegate<PetModel, UITableViewCell> {
    weak var delegate: PetTableViewDataSourceDelegate!

    init(delegate: PetTableViewDataSourceDelegate, vetId: Int, completion: @escaping PetsCompletion) {
        self.delegate = delegate
        super.init(
            cellType: nil,
            decorator: { (cell, model) in
                cell.textLabel?.text = "\(model.firstName) \(model.lastName)"
                cell.accessoryType = .disclosureIndicator
        }, touchDelegate: { (indexPath, model) in
            delegate.petSelected(model, vetId: vetId, completion: completion)
        })
    }
}
