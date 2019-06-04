import XCTest
@testable import Vets_And_Pets

class NavigatorPushTests: XCTestCase {

    override class func setUp() {
        super.setUp()
        Navigator.bundle = Bundle(for: NavigatorPushTests.self)
    }

    override func setUp() { }

    override func tearDown() { }

    private func createNavigator() -> Navigator {
        let navigator = Navigator()
        navigator.root(type: OrangeViewController.self, storyboardName: "Orange") { vc in
            // Testing fix, see: https://www.natashatherobot.com/ios-testing-view-controllers-swift/
            let _ = navigator.rootNavigationController.view
            let _ = vc.view
        }
        return navigator
    }

    func testPushUIViewControllerCompletion() {
        let _: CompletionViewController = createNavigator().push(completion: { vc in
            XCTAssertTrue(vc.loaded)
            XCTAssertTrue(vc.didWillAppear)
            XCTAssertTrue(vc.didAppear)
        })
    }

    func testPushUIInferredViewController() {
        let vcInferred = createNavigator().push()
        XCTAssertNotNil(vcInferred)
        XCTAssertEqual("UIViewController", String(describing: vcInferred.classForCoder))
    }
    func testPushUIViewController() {
        let vc: UIViewController = createNavigator().push()
        XCTAssertNotNil(vc)
        XCTAssertEqual("UIViewController", String(describing: vc.classForCoder))
    }

    func testPushCustomViewController() {
        let vc: OrangeViewController = createNavigator().push()
        XCTAssertNotNil(vc)
        XCTAssertEqual("OrangeViewController", String(describing: vc.classForCoder))
    }

    func testPushWithStoryboard() {
        let vc: OrangeViewController = createNavigator().push(storyboardName: "Orange")
        XCTAssertNotNil(vc)
        XCTAssertEqual("OrangeViewController", String(describing: vc.classForCoder))
    }
    func testPushWithStoryboardInferred() {
        let unspecifiedVC = createNavigator().push(storyboardName: "Orange")
        XCTAssertNotNil(unspecifiedVC)
        XCTAssertEqual("OrangeViewController", String(describing: unspecifiedVC.classForCoder))
    }

    func testPushWithUnassociatedStoryboard() {
        let vc: UIViewController = createNavigator().push(storyboardName: "Unassociated")
        XCTAssertNotNil(vc)
        XCTAssertEqual("UIViewController", String(describing: vc.classForCoder))
    }
    func testPushWithUnassociatedStoryboardInferred() {
        let unspecifiedVC = createNavigator().push(storyboardName: "Unassociated")
        XCTAssertNotNil(unspecifiedVC)
        XCTAssertEqual("UIViewController", String(describing: unspecifiedVC.classForCoder))
    }

    func testPushUIViewControllerConfigure() {
        createNavigator().push() { vc in
            XCTAssertNotNil(vc)
            XCTAssertEqual("UIViewController", String(describing: vc.classForCoder))
        }
    }

    func testPushCustomViewControllerConfigure() {
        let _: OrangeViewController = createNavigator().push() { vc in
            XCTAssertNotNil(vc)
            XCTAssertEqual("OrangeViewController", String(describing: vc.classForCoder))
        }
    }

    func testPushWithStoryboardConfigure() {
        let _: OrangeViewController = createNavigator().push(storyboardName: "Orange") { vc in
            XCTAssertNotNil(vc)
            XCTAssertEqual("OrangeViewController", String(describing: vc.classForCoder))
        }
    }
    func testPushWithStoryboardConfigureInferred() {
        createNavigator().push(storyboardName: "Orange") { vc in
            XCTAssertNotNil(vc)
            XCTAssertEqual("OrangeViewController", String(describing: vc.classForCoder))
        }
    }

    func testPushWithUnassociatedStoryboardConfigureInferred() {
        let _: UIViewController = createNavigator().push(storyboardName: "Unassociated") { vc in
            XCTAssertNotNil(vc)
            XCTAssertEqual("UIViewController", String(describing: vc.classForCoder))
        }
    }
    func testPushWithUnassociatedStoryboardConfigure() {
        createNavigator().push(storyboardName: "Unassociated") { vc in
            XCTAssertNotNil(vc)
            XCTAssertEqual("UIViewController", String(describing: vc.classForCoder))
        }
    }
}
