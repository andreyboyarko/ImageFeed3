@testable import ImageFeed
import Foundation

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: WebViewPresenterProtocol?
    var loadRequestCalled: Bool = false

    func load(request: URLRequest) {
        loadRequestCalled = true
    }

    func setProgressValue(_ newValue: Float) {
        // пустая реализация для Spy
    }

    func setProgressHidden(_ isHidden: Bool) {
        // пустая реализация для Spy
    }
}

