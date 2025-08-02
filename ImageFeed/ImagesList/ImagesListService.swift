import Foundation

final class ImagesListService {
    static let shared = ImagesListService()
    private init() {}
    
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage = 0
    private var isFetching = false
    private let perPage = 10
    
    private var task: URLSessionTask?
    
    private let iso8601DateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()

    private func convert(photoResult: PhotoResult) -> Photo {
        let date = iso8601DateFormatter.date(from: photoResult.createdAt)
        let size = CGSize(width: photoResult.width, height: photoResult.height)
        
        return Photo(
            id: photoResult.id,
            size: size,
            createdAt: date,
            welcomeDescription: photoResult.description,
            thumbImageURL: photoResult.urls.thumb,
            largeImageURL: photoResult.urls.full,
            isLiked: photoResult.likedByUser
        )
    }
    
    func fetchPhotosNextPage() {
        guard !isFetching else { return }
        isFetching = true
        let nextPage = lastLoadedPage + 1
        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(nextPage)&per_page=\(perPage)") else { return }
        
        var request = URLRequest(url: url)
        request.setValue("Client-ID \(Constants.accessKey)", forHTTPHeaderField: "Authorization")
        
        task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                defer { self.isFetching = false }
                
                if let error = error {
                    print("[fetchPhotosNextPage | ImagesListService]: request error \(error.localizedDescription), page: \(nextPage)")
                    return
                }
                
                guard let data = data else {
                    print("[fetchPhotosNextPage | ImagesListService]: no data received, page: \(nextPage)")
                    return
                }
                
                do {
                    let photoResults = try JSONDecoder().decode([PhotoResult].self, from: data)
                    let newPhotos = photoResults.map { self.convert(photoResult: $0) }
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                } catch {
                    print("""
                    [fetchPhotosNextPage | ImagesListService]: decoding error \(error.localizedDescription)
                    page: \(nextPage)
                    raw data: \(String(data: data, encoding: .utf8) ?? "nil")
                    """)
                }
            }
        }
        task?.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else {
            let error = NSError(domain: "Invalid URL", code: 0)
            print("[changeLike | ImagesListService]: invalid URL for photoId: \(photoId), isLike: \(isLike)")
            completion(.failure(error))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(OAuth2TokenStorage.shared.token!)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    print("[changeLike | ImagesListService]: request error \(error.localizedDescription), photoId: \(photoId), isLike: \(isLike)")
                    completion(.failure(error))
                    return
                }
                
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: !photo.isLiked
                    )
                    self.photos = self.photos.withReplaced(itemAt: index, newValue: newPhoto)
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                }
                
                completion(.success(()))
            }
        }
        
        task.resume()
    }
}

extension Array {
    func withReplaced(itemAt index: Int, newValue: Element) -> [Element] {
        var newArray = self
        newArray[index] = newValue
        return newArray
    }
}
