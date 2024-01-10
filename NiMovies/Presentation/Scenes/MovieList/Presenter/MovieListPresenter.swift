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
    func loadMoreMovies()
    func sortMovies(by sortType: MovieListSortType)
    func didSelectMovie(at index: Int)
}

final class DefaultMovieListPresenter: MovieListPresenter {
    private struct Constant {
        static let internetConnectionUpdateDelay: TimeInterval = 5
        static let itemsForPageValue = 20
        static let initialFetchPage = 1
        static let scrollToTopButtonScope = 6
    }
    
    // MARK: - Properties -
    
    private let router: MovieListRouter
    private unowned var view: MovieListView
    private let apiService: MovieListApiService
    private var moviesGenreList: [MovieGenre] = []
    private var lastMovieListResult: [MovieResult] = []
    private var movieListViewState = MovieListViewState()
    private(set) var sortType: MovieListSortType = .popularityDescending
    private var searchWorkItem: DispatchWorkItem?
    private var currentSearchQuery: String?
    private var isRequestLoading = false
    private var currentPage: Int {
        movieListViewState.movies.count / Constant.itemsForPageValue + Constant.initialFetchPage
    }
    private let requestsGroup = DispatchGroup()
    private var isInternetConnectionErrorAvailable = true
    
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
        return movieListViewState.movies.count
    }
    
    func getMovie(at index: Int) -> MovieListViewState.Movie? {
        return movieListViewState.movies[index]
    }
    
    func sortMovies(by sortType: MovieListSortType) {
        self.sortType = sortType
        fetchMovieList(isNewLoad: true)
    }
    
    func searchMovies(query: String?) {
        searchWorkItem?.cancel()
        
        guard let query, !query.isEmpty else {
            currentSearchQuery = nil
            fetchMovieList(isNewLoad: true)
            return
        }
        
        searchWorkItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.fetchMovieSearch(with: query, isNewSearch: true)
            }
        }
        
        DispatchQueue.global().asyncAfter(
            deadline: .now() + 0.5,
            execute: searchWorkItem!
        )
    }

    func loadMoreMovies() {
        guard !isRequestLoading else {
            return
        }
        
        if let currentSearchQuery {
            fetchMovieSearch(with: currentSearchQuery)
        } else {
            fetchMovieList()
        }
    }
    
    func didSelectMovie(at index: Int) {
        guard let movie = getMovie(at: index) else {
            return
        }
        let movieDetailsConfiguration = MovieDetailsConfiguration(
            id: movie.id,
            title: movie.title
        )
        router.showNiPostDetails(with: movieDetailsConfiguration)
    }
}

private extension DefaultMovieListPresenter {
    func fetchMovieList(
        isNewLoad: Bool = false,
        group: DispatchGroup? = nil
    ) {
        isRequestLoading = true
        group?.enter()
        
        if isNewLoad {
            movieListViewState.movies = []
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
                lastMovieListResult = result.results
                updateMovieListViewState(with: result.results)
                
            case .failure(let error as NetworkError):
                switch error  {
                case .noInternetConnection:
                    if isInternetConnectionErrorAvailable {
                        isInternetConnectionErrorAvailable = false
                        view.showError(message: error.localizedDescription)
                    }
                default:
                    view.showError(message: error.localizedDescription)
                }
                
            case .failure(let error):
                view.showError(message: error.localizedDescription)
            }
            group?.leave()
        }
    }
    
    func fetchMovieSearch(
        with query: String,
        isNewSearch: Bool = false
    ) {
        isRequestLoading = true
        
        if isNewSearch {
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
    
    func fetchMoviesGenreList(group: DispatchGroup? = nil) {
        group?.enter()
        
        apiService.fetchMoviesGenreList { [weak self] response in
            guard let self else { return }
            
            switch response {
            case .success(let result):
                guard let result,
                      !result.genres.isEmpty else {
                    return
                }
                moviesGenreList = result.genres
                
            case .failure(let error):
                view.showError(message: error.localizedDescription)
            }
            group?.leave()
        }
    }
    
    func updateMovieListViewState(with movieList: [MovieResult]) {
        let isInitialUpdate = getMovieListCount() == .zero
        movieListViewState.appendMovieList(movieList, with: moviesGenreList)

        if isInitialUpdate {
            view.update()
        } else {
            let indexPaths = makeIndexPathsForNewMovieList(with: movieList)
            view.update(with: indexPaths)
        }
    }
    
    func makeIndexPathsForNewMovieList(with newMovieList: [MovieResult]) -> [IndexPath] {
        let endIndex = getMovieListCount()
        let startIndex = endIndex - newMovieList.count
        return (startIndex..<endIndex).map { IndexPath(item: $0, section: .zero) }
    }
    
    func initialLoadHandler() {
        requestsGroup.enter()
        view.showLoadingAnimation { [weak self] in
            self?.requestsGroup.leave()
        }
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self else { return }
            
            fetchMoviesGenreList(group: requestsGroup)
            fetchMovieList(group: requestsGroup)
        }
        
        requestsGroup.notify(queue: .main) { [weak self] in
            guard let self else { return }
            
            updateMovieListViewState(with: lastMovieListResult)
            view.hideLoadingAnimation()
        }
    }
}
