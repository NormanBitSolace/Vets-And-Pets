import XCTest
@testable import Vets_And_Pets

class NavigatorChildTests: XCTestCase {

    override class func setUp() {
        super.setUp()
        Navigator.bundle = Bundle(for: NavigatorChildTests.self)
    }

    override func setUp() { }

    override func tearDown() { }

    private func createNavigator() -> Navigator {
        let navigator = Navigator()
        navigator.root(type: OrangeViewController.self, storyboardName: "Orange") { vc in
        }
        return navigator
    }

    func testRemoveChildUIViewControllerFromTopInferred() {
        let nav = createNavigator()
        let topVC = nav.topViewController!

        let vc: UIViewController = nav.addChildViewController()
        XCTAssertNotNil(vc)
        XCTAssertEqual("UIViewController", String(describing: vc.classForCoder))
        XCTAssertTrue(topVC.view.subviews.contains(vc.view))
        nav.removeChildViewController(childViewController: vc) {
            XCTAssertFalse(topVC.view.subviews.contains(vc.view))
        }
    }
    func testRemoveChildUIViewControllerFromTop() {
        let nav = createNavigator()
        let topVC = nav.topViewController!
       let cvc: OrangeViewController = nav.addChildViewController()
        XCTAssertNotNil(cvc)
        XCTAssertEqual("OrangeViewController", String(describing: cvc.classForCoder))
        XCTAssertTrue(topVC.view.subviews.contains(cvc.view))
        nav.removeChildViewController(childViewController: cvc) {
            XCTAssertFalse(topVC.view.subviews.contains(cvc.view))
        }
   }

    func testChildUIViewController() {
        let vcInferred = createNavigator().addChildViewController()
        XCTAssertNotNil(vcInferred)
        XCTAssertEqual("UIViewController", String(describing: vcInferred.classForCoder))

        let vc: UIViewController = createNavigator().addChildViewController()
        XCTAssertNotNil(vc)
        XCTAssertEqual("UIViewController", String(describing: vc.classForCoder))
    }

    func testChildCustomViewController() {
        let vc: OrangeViewController = createNavigator().addChildViewController()
        XCTAssertNotNil(vc)
        XCTAssertEqual("OrangeViewController", String(describing: vc.classForCoder))
    }

    func testChildWithStoryboard() {
        let vc: OrangeViewController = createNavigator().addChildViewController(storyboardName: "Orange")
        XCTAssertNotNil(vc)
        XCTAssertEqual("OrangeViewController", String(describing: vc.classForCoder))
        let unspecifiedVC = createNavigator().addChildViewController(storyboardName: "Orange")
        XCTAssertNotNil(unspecifiedVC)
        XCTAssertEqual("OrangeViewController", String(describing: unspecifiedVC.classForCoder))
    }

    func testChildWithUnassociatedStoryboard() {
        let vc: UIViewController = createNavigator().addChildViewController(storyboardName: "Unassociated")
        XCTAssertNotNil(vc)
        XCTAssertEqual("UIViewController", String(describing: vc.classForCoder))
        let unspecifiedVC = createNavigator().addChildViewController(storyboardName: "Unassociated")
        XCTAssertNotNil(unspecifiedVC)
        XCTAssertEqual("UIViewController", String(describing: unspecifiedVC.classForCoder))
    }

    func testChildUIViewControllerConfigure() {
        createNavigator().addChildViewController() { vc in
            XCTAssertNotNil(vc)
            XCTAssertEqual("UIViewController", String(describing: vc.classForCoder))
        }

        createNavigator().addChildViewController() { vc in
            XCTAssertNotNil(vc)
            XCTAssertEqual("UIViewController", String(describing: vc.classForCoder))
        }
    }

    func testChildCustomViewControllerConfigure() {
        let _: OrangeViewController = createNavigator().addChildViewController() { vc in
            XCTAssertNotNil(vc)
            XCTAssertEqual("OrangeViewController", String(describing: vc.classForCoder))
        }
    }

    func testChildWithStoryboardConfigure() {
        let _: OrangeViewController = createNavigator().addChildViewController(storyboardName: "Orange") { vc in
            XCTAssertNotNil(vc)
            XCTAssertEqual("OrangeViewController", String(describing: vc.classForCoder))
        }
        createNavigator().addChildViewController(storyboardName: "Orange") { vc in
            XCTAssertNotNil(vc)
            XCTAssertEqual("OrangeViewController", String(describing: vc.classForCoder))
        }
    }

    func testChildWithUnassociatedStoryboardConfigure() {
        let _: UIViewController = createNavigator().addChildViewController(storyboardName: "Unassociated") { vc in
            XCTAssertNotNil(vc)
            XCTAssertEqual("UIViewController", String(describing: vc.classForCoder))
        }
        createNavigator().addChildViewController(storyboardName: "Unassociated") { vc in
            XCTAssertNotNil(vc)
            XCTAssertEqual("UIViewController", String(describing: vc.classForCoder))
        }
    }
}
