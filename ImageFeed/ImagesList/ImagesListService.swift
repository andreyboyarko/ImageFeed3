
import Foundation

final class ImagesListService {
    static let shared = ImagesListService()
    private init() {}
    
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    private (set) var photos: [Photo] = []
    private var lastLoadedPage = 0
    private var isFetching = false
    private let perPage = 10
    
    private var task: URLSessionTask?
    
    private func convert(photoResult: PhotoResult) -> Photo {
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: photoResult.createdAt)
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
                
                if let data = data,
                   let photoResults = try? JSONDecoder().decode([PhotoResult].self, from: data) {
                    let newPhotos = photoResults.map { self.convert(photoResult: $0) }
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                }
            }
        }
        task?.resume()
    }
}
