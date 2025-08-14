
@testable import ImageFeed
import XCTest

final class ImagesListViewControllerTests: XCTestCase {

    func testViewControllerCallsViewDidLoad() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenterSpy = ImagesListPresenterSpy()
        viewController.configure(presenterSpy)

        // when
        _ = viewController.view  // триггерим вызов viewDidLoad()

        // then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }
}

