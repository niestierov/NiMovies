//
//  MovieDetailsApiService.swift
//  NiMovies
//
//  Created by Denys Niestierov on 06.01.2024.
//

import Foundation

fileprivate enum MovieDetailsError: Error, LocalizedError {
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
        completion: @escaping (Result<MovieDetailsResult, Error>) -> Void
    )
    func fetchMovieVideos(
        movieId: Int,
        completion: @escaping (Result<[String], Error>) -> Void
    )
}

final class DefaultMovieDetailsApiService: MovieDetailsApiService {
    private struct Constant {
        static let youTubeTitle = "YouTube"
        static let suitableVideoTypes = ["Trailer", "Teaser"]
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
        completion: @escaping (Result<MovieDetailsResult, Error>) -> Void
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
                completion(.success(result))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchMovieVideos(
        movieId: Int,
        completion: @escaping (Result<[String], Error>) -> Void
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
                guard let keys = self.getVideoKeys(by: result.results) else {
                    completion(.failure(MovieDetailsError.videoKeyIsMissing))
                    return
                }
                completion(.success(keys))
                
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
    
    func getVideoKeys(by movieVideo: [MovieVideo]) -> [String]? {
        let keys = movieVideo.compactMap { result -> String? in
            guard Constant.suitableVideoTypes.contains(result.type),
                  result.site == Constant.youTubeTitle,
                  let key = result.key
            else {
                return nil
            }
            return key
        }
        return keys
    }
}
