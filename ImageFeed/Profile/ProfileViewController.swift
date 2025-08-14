import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
    func updateUI()  // Логику доабвлю позже
}

final class ProfileViewController: UIViewController {
    
    private var presenter: ProfilePresenterProtocol!

    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }

    // MARK: - UI Elements

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "avatar"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let loginNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "YP Gray")
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let logoutButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "exite_button"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = "exitButton"
        return button
    }()

    // MARK: - Observer

    private var profileImageServiceObserver: NSObjectProtocol?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        view.backgroundColor = UIColor(named: "YP Black")

        setupViews()
        setupConstraints()
        setupActions()
        updateProfileDetails()
        avatarImageView.startSkeletonAnimation(cornerRadius: 35)
        nameLabel.startSkeletonAnimation()
        loginNameLabel.startSkeletonAnimation()
        descriptionLabel.startSkeletonAnimation()
        nameLabel.accessibilityIdentifier = "usernameLabel"

        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateAvatar()
        }

        let cache = ImageCache.default
        cache.memoryStorage.config.totalCostLimit = 300 * 1024 * 1024
        cache.diskStorage.config.sizeLimit = 1000 * 1000 * 1000

        updateAvatar()
    }

    // MARK: - Setup UI

    private func setupViews() {
        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),

            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 20),

            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),

            descriptionLabel.leadingAnchor.constraint(equalTo: loginNameLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
        ])
    }

    private func setupActions() {
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
    }

    private func updateProfileDetails() {
        guard let profile = ProfileService.shared.profile else {
            print("❌ Профиль не найден")
            return
        }

        nameLabel.text = profile.name.isEmpty ? profile.username : profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio ?? ""
    }

    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }

        let processor = RoundCornerImageProcessor(cornerRadius: 35)

        avatarImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholder.jpeg"),
            options: [.processor(processor)]
        ) { result in
            switch result {
            case .success(let value):
                print("✅ Аватар загружен из: \(value.cacheType)")
            case .failure(let error):
                print("❌ Ошибка загрузки аватара: \(error)")
            }
        }
    }

    // MARK: - Actions

    @objc private func didTapLogoutButton() {
        showLogoutAlert()
    }

    private func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Нет", style: .cancel))
        alert.addAction(UIAlertAction(title: "Да", style: .destructive) { _ in
            self.logout()
        })

        present(alert, animated: true)
    }

    private func logout() {
        ProfileLogoutService.shared.logout()
        OAuth2TokenStorage.shared.token = nil

        guard let window = UIApplication.shared.windows.first else { return }
        window.rootViewController = SplashViewController()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowProfile" {
            let profileVC = segue.destination as! ProfileViewController
            let presenter = ProfilePresenter()
            profileVC.configure(presenter)
        }
    }

    
}
extension ProfileViewController: ProfileViewControllerProtocol {
    func updateUI() {
        // Логику доабвлю позже
    }
}
