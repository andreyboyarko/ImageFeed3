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

    private let tokenStorage = OAuth2TokenStorage.shared

    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let urlString = "https://unsplash.com/oauth/token"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "OAuth2Service", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
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
            completion(.failure(error))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  200...299 ~= httpResponse.statusCode,
                  let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "OAuth2Service", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                }
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                self?.tokenStorage.token = decodedResponse.access_token
                DispatchQueue.main.async {
                    completion(.success(decodedResponse.access_token))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}

