
@testable import ImageFeed
import Foundation

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var viewDidLoadCalled = false
    weak var view: ProfileViewControllerProtocol?

    func viewDidLoad() {
        viewDidLoadCalled = true
    }
}
