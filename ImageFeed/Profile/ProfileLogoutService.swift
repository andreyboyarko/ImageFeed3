
import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() {}

    func logout() {
        clearToken()
        cleanCookies()
    }

    private func clearToken() {
        OAuth2TokenStorage.shared.token = nil
    }

    private func cleanCookies() {
        // Удаляем все cookies
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)

        // Удаляем все данные из WKWebView (включая кеш, localStorage и т.д.)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}

