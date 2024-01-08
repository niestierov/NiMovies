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
    private var currentPage: Int {
        movieListViewState.movies.count / Constant.itemsForPageValue + Constant.initialFetchPage
    }
    private var isRequestLoading = false
    private var latestSearchQuery: String?
    private var isConnectedToInternet: Bool {
        NetworkReachabilityService.isConnectedToInternet
    }
    private var lastInternetConnectionStatus: Bool = false
    private var isErrorAlertIsReadyToBeShown = true
    
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
        let initialLoadGroup = DispatchGroup()

        initialLoadGroup.enter()
        view.showLoadingAnimation {
            initialLoadGroup.leave()
        }
        
        initialLoadGroup.enter()
        //var movieListResultError: Error?
        if isConnectedToInternet {
            var movieListResult: [MovieResult]?

            let requestsGroup = DispatchGroup()
            
            //DispatchQueue.global(qos: .userInitiated).async(group: requestsGroup) {
            requestsGroup.enter()
            self.fetchMoviesGenreList() { _ in
                requestsGroup.leave()
            }
            
            requestsGroup.enter()
            self.fetchMovieList(isInitial: false) { result in
                switch result {
                case .success(let movieList):
                    movieListResult = movieList
                case .failure(let error):
                    //movieListResultError = error
                    break
                }
                    
                requestsGroup.leave()
            }

            requestsGroup.notify(queue: .global(qos: .userInitiated)) {
                if let movieListResult {
                    self.updateMovieListViewState(with: movieListResult)
                }
                initialLoadGroup.leave()
            }
        } else {
            initialLoadGroup.leave()
        }

        initialLoadGroup.notify(queue: .main) {
            self.view.hideLoadingAnimation()
            
            if !self.isConnectedToInternet {
                self.view.showNoInternetConnectionError()
            }
        }
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
            latestSearchQuery = nil
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
        
        guard isConnectedToInternet else {
            if isErrorAlertIsReadyToBeShown {
                isErrorAlertIsReadyToBeShown = false
                view.showNoInternetConnectionError()
            }
            return
        }
        
        if let latestSearchQuery {
            fetchMovieSearch(with: latestSearchQuery, isInitialSearch: false)
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
        completion: ((Result<[MovieResult],Error>) -> Void)? = nil
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
            case .success(let movieList):
                if let completion {
                    completion(.success(movieList))
                } else {
                    updateMovieListViewState(with: movieList)
                }
            case .failure(let error):
                if let completion {
                    completion(.failure(error))
                } else {
                    view.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    func fetchMovieSearch(
        with query: String,
        isInitialSearch: Bool,
        completion: ((Result<[MovieResult], Error>) -> Void)? = nil
    ) {
        isRequestLoading = true
        
        if isInitialSearch {
            movieListViewState.movies = []
            latestSearchQuery = query
        }
        
        apiService.fetchSearch(
            with: query,
            for: currentPage
        ) { [weak self] response in
            guard let self else { return }
            
            isRequestLoading = false
            
            switch response {
            case .success(let movieList):
                if let completion {
                    completion(.success(movieList))
                } else {
                    updateMovieListViewState(with: movieList)
                }
            case .failure(let error):
                if let completion {
                    completion(.failure(error))
                } else {
                    view.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    func fetchMoviesGenreList(completion: ((Result<[MovieGenre], Error>) -> Void)? = nil) {
        apiService.fetchMoviesGenreList { [weak self] result in
            guard let self else {
                return
            }
            
            switch result {
            case .success(let genreList):
                moviesGenreList = genreList
                completion?(.success(genreList))
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
}
