import UIKit

final class SplashViewController: UIViewController {
    
    private let oauth2Service = OAuth2Service.shared
    private let profileService = ProfileService.shared
    private let storage = OAuth2TokenStorage.shared
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = storage.token {
            fetchProfile(token)
        } else {
            showAuthController()
        }
    }
    
    private func showAuthController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            assertionFailure("Не удалось найти AuthViewController в storyboard")
            return
        }
        authVC.delegate = self
        authVC.modalPresentationStyle = .fullScreen
        present(authVC, animated: true)
    }
    
    private func fetchOAuthToken(_ code: String) {
        UIBlockingProgressHUD.show()
        
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                guard let self = self else { return }
                
                switch result {
                case .success(let token):
                    self.fetchProfile(token)
                case .failure(let error):
                    print("🚫 Ошибка получения токена: \(error)")
                    // Можешь тут показать alert
                }
            }
        }
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        
        ProfileService.shared.fetchProfile(token) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                UIBlockingProgressHUD.dismiss()
                
                switch result {
                case .success(let profile):
                    
                    // ⚡️ Стартуем загрузку аватарки, НЕ дожидаясь завершения
                    ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                    
                    // ✅ Переход к галерее
                    self.switchToTabBarController()
                    
                case .failure(let error):
                    print("🚫 Ошибка загрузки профиля: \(error)")
                    // Здесь можешь добавить alert для пользователя
                }
            }
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Невозможно получить window")
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController else {
            assertionFailure("Не удалось найти TabBarController в storyboard")
            return
        }
        
        window.rootViewController = tabBarController
    }
}


extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        fetchOAuthToken(code)
    }
}




//import UIKit
//
//final class SplashViewController: UIViewController {
//    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
//    
//    private let oauth2TokenStorage = OAuth2TokenStorage.shared
//    private let oauth2Service = OAuth2Service.shared
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        if let _ = oauth2TokenStorage.token {
//            switchToTabBarController()
//        } else {
//            performSegue(withIdentifier: ShowAuthenticationScreenSegueIdentifier, sender: nil)
//        }
//    }
//    
//    private func switchToTabBarController() {
//        guard let window = UIApplication.shared.windows.first else {
//            fatalError("Invalid Configuration")
//        }
//        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
//            .instantiateViewController(withIdentifier: "TabBarViewController")
//        window.rootViewController = tabBarController
//    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
//            guard
//                let navigationController = segue.destination as? UINavigationController,
//                let authVC = navigationController.viewControllers.first as? AuthViewController
//            else {
//                fatalError("Failed to prepare for \(ShowAuthenticationScreenSegueIdentifier)")
//            }
//            authVC.delegate = self
//        } else {
//            super.prepare(for: segue, sender: sender)
//        }
//    }
//}
//
//extension SplashViewController: AuthViewControllerDelegate {
//    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
//        dismiss(animated: true) { [weak self] in
//            self?.fetchOAuthToken(code)
//        }
//    }
//
//    private func fetchOAuthToken(_ code: String) {
//        oauth2Service.fetchOAuthToken(code) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success:
//                    self?.switchToTabBarController()
//                case .failure(let error):
//                    print("Ошибка при получении токена: \(error)")
//                }
//            }
//        }
//    }
//}
//
