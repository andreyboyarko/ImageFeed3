import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var blockingWindow: UIWindow?

    static func show() {
        blockingWindow = UIWindow(frame: UIScreen.main.bounds)
        blockingWindow?.rootViewController = UIViewController()
        blockingWindow?.windowLevel = .alert + 1
        blockingWindow?.makeKeyAndVisible()
        ProgressHUD.animationType = .circleStrokeSpin
        ProgressHUD.animate()
    }

    static func dismiss() {
        ProgressHUD.dismiss()
        blockingWindow?.isHidden = true
        blockingWindow = nil
    }
}
