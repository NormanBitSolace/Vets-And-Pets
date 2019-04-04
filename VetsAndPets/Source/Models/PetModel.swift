import Foundation

typealias PetModel = Pet

struct Pet: Codable {
    var id: Int?
    let practitionerId: Int
    var ownerId: Int?
    let firstName: String
    let lastName: String
    let breed: String
    let animalType = 0
    let dob: Date
    let isFemale: Bool
    let isSpayedOrNeutered: Bool
}


extension Pet {

    init(id: Int?, practitionerId: Int, firstName: String, lastName: String, breed: String, dob: String, isFemale: Bool, isSpayedOrNeutered: Bool) {
        self.id = id
        self.practitionerId = practitionerId
        self.firstName = firstName
        self.lastName = lastName
        self.breed = breed
        self.dob = Date.parse(dob, format: "MM/dd/yyyy")
        self.isFemale = isFemale
        self.isSpayedOrNeutered = isSpayedOrNeutered
    }

    static func validate(first: String?, last: String?, breed: String?, dob: String?) -> [String]? {
        var missing = [String]()
        if first == nil || first?.isEmpty ?? true {
            missing.append("firstName")
        }
        if last == nil || last?.isEmpty ?? true {
            missing.append("lastName")
        }
        if breed == nil || breed?.isEmpty ?? true {
            missing.append("breed")
        }
        if dob == nil || dob?.isEmpty ?? true {
            missing.append("dob")
        }
        if missing.count == 0 { return nil }
        return missing
    }
}
