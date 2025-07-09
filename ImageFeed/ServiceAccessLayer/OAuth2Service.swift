
import Foundation

enum AuthServiceError: Error {
    case invalidRequest
    case invalidResponse
    case decodingError
}

struct OAuthTokenResponseBody: Codable {
    let access_token: String
    let token_type: String?
    let scope: String?
    let created_at: Int?
}

final class OAuth2Service {

    static let shared = OAuth2Service()

    private let urlSession = URLSession.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    private var task: URLSessionTask?
    private var lastCode: String?

    private init() {}

    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)

        // Если уже выполнялся запрос с таким же code — не делаем новый запрос
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        // Отменяем предыдущий запрос, если он есть
        task?.cancel()
        lastCode = code

        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.task = nil
                self.lastCode = nil

                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard
                    let httpResponse = response as? HTTPURLResponse,
                    200...299 ~= httpResponse.statusCode,
                    let data = data
                else {
                    completion(.failure(AuthServiceError.invalidResponse))
                    return
                }

                do {
                    let decodedResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    self.tokenStorage.token = decodedResponse.access_token
                    completion(.success(decodedResponse.access_token))
                } catch {
                    completion(.failure(AuthServiceError.decodingError))
                }
            }
        }
        self.task = task
        task.resume()
    }

    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        let urlString = "https://unsplash.com/oauth/token"
        guard let url = URL(string: urlString) else {
            assertionFailure("Failed to create URL")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            return nil
        }

        return request
    }
}

