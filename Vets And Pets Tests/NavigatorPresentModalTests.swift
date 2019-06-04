import XCTest
@testable import Vets_And_Pets

class NavigatorPresentModalTests: XCTestCase {

    override class func setUp() {
        super.setUp()
        Navigator.bundle = Bundle(for: NavigatorPresentModalTests.self)
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

    func testPresentModalUIViewControllerCompletion() {
        let _: CompletionViewController = createNavigator().presentModal(completion: { vc in
            XCTAssertTrue(vc.loaded)
            XCTAssertTrue(vc.didWillAppear)
            XCTAssertTrue(vc.didAppear)
        })
    }

    func testPresentModalUIViewControllerInferred() {
        let vcInferred = createNavigator().presentModal()
        XCTAssertNotNil(vcInferred)
        XCTAssertNil(vcInferred.navigationController)
        XCTAssertEqual("UIViewController", String(describing: vcInferred.classForCoder))
    }
    func testPresentModalUIViewController() {
        let vc: UIViewController = createNavigator().presentModal()
        XCTAssertNotNil(vc)
        XCTAssertNil(vc.navigationController)
        XCTAssertEqual("UIViewController", String(describing: vc.classForCoder))
    }

    func testPresentModalUIViewControllerWrapInferred() {
        let vcInferred = createNavigator().presentModal(wrap: true)
        XCTAssertNotNil(vcInferred)
        XCTAssertNotNil(vcInferred.navigationController)
        XCTAssertEqual("UIViewController", String(describing: vcInferred.classForCoder))
    }
    func testPresentModalUIViewControllerWrap() {
        let vc: UIViewController = createNavigator().presentModal(wrap: true)
        XCTAssertNotNil(vc)
        XCTAssertNotNil(vc.navigationController)
       XCTAssertEqual("UIViewController", String(describing: vc.classForCoder))
    }

    func testPresentModalCustomViewController() {
        let vc: OrangeViewController = createNavigator().presentModal()
        XCTAssertNotNil(vc)
        XCTAssertNil(vc.navigationController)
        XCTAssertEqual("OrangeViewController", String(describing: vc.classForCoder))
    }

    func testPresentModalCustomViewControllerWrap() {
        let vc: OrangeViewController = createNavigator().presentModal(wrap: true)
        XCTAssertNotNil(vc)
        XCTAssertNotNil(vc.navigationController)
        XCTAssertEqual("OrangeViewController", String(describing: vc.classForCoder))
    }

    func testPresentModalWithStoryboard() {
        let vc: OrangeViewController = createNavigator().presentModal(storyboardName: "Orange")
        XCTAssertNotNil(vc)
        XCTAssertNil(vc.navigationController)
        XCTAssertEqual("OrangeViewController", String(describing: vc.classForCoder))
    }
    func testPresentModalWithStoryboardInferred() {
        let unspecifiedVC = createNavigator().presentModal(storyboardName: "Orange")
        XCTAssertNotNil(unspecifiedVC)
        XCTAssertEqual("OrangeViewController", String(describing: unspecifiedVC.classForCoder))
    }

    func testPresentModalWithStoryboardWrap() {
        let vc: OrangeViewController = createNavigator().presentModal(storyboardName: "Orange", wrap: true)
        XCTAssertNotNil(vc)
        XCTAssertNotNil(vc.navigationController)
        XCTAssertEqual("OrangeViewController", String(describing: vc.classForCoder))
    }
    func testPresentModalWithStoryboardWrapInferred() {
        let unspecifiedVC = createNavigator().presentModal(storyboardName: "Orange")
        XCTAssertNotNil(unspecifiedVC)
        XCTAssertEqual("OrangeViewController", String(describing: unspecifiedVC.classForCoder))
    }

    func testPresentModalWithUnassociatedStoryboard() {
        let vc: UIViewController = createNavigator().presentModal(storyboardName: "Unassociated")
        XCTAssertNotNil(vc)
        XCTAssertNil(vc.navigationController)
        XCTAssertEqual("UIViewController", String(describing: vc.classForCoder))
    }
    func testPresentModalWithUnassociatedStoryboardInferred() {
        let unspecifiedVC = createNavigator().presentModal(storyboardName: "Unassociated")
        XCTAssertNotNil(unspecifiedVC)
        XCTAssertEqual("UIViewController", String(describing: unspecifiedVC.classForCoder))
    }

    func testPresentModalWithUnassociatedStoryboardWrap() {
        let vc: UIViewController = createNavigator().presentModal(storyboardName: "Unassociated", wrap: true)
        XCTAssertNotNil(vc)
        XCTAssertNotNil(vc.navigationController)
        XCTAssertEqual("UIViewController", String(describing: vc.classForCoder))
    }
    func testPresentModalWithUnassociatedStoryboardWrapInferred() {
        let unspecifiedVC = createNavigator().presentModal(storyboardName: "Unassociated", wrap: true)
        XCTAssertNotNil(unspecifiedVC)
        XCTAssertNotNil(unspecifiedVC.navigationController)
        XCTAssertEqual("UIViewController", String(describing: unspecifiedVC.classForCoder))
    }

    func testPresentModalUIViewControllerConfigure() {
        createNavigator().presentModal() { vc in
            XCTAssertNotNil(vc)
            XCTAssertNil(vc.navigationController)
            XCTAssertEqual("UIViewController", String(describing: vc.classForCoder))
        }
    }

    func testPresentModalUIViewControllerConfigureWrap() {
        createNavigator().presentModal(wrap: true) { vc in
            XCTAssertNotNil(vc)
            XCTAssertNotNil(vc.navigationController)
            XCTAssertEqual("UIViewController", String(describing: vc.classForCoder))
        }
    }

    func testPresentModalCustomViewControllerConfigure() {
        let _: OrangeViewController = createNavigator().presentModal() { vc in
            XCTAssertNotNil(vc)
            XCTAssertNil(vc.navigationController)
            XCTAssertEqual("OrangeViewController", String(describing: vc.classForCoder))
        }
    }

    func testPresentModalCustomViewControllerConfigureWrap() {
        let _: OrangeViewController = createNavigator().presentModal(wrap: true) { vc in
            XCTAssertNotNil(vc)
            XCTAssertNotNil(vc.navigationController)
            XCTAssertEqual("OrangeViewController", String(describing: vc.classForCoder))
        }
    }

    func testPresentModalWithStoryboardConfigure() {
        let _: OrangeViewController = createNavigator().presentModal(storyboardName: "Orange") { vc in
            XCTAssertNotNil(vc)
            XCTAssertNil(vc.navigationController)
            XCTAssertEqual("OrangeViewController", String(describing: vc.classForCoder))
        }
    }
    func testPresentModalWithStoryboardConfigureInferred() {
        createNavigator().presentModal(storyboardName: "Orange") { vc in
            XCTAssertNotNil(vc)
            XCTAssertNil(vc.navigationController)
            XCTAssertEqual("OrangeViewController", String(describing: vc.classForCoder))
        }
    }

    func testPresentModalWithStoryboardConfigureWrap() {
        let _: OrangeViewController = createNavigator().presentModal(storyboardName: "Orange", wrap: true) { vc in
            XCTAssertNotNil(vc)
            XCTAssertNotNil(vc.navigationController)
            XCTAssertEqual("OrangeViewController", String(describing: vc.classForCoder))
        }
    }
    func testPresentModalWithStoryboardConfigureWrapInferred() {
        createNavigator().presentModal(storyboardName: "Orange", wrap: true) { vc in
            XCTAssertNotNil(vc)
            XCTAssertNotNil(vc.navigationController)
            XCTAssertEqual("OrangeViewController", String(describing: vc.classForCoder))
        }
    }

    func testPresentModalWithUnassociatedStoryboardConfigure() {
        let _: UIViewController = createNavigator().presentModal(storyboardName: "Unassociated") { vc in
            XCTAssertNotNil(vc)
            XCTAssertNil(vc.navigationController)
            XCTAssertEqual("UIViewController", String(describing: vc.classForCoder))
        }
    }
    func testPresentModalWithUnassociatedStoryboardConfigureInferred() {
        createNavigator().presentModal(storyboardName: "Unassociated") { vc in
            XCTAssertNotNil(vc)
            XCTAssertNil(vc.navigationController)
            XCTAssertEqual("UIViewController", String(describing: vc.classForCoder))
        }
    }

    func testPresentModalWithUnassociatedStoryboardConfigureWrap() {
        let _: UIViewController = createNavigator().presentModal(storyboardName: "Unassociated", wrap: true) { vc in
            XCTAssertNotNil(vc)
            XCTAssertNotNil(vc.navigationController)
            XCTAssertEqual("UIViewController", String(describing: vc.classForCoder))
        }
    }
    func testPresentModalWithUnassociatedStoryboardConfigureWrapInferred() {
        createNavigator().presentModal(storyboardName: "Unassociated", wrap: true) { vc in
            XCTAssertNotNil(vc)
            XCTAssertNotNil(vc.navigationController)
            XCTAssertEqual("UIViewController", String(describing: vc.classForCoder))
        }
    }
}
