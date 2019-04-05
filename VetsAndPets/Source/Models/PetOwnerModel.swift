import Foundation

struct PetOwnerModel: Codable {
    var id: Int?
    let firstName: String
    let lastName: String
}

extension PetOwnerModel {
    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }

    static func validate(first: String?, last: String?) -> [String]? {
        var missing = [String]()
        if first == nil || first?.isEmpty ?? true {
            missing.append("firstName")
        }
        if last == nil || last?.isEmpty ?? true {
            missing.append("lastName")
        }
        if missing.count == 0 { return nil }
        return missing
    }
}
