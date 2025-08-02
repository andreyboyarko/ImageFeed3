
import UIKit

enum AppImageResource: String {
    case likeButtonOn = "like_button_on"
    case likeButtonOff = "like_button_off"
}

extension UIImage {
    convenience init(resource: AppImageResource) {
        self.init(named: resource.rawValue)!
    }
}
