import Foundation

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage() // синглтон

    private init() {}

    private let tokenKey = "oauth2Token"

    var token: String? {
        get {
            UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: tokenKey)
        }
    }
}
