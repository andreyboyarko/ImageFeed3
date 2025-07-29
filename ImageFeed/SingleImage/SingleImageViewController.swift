
import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    
    var imageURL: URL?
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImage()
    }
    
    private func setupImage() {
        guard let imageURL = imageURL else { return }
        
        imageView.kf.indicatorType = .activity
        
        imageView.kf.setImage(with: imageURL,
                              placeholder: UIImage(named: "placeholder")) { [weak self] result in
            switch result {
            case .success(let value):
                print("✅ Изображение загружено из: \(value.cacheType)")
                self?.rescaleAndCenterImageInScrollView(image: value.image)
            case .failure(let error):
                print("❌ Ошибка загрузки изображения: \(error)")
            }
        }
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        guard let scrollView = scrollView else { return }
        
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        
        // Масштабирование изображения под размер экрана
        let visibleRectSize = scrollView.bounds.size
        let widthScale = visibleRectSize.width / image.size.width
        let heightScale = visibleRectSize.height / image.size.height
        let scale = max(minZoomScale, min(maxZoomScale, min(widthScale, heightScale)))
        
        scrollView.setZoomScale(scale, animated: false)
        centerImage()
    }
    
    private func centerImage() {
        let scrollViewSize = scrollView.bounds.size
        let imageViewSize = imageView.frame.size
        
        let horizontalInset = max(0, (scrollViewSize.width - imageViewSize.width) / 2)
        let verticalInset = max(0, (scrollViewSize.height - imageViewSize.height) / 2)
        
        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset,
                                               bottom: verticalInset, right: horizontalInset)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}


//import UIKit
//
//final class SingleImageViewController: UIViewController {
//    var image: UIImage? {
//        didSet {
//            guard isViewLoaded, let image else { return }
//
//            imageView.image = image
//            imageView.frame.size = image.size
//            rescaleAndCenterImageInScrollView(image: image)
//        }
//    }
//
//    @IBOutlet private var scrollView: UIScrollView!
//    @IBOutlet private var imageView: UIImageView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        scrollView.minimumZoomScale = 0.1
//        scrollView.maximumZoomScale = 1.25
//
//        guard let image else { return }
//        imageView.image = image
//        imageView.frame.size = image.size
//        rescaleAndCenterImageInScrollView(image: image)
//    }
//
//    @IBAction private func didTapBackButton() {
//        dismiss(animated: true, completion: nil)
//    }
//    
//    @IBAction func didTapShareButton(_ sender: UIButton) {
//        guard let image else { return }
//        let share = UIActivityViewController(
//            activityItems: [image],
//            applicationActivities: nil
//        )
//        present(share, animated: true, completion: nil)
//    }
//    
//    private func rescaleAndCenterImageInScrollView(image: UIImage) {
//        let minZoomScale = scrollView.minimumZoomScale
//        let maxZoomScale = scrollView.maximumZoomScale
//        view.layoutIfNeeded()
//        let visibleRectSize = scrollView.bounds.size
//        let imageSize = image.size
//        let hScale = visibleRectSize.width / imageSize.width
//        let vScale = visibleRectSize.height / imageSize.height
//        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
//        scrollView.setZoomScale(scale, animated: false)
//        scrollView.layoutIfNeeded()
//        let newContentSize = scrollView.contentSize
//        let x = (newContentSize.width - visibleRectSize.width) / 2
//        let y = (newContentSize.height - visibleRectSize.height) / 2
//        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
//    }
//}
//
//extension SingleImageViewController: UIScrollViewDelegate {
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        imageView
//    }
//}
