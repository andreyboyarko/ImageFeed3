import UIKit

final class SplashViewController: UIViewController {
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private let oauth2Service = OAuth2Service.shared
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let _ = oauth2TokenStorage.token {
            switchToTabBarController()
        } else {
            performSegue(withIdentifier: ShowAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let authVC = navigationController.viewControllers.first as? AuthViewController
            else {
                fatalError("Failed to prepare for \(ShowAuthenticationScreenSegueIdentifier)")
            }
            authVC.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            self?.fetchOAuthToken(code)
        }
    }

    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.switchToTabBarController()
                case .failure(let error):
                    print("Ошибка при получении токена: \(error)")
                }
            }
        }
    }
}

