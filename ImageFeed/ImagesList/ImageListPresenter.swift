
protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
}

final class ImageListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?

    func viewDidLoad() {
        // Логику доабвлю позже
    }
}

