//
//  MovieDetailsApiService.swift
//  NiMovies
//
//  Created by Denys Niestierov on 06.01.2024.
//

import Foundation

protocol MovieDetailsApiService {
    func fetchMovieDetails(
        movieId: Int,
        completion: @escaping (Result<MovieDetailsViewState.Movie, Error>) -> Void
    )
    func fetchMovieVideos(
        movieId: Int,
        completion: @escaping (Result<String, Error>) -> Void
    )
}

final class DefaultMovieDetailsApiService: MovieDetailsApiService {
    
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
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let endpointPath = MovieDetailsEndpoint.videos(movieId: movieId)
        let endpoint = Endpoint<MovieVideoResult>(
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
                let videos = result.results.compactMap {
                    $0.key
                }
                
                completion(.success(videos.first ?? ""))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension DefaultMovieDetailsApiService {
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
}
