import Foundation

enum Constants {
    static let accessKey = "9juzreJeOMMCDBM_OKpb75_UB4WrY_eoeZ5IIeQHZ14"
    static let secretKey = "wLFbhfuPhzt9aLa8VXwmEXt0iAvEakfIn_CuFsFrlWs"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL: URL = {
            guard let url = URL(string: "https://api.unsplash.com") else {
                fatalError("Invalid defaultBaseURL")
            }
            return url
        }()
}
