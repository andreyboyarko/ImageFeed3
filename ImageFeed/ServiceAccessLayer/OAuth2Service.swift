import Foundation

struct OAuthTokenResponseBody: Codable {
    let access_token: String
    let token_type: String?
    let scope: String?
    let created_at: Int?
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}

    private let tokenStorage = OAuth2TokenStorage()

    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let urlString = "https://unsplash.com/oauth/token"
        guard let url = URL(string: urlString) else {
            print("❌ Ошибка: Невалидный URL \(urlString)")
            completion(.failure(NSError(domain: "OAuth2Service", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        print("✅ URL сформирован: \(url)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters = [
            "client_id": "YOUR_CLIENT_ID",
            "client_secret": "YOUR_CLIENT_SECRET",
            "redirect_uri": "YOUR_REDIRECT_URI",
            "code": code,
            "grant_type": "authorization_code"
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            print("✅ Параметры запроса сериализованы")
        } catch {
            print("❌ Ошибка сериализации параметров: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in

            if let error = error {
                print("❌ Сетевая ошибка: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Ошибка: Ответ сервера не HTTPURLResponse")
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "OAuth2Service", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                }
                return
            }
            print("✅ Получен HTTP статус код: \(httpResponse.statusCode)")

            guard (200...299).contains(httpResponse.statusCode) else {
                print("❌ Ошибка сервера с кодом: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "OAuth2Service", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server returned status code \(httpResponse.statusCode)"])))
                }
                return
            }

            guard let data = data else {
                print("❌ Ошибка: Получены пустые данные от сервера")
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "OAuth2Service", code: 0, userInfo: [NSLocalizedDescriptionKey: "Empty response data"])))
                }
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                print("✅ Токен получен: \(decodedResponse.access_token)")
                self?.tokenStorage.token = decodedResponse.access_token

                DispatchQueue.main.async {
                    completion(.success(decodedResponse.access_token))
                }
            } catch {
                print("❌ Ошибка декодирования: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}

