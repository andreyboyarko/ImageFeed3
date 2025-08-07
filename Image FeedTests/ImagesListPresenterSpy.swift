
@testable import ImageFeed
import Foundation

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var viewDidLoadCalled = false
    weak var view: ImagesListViewControllerProtocol?

    func viewDidLoad() {
        viewDidLoadCalled = true
    }
}

