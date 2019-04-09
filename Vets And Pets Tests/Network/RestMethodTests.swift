import XCTest
@testable import Vets_And_Pets

class RestMethodTests: XCTestCase, RestHelper {

    override func setUp() { }
    override func tearDown() { }

    struct Model: Codable, Equatable {
        let code: String
        let hello: String
    }

    func testGet() {
        var model: Model?
        let url = URL("https://fourtonfish.com/hellosalut/?lang=us")
        let expectation = self.expectation(description: "testData")
        get(type: Model.self, url: url) { serverModel in
            model = serverModel
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual("none", model?.code)
    }
}
