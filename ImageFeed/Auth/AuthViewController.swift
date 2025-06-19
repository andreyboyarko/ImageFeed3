import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    private let ShowWebViewSegueIdentifier = "ShowWebView"

    weak var delegate: AuthViewControllerDelegate?

    @IBOutlet var loginButton: UIButton!

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

        // Устанавливаем для всех основных состояний
        loginButton.setAttributedTitle(attributedTitle, for: .normal)
        loginButton.setAttributedTitle(attributedTitle, for: .highlighted)
        loginButton.setAttributedTitle(attributedTitle, for: .selected)
        loginButton.setAttributedTitle(attributedTitle, for: .disabled)

        // Обязательно отключаем изменение цвета текста при выделении
        loginButton.setTitleColor(UIColor.ypBlack, for: .highlighted)
        loginButton.setTitleColor(UIColor.ypBlack, for: .selected)
        loginButton.setTitleColor(UIColor.ypBlack, for: .disabled)

        // Устанавливаем радиус закругления, если нужно
        loginButton.layer.cornerRadius = 16
        loginButton.layer.masksToBounds = true
        
        // мне пришлось установить шрифта через код, так как шрифт через Interface Builder не отображался корректно в симуляторе
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
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        configureLoginButton()
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            OAuth2Service.shared.fetchOAuthToken(code) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let token):
                        print("✅ Получен токен: \(token)")
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

