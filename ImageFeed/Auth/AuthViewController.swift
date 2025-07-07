
import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    private let ShowWebViewSegueIdentifier = "ShowWebView"

    weak var delegate: AuthViewControllerDelegate?

    @IBOutlet var loginButton: UIButton!

    // Добавляем сервис
    private let oauth2Service = OAuth2Service.shared

    private func configureLoginButton() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 22
        paragraphStyle.maximumLineHeight = 22
        paragraphStyle.alignment = .center

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .bold),
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.ypBlack
        ]

        let attributedTitle = NSAttributedString(string: "Войти", attributes: attributes)

        loginButton.setAttributedTitle(attributedTitle, for: .normal)
        loginButton.setAttributedTitle(attributedTitle, for: .highlighted)
        loginButton.setAttributedTitle(attributedTitle, for: .selected)
        loginButton.setAttributedTitle(attributedTitle, for: .disabled)

        loginButton.setTitleColor(UIColor.ypBlack, for: .highlighted)
        loginButton.setTitleColor(UIColor.ypBlack, for: .selected)
        loginButton.setTitleColor(UIColor.ypBlack, for: .disabled)

        loginButton.layer.cornerRadius = 16
        loginButton.layer.masksToBounds = true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowWebViewSegueIdentifier {
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black")

            if let webVC = segue.destination as? WebViewViewController {
                webVC.delegate = self
            }
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let backImage = UIImage(named: "nav_back_button") {
            navigationController?.navigationBar.backIndicatorImage = backImage
            navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        } else {
            print("❌ Не удалось загрузить изображение 'nav_back_button'")
        }

        configureLoginButton()
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }

            UIBlockingProgressHUD.show() // Блокируем UI и показываем индикатор загрузки

            self.oauth2Service.fetchOAuthToken(code) { result in
                DispatchQueue.main.async {
                    UIBlockingProgressHUD.dismiss() // Скрываем индикатор и разблокируем UI

                    switch result {
                    case .success:
                        self.delegate?.authViewController(self, didAuthenticateWithCode: code)
                    case .failure(let error):
                        print("🚫 Ошибка получения токена: \(error)")
                    }
                }
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}


//import UIKit
//import ProgressHUD
//
//protocol AuthViewControllerDelegate: AnyObject {
//    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
//}
//
//final class AuthViewController: UIViewController {
//    private let ShowWebViewSegueIdentifier = "ShowWebView"
//
//    weak var delegate: AuthViewControllerDelegate?
//
//    @IBOutlet var loginButton: UIButton!
//
//    // Добавляем сервис
//    private let oauth2Service = OAuth2Service.shared
//
//    private func configureLoginButton() {
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.minimumLineHeight = 22
//        paragraphStyle.maximumLineHeight = 22
//        paragraphStyle.alignment = .center
//
//        let attributes: [NSAttributedString.Key: Any] = [
//            .font: UIFont.systemFont(ofSize: 17, weight: .bold),
//            .paragraphStyle: paragraphStyle,
//            .foregroundColor: UIColor.ypBlack
//        ]
//
//        let attributedTitle = NSAttributedString(string: "Войти", attributes: attributes)
//
//        loginButton.setAttributedTitle(attributedTitle, for: .normal)
//        loginButton.setAttributedTitle(attributedTitle, for: .highlighted)
//        loginButton.setAttributedTitle(attributedTitle, for: .selected)
//        loginButton.setAttributedTitle(attributedTitle, for: .disabled)
//
//        loginButton.setTitleColor(UIColor.ypBlack, for: .highlighted)
//        loginButton.setTitleColor(UIColor.ypBlack, for: .selected)
//        loginButton.setTitleColor(UIColor.ypBlack, for: .disabled)
//
//        loginButton.layer.cornerRadius = 16
//        loginButton.layer.masksToBounds = true
//    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == ShowWebViewSegueIdentifier {
//            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
//            navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black")
//
//            if let webVC = segue.destination as? WebViewViewController {
//                webVC.delegate = self
//            }
//        } else {
//            super.prepare(for: segue, sender: sender)
//        }
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
//        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
//        configureLoginButton()
//    }
//}
//
//extension AuthViewController: WebViewViewControllerDelegate {
//    
//    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
//        vc.dismiss(animated: true) { [weak self] in
//            guard let self = self else { return }
//            
//            UIBlockingProgressHUD.show() // Блокируем UI и показываем индикатор загрузки
//            
//            self.oauth2Service.fetchOAuthToken(code) { result in
//                DispatchQueue.main.async {
//                    UIBlockingProgressHUD.dismiss() // Скрываем индикатор и разблокируем UI
//                    
//                    switch result {
//                    case .success:
//                        self.delegate?.authViewController(self, didAuthenticateWithCode: code)
//                    case .failure(let error):
//                        print("🚫 Ошибка получения токена: \(error)")
//                        // Если хочешь, можешь тут добавить alert для пользователя
//                    }
//                }
//            }
//        }
//    }
//
//    
//    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
//        dismiss(animated: true)
//    }
//}
//
