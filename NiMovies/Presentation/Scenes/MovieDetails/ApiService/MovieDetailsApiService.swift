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
}

extension DefaultMovieDetailsApiService {
    enum MovieDetailsEndpoint {
        case details(movieId: Int)
        
        private var path: String {
            switch self {
            case .details(let movieId):
                let id = movieId.stringValue
                return "/movie/" + id
            }
        }
        
        var parameters: [String: Any] {
            let baseParameters: [String: Any] = [
                MovieConfiguration.apiKey: MovieConfiguration.getSecretKey()
            ]
            
            switch self {
            case .details:
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
