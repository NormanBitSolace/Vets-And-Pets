import Foundation

typealias VetModel = Practitioner

struct Practitioner: Codable {
    let id: Int?
    let username: String
    let firstName: String
    let lastName: String
    let title: String
    let mission: String
    var nameAndTitle: String {
        return "\(firstName) \(lastName), \(title)"
    }
}

extension Practitioner {
    static func validate(first: String?, last: String?, user: String?, title: String?, mission: String?) -> [String]? {
        var missing = [String]()
        if first == nil || first?.isEmpty ?? true {
            missing.append("firstName")
        }
        if last == nil || last?.isEmpty ?? true {
            missing.append("lastName")
        }
        if user == nil || user?.isEmpty ?? true {
            missing.append("username")
        }
        if title == nil || title?.isEmpty ?? true {
            missing.append("title")
        }
        if mission == nil || mission?.isEmpty ?? true {
            missing.append("mission")
        }
        if missing.count == 0 { return nil }
        return missing
    }
}
