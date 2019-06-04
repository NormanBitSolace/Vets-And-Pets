import XCTest
@testable import Vets_And_Pets

class NavigatorPopoverTests: XCTestCase {

    override class func setUp() {
        super.setUp()
        Navigator.bundle = Bundle(for: NavigatorPopoverTests.self)
    }

    override func setUp() { }

    override func tearDown() { }

    private func createNavigator() -> Navigator {
        let navigator = Navigator()
        navigator.root(type: ButtonViewController.self, storyboardName: "Button") { vc in
            vc.loadViewIfNeeded()
            let _ = navigator.rootNavigationController.view
            let _ = vc.view
            vc.view.setNeedsLayout()
        }
        return navigator
    }


    func testPopoverUIViewControllerCompletion() {
        let nav = createNavigator()
        let anchor = (nav.topViewController as! ButtonViewController).button
        DispatchQueue.main.asyncAfter(deadline: .now()) {
        // Prevents message: Presenting view controllers on detached view controllers is discouraged
        // My guess is that it gives viewWillAppear enough time to be called
        // tried vc.view.setNeedsLayout(), vc.loadViewIfNeeded(), https://www.natashatherobot.com/ios-testing-view-controllers-swift
            let _: CompletionPopoverViewController = nav.presentPopover(anchor: anchor as Any, completion: { vc in
                XCTAssertTrue(vc.loaded)
                XCTAssertTrue(vc.didWillAppear)
                XCTAssertTrue(vc.didAppear)
                vc.dismiss(animated: false)
            })
        }
    }

    func testPopoverUIViewController() {
        let nav = createNavigator()
        let anchor = (nav.topViewController as! ButtonViewController).button
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let vc: PopoverViewController = nav.presentPopover(anchor: anchor as Any)
            XCTAssertNotNil(vc)
            XCTAssertEqual("PopoverViewController", String(describing: vc.classForCoder))
            vc.dismiss(animated: false)
        }
    }
}
