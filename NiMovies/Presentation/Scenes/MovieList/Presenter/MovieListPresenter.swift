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
    func performMovieSearch(query: String?)
    func loadMoreMovies()
    func sortMovies(by sortType: MovieListSortType)
    func didSelectMovie(at index: Int)
    func getInternetConnectionStatus() -> Bool
}

final class DefaultMovieListPresenter: MovieListPresenter {
    private struct Constant {
        static let itemsForPageValue = 20
        static let initialFetchPage = 1
    }
    
    // MARK: - Properties -
    
    private let router: MovieListRouter
    private unowned var view: MovieListView
    private let apiService: MovieListApiService
    private lazy var moviesGenreList: [MovieGenre] = []
    private lazy var lastMovieListResult: [MovieResult] = []
    private lazy var movieListViewState = MovieListViewState()
    private(set) lazy var sortType: MovieListSortType = .popularityDescending
    private let requestsGroup = DispatchGroup()
    private var searchWorkItem: DispatchWorkItem?
    private var currentSearchQuery: String?
    private lazy var isRequestLoading = false
    private lazy var isInternetConnectionErrorAvailable = true
    private var currentPage: Int {
        movieListViewState.movies.count / Constant.itemsForPageValue + Constant.initialFetchPage
    }
    private lazy var isConnectedToInternet = {
        NetworkReachabilityService.isConnectedToInternet
    }()
    private lazy var defaultErrorHandler: ((Error) -> Void) = { [weak self] error in
        self?.view.showError(message: error.localizedDescription)
    }
    
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
        guard index < movieListViewState.movies.count else {
            return nil
        }
        return movieListViewState.movies[index]
    }
    
    func sortMovies(by sortType: MovieListSortType) {
        if !isConnectedToInternet {
            defaultErrorHandler(NetworkError.noInternetConnection)
            return
        }
        
        self.sortType = sortType
        fetchMovieList(isNewLoad: true)
    }
    
    func getInternetConnectionStatus() -> Bool {
        isConnectedToInternet
    }
    
    func performMovieSearch(query: String?) {
        if NetworkReachabilityService.isConnectedToInternet {
            searchMovies(query: query)
        } else {
            searchMoviesLocally(query: query)
        }
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

// MARK: - Private -

private extension DefaultMovieListPresenter {
    func fetchMovieList(
        isNewLoad: Bool = false,
        group: DispatchGroup? = nil
    ) {
        group?.enter()
        
        isRequestLoading = true
        let requestPage = isNewLoad ? Constant.initialFetchPage : currentPage
        
        apiService.fetchMovieList(
            by: sortType,
            for: requestPage
        ) { [weak self] response in
            guard let self else { return }
            
            isRequestLoading = false
            
            switch response {
            case .success(let result):
                lastMovieListResult = result?.results ?? []
                
                if isNewLoad {
                    movieListViewState.movies = []
                    clearMovieModel()
                }
                if group == nil {
                    updateMovieListViewState(with: lastMovieListResult)
                }
                
                updateMovieModel(with: lastMovieListResult)
                
            case .failure(let error):
                handlFailureMovieListFetch(error: error)
            }
            
            group?.leave()
        }
    }
    
    func handlFailureMovieListFetch(error: Error) {
        guard let networkError = error as? NetworkError else {
            defaultErrorHandler(error)
            return
        }
        
        switch networkError  {
        case .noInternetConnection:
            if isInternetConnectionErrorAvailable {
                isInternetConnectionErrorAvailable = false
                defaultErrorHandler(error)
            }
        default:
            defaultErrorHandler(error)
        }
    }
    
    func fetchMoviesGenreList(group: DispatchGroup? = nil) {
        group?.enter()
        
        apiService.fetchMoviesGenreList { [weak self] response in
            guard let self else { return }
            
            switch response {
            case .success(let result):
                moviesGenreList = result?.genres ?? []
                updateMovieModel(with: moviesGenreList)
            case .failure(let error):
                defaultErrorHandler(error)
            }
            
            group?.leave()
        }
    }
    
    func fetchMovieSearch(
        with query: String,
        isNewSearch: Bool = false
    ) {
        isRequestLoading = true
        let requestPage = isNewSearch ? Constant.initialFetchPage : currentPage
        
        apiService.fetchSearch(
            with: query,
            for: requestPage
        ) { [weak self] response in
            guard let self else { return }
            
            isRequestLoading = false
            
            switch response {
            case .success(let result):
                guard let result else {
                    return
                }
                if isNewSearch {
                    movieListViewState.movies = []
                    currentSearchQuery = query
                }
                lastMovieListResult = result.results
                updateMovieListViewState(with: result.results)
                
            case .failure(let error):
                defaultErrorHandler(error)
            }
        }
    }
    
    func updateMovieListViewState(with movieList: [MovieResult]) {
        let isInitialUpdate = getMovieListCount() == .zero
        movieListViewState.appendMovieList(movieList, with: moviesGenreList)
        
        if isInitialUpdate {
            view.update()
        } else {
            view.appendItems(movieList.count)
        }
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
    
    func searchMoviesLocally(query: String?) {
        movieListViewState.movies = []
        
        guard let query, !query.isEmpty else {
            updateMovieListViewState(with: lastMovieListResult)
            return
        }
        
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            
            let filteredMovies = lastMovieListResult.filter {
                return $0.title.localizedCaseInsensitiveContains(query)
            }

            DispatchQueue.main.async {
                self.updateMovieListViewState(with: filteredMovies)
            }
        }
    }
    
    func initialLoadHandler() {
        requestsGroup.enter()
        view.showLoadingAnimation { [weak self] in
            self?.requestsGroup.leave()
        }
        
        if isConnectedToInternet {
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                guard let self else { return }
                
                fetchMoviesGenreList(group: requestsGroup)
                fetchMovieList(isNewLoad: true, group: requestsGroup)
            }
        } else {
            DefaultMovieModelManager.shared.performMovieGenresUpdate(
                &moviesGenreList,
                group: requestsGroup,
                errorHandler: defaultErrorHandler
            )
            
            DefaultMovieModelManager.shared.performMovieListUpdate(
                &lastMovieListResult,
                group: requestsGroup,
                errorHandler: defaultErrorHandler
            )
            isInternetConnectionErrorAvailable = false
        }
        
        requestsGroup.notify(queue: .main) { [weak self] in
            guard let self else { return }
            
            updateMovieListViewState(with: lastMovieListResult)
            view.hideLoadingAnimation()
            
            if !isInternetConnectionErrorAvailable {
                view.showError(message: AppConstant.noInternetConnectionErrorMessage)
            }
        }
    }
    
    func updateMovieModel<T>(with items: [T]) {
        switch T.self {
        case is MovieResult.Type:
            DefaultMovieModelManager.shared.performModelUpdate(
                with: lastMovieListResult,
                errorHandler: defaultErrorHandler
            )
        case is MovieGenre.Type:
            DefaultMovieModelManager.shared.performModelUpdate(
                with: moviesGenreList,
                errorHandler: defaultErrorHandler
            )
        default:
            break
        }
    }
    
    func clearMovieModel() {
        DefaultMovieModelManager.shared.removeMovieListItems(
            errorHandler: defaultErrorHandler
        )
    }
}
