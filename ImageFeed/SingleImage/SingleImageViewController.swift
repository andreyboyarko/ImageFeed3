
import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    
    var imageURL: URL?
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        scrollView.delegate = self

        guard let imageURL = imageURL else { return }

        UIBlockingProgressHUD.show() // 👈 показываем лоадер

        imageView.kf.setImage(with: imageURL, placeholder: nil) { [weak self] result in
            UIBlockingProgressHUD.dismiss() // 👈 убираем лоадер
            switch result {
            case .success:
                break // всё ок
            case .failure:
                self?.showErrorAlert() // показать ошибку
            }
        }
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Не удалось загрузить изображение.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }

    private func setupImage() {
        guard let imageURL = imageURL else { return }

        UIBlockingProgressHUD.show()

        imageView.kf.setImage(with: imageURL,
                              placeholder: UIImage(named: "placeholder")) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self = self else { return }

            switch result {
            case .success(let value):
                self.imageView.image = value.image
                self.imageView.frame.size = value.image.size 
                self.rescaleAndCenterImageInScrollView(image: value.image)
            case .failure:
                self.showError()
            }
        }
    }

    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale

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

    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image = imageView.image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }

    private func showError() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Не надо", style: .cancel))
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.setupImage()
        })

        present(alert, animated: true)
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
