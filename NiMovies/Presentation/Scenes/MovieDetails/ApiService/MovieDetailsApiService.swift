//
//  MovieDetailsApiService.swift
//  NiMovies
//
//  Created by Denys Niestierov on 06.01.2024.
//

import Foundation

private enum MovieDetailsError: Error, LocalizedError {
    case videoDataIsEmpty
    case videoKeyIsMissing
    
    var errorDescription: String? {
        switch self {
        case .videoDataIsEmpty, .videoKeyIsMissing:
            AppConstant.defaultErrorMessage + "An error occurred while playing this trailer."
        }
    }
}

protocol MovieDetailsApiService {
    func fetchMovieDetails(
        movieId: Int,
        completion: @escaping (Result<MovieDetailsViewState.Movie, Error>) -> Void
    )
    func fetchMovieVideos(
        movieId: Int,
        completion: @escaping (Result<URL, Error>) -> Void
    )
}

final class DefaultMovieDetailsApiService: MovieDetailsApiService {
    private struct Constant {
        static let youtubeBaseUrlWithoutKey = "https://www.youtube.com/watch?v="
        static let youtubeTitle = "YouTube"
    }
    
    // MARK: - Properties -
    
    let networkService: NetworkService
    
    // MARK: - Init -
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    // MARK: - Internal -
    
    func fetchMovieDetails(
        movieId: Int,
        completion: @escaping (Result<MovieDetailsViewState.Movie, Error>) -> Void
    ) {
        let endpointPath = MovieDetailsEndpoint.details(movieId: movieId)
        let endpoint = Endpoint<MovieDetailsResult>(
            url: endpointPath.url,
            parameters: endpointPath.parameters,
            method: .get
        )
        
        networkService.request(endpoint: endpoint) { response in
            switch response {
            case .success(let result):
                guard let result else {
                    return
                }
                let movie = MovieDetailsViewState.makeMovie(result)
                completion(.success(movie))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchMovieVideos(
        movieId: Int,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        let endpointPath = MovieDetailsEndpoint.videos(movieId: movieId)
        let endpoint = Endpoint<MovieVideoResult>(
            url: endpointPath.url,
            parameters: endpointPath.parameters,
            method: .get
        )
        
        networkService.request(endpoint: endpoint) { [weak self] response in
            guard let self else { return }
            
            switch response {
            case .success(let result):
                guard let result else {
                    completion(.failure(MovieDetailsError.videoDataIsEmpty))
                    return
                }
                guard let url = self.makeYouTubeUrl(with: result.results) else {
                    completion(.failure(MovieDetailsError.videoKeyIsMissing))
                    return
                }
                completion(.success(url))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

private extension DefaultMovieDetailsApiService {
    enum MovieDetailsEndpoint {
        case details(movieId: Int)
        case videos(movieId: Int)
        
        private var path: String {
            let basePath = "/movie/"
            switch self {
            case .details(let movieId):
                return basePath + movieId.stringValue
            case .videos(let movieId):
                return basePath + movieId.stringValue + "/videos"
            }
        }
        
        var parameters: [String: Any] {
            let baseParameters: [String: Any] = [
                MovieConfiguration.apiKey: MovieConfiguration.getSecretKey()
            ]
            
            switch self {
            case .details, .videos:
                break
            }
            return baseParameters
        }
        
        var url: URL? {
            let urlString = MovieConfiguration.baseUrl + path
            
            guard let url = URL(string: urlString) else {
                return nil
            }
            return url
        }
    }
    
    func makeYouTubeUrl(with movieVideo: [MovieVideo]) -> URL? {
        for result in movieVideo {
            if result.site == Constant.youtubeTitle {
                guard let key = result.key else {
                    return nil
                }
                if let url = URL(string: Constant.youtubeBaseUrlWithoutKey + key) {
                    return url
                }
            }
        }
        return nil
    }
}
