import XCTest
@testable import Vets_And_Pets

class RestHelperTests: XCTestCase, RestHelper {

    override func setUp() { }
    override func tearDown() { }

    //   TODO fails when running multiple tests. No idea why or what memory is shared...
    func ztestGet() {
        var model: ToDo?
        let url = URL("https://voice-frosty-19170.v2.vapor.cloud/todos")
        let expectation = self.expectation(description: "testGet")
        get(type: [ToDo].self, url: url) { serverModel in
            model = serverModel?.first
            print("xxx \(model)")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        print("xxx2 \(model)")
        if let id = model?.id! {
            XCTAssertEqual(1, id)
        } else {
            XCTFail("Get failed.")
        }
    }

    struct ToDo: Codable {
        let id: Int?
        let title: String
    }

    func ztestPostDelete() {
        var model: ToDo?
        let todo = ToDo(id: nil, title: "Mow the lawn.")
        let url = URL("https://voice-frosty-19170.v2.vapor.cloud/todos")
        let expectation = self.expectation(description: "testPostDelete")
        post(model: todo, url: url) { serverModel in
            model = serverModel
            if let id = model?.id {
                let deleteUrl = URL("https://voice-frosty-19170.v2.vapor.cloud/todos/\(id)")
                self.delete(url: deleteUrl) {
                    expectation.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNotNil(model?.id)
    }
}
