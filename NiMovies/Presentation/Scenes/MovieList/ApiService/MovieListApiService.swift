//
//  MovieListApiService.swift
//  NiMovies
//
//  Created by Denys Niestierov on 25.12.2023.
//

import Foundation

protocol MovieListApiService {
    func fetchMovieList(
        by sort: MovieListSortType,
        for page: Int,
        completion: @escaping (Result<[MovieResult], Error>) -> Void
    )
    func fetchSearch(
        with query: String,
        for page: Int,
        completion: @escaping (Result<[MovieResult], Error>) -> Void
    )
    func fetchMoviesGenreList(
        completion: @escaping (Result<[MovieGenre], Error>) -> Void
    )
}

final class DefaultMovieListApiService: MovieListApiService {
    
    // MARK: - Properties -
    
    let networkService: NetworkService
    
    // MARK: - Init -
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    // MARK: - Internal -
    
    func fetchMovieList(
        by sort: MovieListSortType,
        for page: Int,
        completion: @escaping (Result<[MovieResult], Error>) -> Void
    ) {
        let endpointPath = MovieListEndpoint.list(sortType: sort, page: page)
        fetchMovieList(with: endpointPath, completion: completion)
    }

    func fetchSearch(
        with query: String,
        for page: Int,
        completion: @escaping (Result<[MovieResult], Error>) -> Void
    ) {
        let endpointPath = MovieListEndpoint.search(query: query, page: page)
        fetchMovieList(with: endpointPath, completion: completion)
    }
    
    func fetchMoviesGenreList(
        completion: @escaping (Result<[MovieGenre], Error>) -> Void
    ) {
        let endpointPath = MovieListEndpoint.genres
        let endpoint = Endpoint<MoviesGenreList>(
            url: endpointPath.url,
            parameters: endpointPath.parameters,
            method: .get
        )
        
        networkService.request(endpoint: endpoint) { response in
            switch response {
            case .success(let result):
                guard let result,
                      !result.genres.isEmpty else {
                    return
                }
                completion(.success(result.genres))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Private -

private extension DefaultMovieListApiService {
    func fetchMovieList(
        with endpointPath: MovieListEndpoint,
        completion: @escaping (Result<[MovieResult], Error>) -> Void
    ) {
        let endpoint = Endpoint<MovieListResult>(
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
                completion(.success(result.results))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - MovieListEndpoint -

extension DefaultMovieListApiService {
    fileprivate enum MovieListEndpoint {
        case list(sortType: MovieListSortType, page: Int)
        case search(query: String, page: Int)
        case genres
        
        private var path: String {
            switch self {
            case .list:
                "/discover/movie"
            case .search:
                "/search/movie"
            case .genres:
                "/genre/movie/list"
            }
        }
        
        var parameters: [String: Any] {
            var baseParameters: [String: Any] = [
                MovieConfiguration.apiKey: MovieConfiguration.getSecretKey()
            ]
            
            switch self {
            case .list(let sortType, let page):
                baseParameters[ApiConstant.MovieListFields.sortType] = sortType.rawValue
                baseParameters[ApiConstant.MovieListFields.page] = page
            case .search(let query, let page):
                baseParameters[ApiConstant.MovieSearchFields.query] = query
                baseParameters[ApiConstant.MovieSearchFields.page] = page
            case .genres:
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
