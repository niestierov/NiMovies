//
//  MovieListPresenter.swift
//  NiMovies
//
//  Created by Denys Niestierov on 25.12.2023.
//

import Foundation
import UIKit

protocol MovieListPresenter {
    var sortType: MovieListSortType { get }
    
    func initialLoad()
    func getMovieListCount() -> Int
    func getMovie(at: Int) -> MovieListViewState.Movie?
    func searchMovies(query: String?)
    func didScrollView(at index: Int)
    func sortMovies(by sortType: MovieListSortType)
    func didSelectMovie(at index: Int)
}

final class DefaultMovieListPresenter: MovieListPresenter {
    private struct Constant {
        static let internetConnectionUpdateDelay: TimeInterval = 5
        static let itemsForPageValue = 20
        static let initialFetchPage = 1
        static let paginationValueUntilLoad = 5
        static let scrollToTopButtonScope = 6
    }
    
    // MARK: - Properties -
    
    private let router: MovieListRouter
    private unowned var view: MovieListView
    private let apiService: MovieListApiService
    private var moviesGenreList: [MovieGenre] = []
    private var movieListViewState = MovieListViewState()
    private(set) var sortType: MovieListSortType = .popularityDescending
    private var searchWorkItem: DispatchWorkItem?
    private var currentSearchQuery: String?
    private var isRequestLoading = false
    private var currentPage: Int {
        movieListViewState.movies.count / Constant.itemsForPageValue + Constant.initialFetchPage
    }
    private var lastInternetConnectionUpdate = Date()
    private var internetConnectionUpdateTimer: Timer?
    private var isInternetConnectionErrorIsAvailable = true
    private lazy var isConnectedToInternet: Bool = {
        return NetworkReachabilityService.isConnectedToInternet
    }()

    
    // MARK: - Init -
    
    init(
        view: MovieListView,
        router: MovieListRouter,
        apiService: MovieListApiService
    ) {
        self.view = view
        self.router = router
        self.apiService = apiService
    }
    
    // MARK: - Internal -
    
    func initialLoad() {
        initialLoadHandler()
    }

    func getMovieListCount() -> Int {
        movieListViewState.movies.count
    }
    
    func getMovie(at index: Int) -> MovieListViewState.Movie? {
        if !movieListViewState.movies.isEmpty {
            return movieListViewState.movies[index]
        }
        return nil
    }
    
    func sortMovies(by sortType: MovieListSortType) {
        self.sortType = sortType
        fetchMovieList(isInitial: true)
    }
    
    func searchMovies(query: String?) {
        searchWorkItem?.cancel()
        
        guard let query, !query.isEmpty else {
            currentSearchQuery = nil
            fetchMovieList(isInitial: true)
            return
        }
        
        searchWorkItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.fetchMovieSearch(with: query, isInitialSearch: true)
            }
        }
        
        DispatchQueue.global().asyncAfter(
            deadline: .now() + .milliseconds(500),
            execute: searchWorkItem!
        )
    }

    func didScrollView(at index: Int) {
        guard index >= getMovieListCount() - Constant.paginationValueUntilLoad,
              !isRequestLoading else {
            return
        }
        
        guard updateInternetConnectionStatus() else {
            if isInternetConnectionErrorIsAvailable {
                isInternetConnectionErrorIsAvailable = false
                view.showNoInternetConnectionError()
            }
            return
        }
        
        if let currentSearchQuery {
            fetchMovieSearch(with: currentSearchQuery, isInitialSearch: false)
        } else {
            fetchMovieList(isInitial: false)
        }
    }
    
    func didSelectMovie(at index: Int) {
        guard let id = getMovie(at: index)?.id else {
            return
        }
        router.showNiPostDetails(movieId: id)
    }
}

private extension DefaultMovieListPresenter {
    func fetchMovieList(
        isInitial: Bool,
        completion: (([MovieResult]) -> Void)? = nil
    ) {
        isRequestLoading = true
        
        if isInitial {
            movieListViewState.movies = []
            view.initialUpdate()
        }
        
        apiService.fetchMovieList(
            by: sortType,
            for: currentPage
        ) { [weak self] response in
            guard let self else { return }
            
            isRequestLoading = false
            
            switch response {
            case .success(let result):
                guard let result else {
                    return
                }
                if let completion {
                    completion(result.results)
                } else {
                    updateMovieListViewState(with: result.results)
                }
            case .failure(let error):
                view.showError(message: error.localizedDescription)
            }
        }
    }
    
    func fetchMovieSearch(
        with query: String,
        isInitialSearch: Bool
    ) {
        isRequestLoading = true
        
        if isInitialSearch {
            movieListViewState.movies = []
            currentSearchQuery = query
        }
        
        apiService.fetchSearch(
            with: query,
            for: currentPage
        ) { [weak self] response in
            guard let self else { return }
            
            isRequestLoading = false
            
            switch response {
            case .success(let result):
                guard let result else {
                    return
                }
                updateMovieListViewState(with: result.results)
            case .failure(let error):
                view.showError(message: error.localizedDescription)
            }
        }
    }
    
    func fetchMoviesGenreList(completion: ((Result<[MovieGenre], Error>) -> Void)? = nil) {
        apiService.fetchMoviesGenreList { [weak self] response in
            guard let self else { return }
            
            switch response {
            case .success(let result):
                guard let result,
                      !result.genres.isEmpty else {
                    return
                }
                moviesGenreList = result.genres
                completion?(.success(result.genres))
                
            case .failure(let error):
                if let completion {
                    completion(.failure(error))
                } else {
                    view.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    func updateMovieListViewState(with movieList: [MovieResult]) {
        movieListViewState.appendMovieList(movieList, with: moviesGenreList)
        view.update()
    }
    
    func initialLoadHandler() {
        let group = DispatchGroup()
        
        group.enter()
        view.showLoadingAnimation {
            group.leave()
        }
        
        if isConnectedToInternet {
            group.enter()
            
            initialRequestsGroupHandler {
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            
            view.hideLoadingAnimation()
            
            if !isConnectedToInternet {
                view.showNoInternetConnectionError()
            }
        }
    }
    
    func initialRequestsGroupHandler(completion: @escaping () -> Void) {
        var movieListResult: [MovieResult] = []
        let requestsGroup = DispatchGroup()
        
        let movieGenreListWorkItem = DispatchWorkItem { [weak self] in
            self?.fetchMoviesGenreList() { _ in
                requestsGroup.leave()
            }
        }
       
        let movieListWorkItem = DispatchWorkItem { [weak self] in
            self?.fetchMovieList(isInitial: false) { movieList in
                movieListResult = movieList
                requestsGroup.leave()
            }
        }
        
        requestsGroup.enter()
        DispatchQueue.global(qos: .userInteractive).async(execute: movieGenreListWorkItem)
        
        requestsGroup.enter()
        DispatchQueue.global(qos: .userInteractive).async(execute: movieListWorkItem)

        requestsGroup.notify(queue: .main) { [weak self] in
            self?.updateMovieListViewState(with: movieListResult)
            completion()
        }
    }
    
    @discardableResult
    func updateInternetConnectionStatus() -> Bool {
        let currentTime = Date()
        let elapsedTime = currentTime.timeIntervalSince(lastInternetConnectionUpdate)

        guard elapsedTime >= Constant.internetConnectionUpdateDelay else {
            return isConnectedToInternet
        }

        lastInternetConnectionUpdate = currentTime
        isConnectedToInternet = NetworkReachabilityService.isConnectedToInternet

        if isConnectedToInternet {
            isInternetConnectionErrorIsAvailable = true
        }
        return isConnectedToInternet
    }
}
