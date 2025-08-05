import Foundation

final class ProfileImageService {

    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name("ProfileImageProviderDidChange")

    private init() {}

    private var task: URLSessionTask?
    private(set) var avatarURL: String?

    struct UserResult: Codable {
        let profileImage: ProfileImage

        enum CodingKeys: String, CodingKey {
            case profileImage = "profile_image"
        }
    }

    struct ProfileImage: Codable {
        let small: String
    }

    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {

        task?.cancel()

        guard let token = OAuth2TokenStorage.shared.token else {
            print("❌ Нет токена для запроса аватарки")
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            print("❌ Неверный URL для запроса аватарки")
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            defer { self?.task = nil }

            if let error = error {
                completion(.failure(error))
                return
            }

            guard
                let data = data,
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }

            do {
                let result = try JSONDecoder().decode(UserResult.self, from: data)
                let avatarURL = result.profileImage.small
                self?.avatarURL = avatarURL

                // Публикуем уведомление
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": avatarURL]
                )

                completion(.success(avatarURL))
            } catch {
                completion(.failure(error))
            }
        }

        task?.resume()
    }
}
