import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage() // синглтон

    private init() {}

    private let tokenKey = "oauth2Token"

    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let newValue = newValue {
                let success = KeychainWrapper.standard.set(newValue, forKey: tokenKey)
                if !success {
                    print("❌ Не удалось сохранить токен в Keychain")
                }
            } else {
                let success = KeychainWrapper.standard.removeObject(forKey: tokenKey)
                if !success {
                    print("⚠️ Не удалось удалить токен из Keychain")
                }
            }
        }
    }
}
