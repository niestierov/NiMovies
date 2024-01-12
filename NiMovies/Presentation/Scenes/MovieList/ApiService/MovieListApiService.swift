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
        completion: @escaping EndpointRequestCompletion<MovieListResult>
    )
    func fetchSearch(
        with query: String,
        for page: Int,
        completion: @escaping EndpointRequestCompletion<MovieListResult>
    )
    func fetchMoviesGenreList(completion: @escaping EndpointRequestCompletion<MoviesGenreList>)
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
        completion: @escaping EndpointRequestCompletion<MovieListResult>
    ) {
        let endpointPath = MovieListEndpoint.list(sortType: sort, page: page)
        let endpoint = Endpoint<MovieListResult>(
            url: endpointPath.url,
            parameters: endpointPath.parameters,
            method: .get
        )
        networkService.request(endpoint: endpoint, completion: completion)
    }

    func fetchSearch(
        with query: String,
        for page: Int,
        completion: @escaping EndpointRequestCompletion<MovieListResult>
    ) {
        let endpointPath = MovieListEndpoint.search(query: query, page: page)
        let endpoint = Endpoint<MovieListResult>(
            url: endpointPath.url,
            parameters: endpointPath.parameters,
            method: .get
        )
        networkService.request(endpoint: endpoint, completion: completion)
    }
    
    func fetchMoviesGenreList(completion: @escaping EndpointRequestCompletion<MoviesGenreList>) {
        let endpointPath = MovieListEndpoint.genres
        let endpoint = Endpoint<MoviesGenreList>(
            url: endpointPath.url,
            parameters: endpointPath.parameters,
            method: .get
        )
        networkService.request(endpoint: endpoint, completion: completion)
    }
}

// MARK: - MovieListEndpoint -

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
            MovieApiConstant.apiKey: MovieApiConstant.getSecretKey()
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
        let urlString = MovieApiConstant.baseUrl + path
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        return url
    }
}
