import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    weak var delegate: ImagesListCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        cellImage.layer.cornerRadius = 16
        cellImage.layer.masksToBounds = true
        likeButton.accessibilityIdentifier = "likeButton"
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
        cellImage.stopSkeletonAnimation()
    }


    @IBAction private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }

    func setIsLiked(_ isLiked: Bool) {
        let imageResource: AppImageResource = isLiked ? .likeButtonOn : .likeButtonOff
        likeButton.setImage(UIImage(resource: imageResource), for: .normal)
    }

}
