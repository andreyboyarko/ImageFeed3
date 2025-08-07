//@testable import ImageFeed
//import XCTest
//
//final class ProfileViewControllerTests: XCTestCase {
//
//    func testViewControllerCallsViewDidLoad() {
//        // given
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let viewController = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
//        let presenterSpy = ProfilePresenterSpy()
//        viewController.configure(presenterSpy)
//
//        // when
//        _ = viewController.view  // триггерим загрузку view (вызовет viewDidLoad)
//
//        // then
//        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
//    }
//}

import XCTest
@testable import ImageFeed

final class ProfileViewControllerTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // given
        let presenterSpy = ProfilePresenterSpy()
        let viewController = ProfileViewController()
        viewController.configure(presenterSpy)

        // when
        _ = viewController.view  // принудительно вызываем viewDidLoad

        // then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled, "Метод viewDidLoad не был вызван у презентера")
    }
}


