//
//  MovieListViewModel.swift
//  NiMovies
//
//  Created by Denys Niestierov on 25.12.2023.
//

import UIKit

fileprivate struct RequestPrepareInfo {
    let page: Int
    let isPrepareToLoad: Bool
}

protocol MovieListViewModel {
    var sortType: MovieListSortType { get }
    var isRequestLoading: Bool { get }
    var movieListViewState: MovieListViewState { get }
    var isInitialMoviesUpdate: Bool { get }
    var lastMovieResult: [MovieResult] { get }
    
    func initialLoad()
    func getMovieListCount() -> Int
    func getMovie(at: Int) -> MovieListViewState.Movie?
    func performMovieSearch(query: String?)
    func loadMoreMovies()
    func sortMovies(by sortType: MovieListSortType)
    func didSelectMovie(at index: Int)
    func getInternetConnectionStatus() -> Bool
    func isRequestAvailable() -> Bool
    @discardableResult 
    func validateInternetConnection() -> Bool
    func loadingAnimationCompletionHandler()
}

final class DefaultMovieListViewModel: MovieListViewModel {
    private struct Constant {
        static let itemsForPageValue = 20
        static let initialFetchPage = 1
        static let userDefaultsSortTypeKey = "sortType"
    }
    
    // MARK: - Properties -
    
    lazy var movieListViewState = MovieListViewState()
    lazy var isInitialMoviesUpdate = true
    lazy var lastMovieResult: [MovieResult] = []
    
    private lazy var requestsGroup = DispatchGroup()
    private let router: MovieListRouter
    private let apiService: MovieListApiService
    private lazy var moviesGenreList: [MovieGenre] = []
    private lazy var movieListResult: [MovieResult] = []
    private(set) lazy var sortType: MovieListSortType = .popularityDescending
    private var searchWorkItem: DispatchWorkItem?
    private var currentSearchQuery: String?
    private(set) lazy var isRequestLoading = false
    private lazy var isInternetConnectionErrorAvailable = true
    private lazy var previousPage: Int = .zero
    private var currentPage: Int {
        movieListViewState.movies.value.count / Constant.itemsForPageValue + Constant.initialFetchPage
    }
    private var isConnectedToInternet: Bool {
        NetworkReachabilityService.isConnectedToInternet
    }
    private lazy var defaultErrorHandler: ((Error) -> Void) = { [weak self] error in
        self?.movieListViewState.showError.value = error.localizedDescription
    }
    
    // MARK: - Init -
    
    init(
        router: MovieListRouter,
        apiService: MovieListApiService
    ) {
        self.router = router
        self.apiService = apiService
    }
    
    // MARK: - Internal -
    
    func initialLoad() {
        updateSortType()
        initialLoadHandler()
    }
    
    func updateSortType() {
        guard let savedSortType = UserDefaults.standard.string(forKey: Constant.userDefaultsSortTypeKey),
              let sortType = MovieListSortType(rawValue: savedSortType) else {
            return
        }
        self.sortType = sortType
    }
    
    func getMovieListCount() -> Int {
        return movieListViewState.movies.value.count
    }
    
    func getMovie(at index: Int) -> MovieListViewState.Movie? {
        guard index < movieListViewState.movies.value.count else {
            return nil
        }
        return movieListViewState.movies.value[index]
    }
    
    func getInternetConnectionStatus() -> Bool {
        isConnectedToInternet
    }
    
    @discardableResult
    func validateInternetConnection() -> Bool {
        if !isConnectedToInternet {
            defaultErrorHandler(NetworkError.noInternetConnection)
            return false
        }
        return true
    }
    
    func isRequestAvailable() -> Bool {
        return previousPage != currentPage
    }
    
    func sortMovies(by sortType: MovieListSortType) {
        guard validateInternetConnection() else {
            return
        }
        
        self.sortType = sortType
        fetchMovieList(isNewLoad: true)
        
        UserDefaults.standard.set(
            sortType.rawValue,
            forKey: Constant.userDefaultsSortTypeKey
        )
    }
    
    func performMovieSearch(query: String?) {
        if isConnectedToInternet {
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
            let movieListCount = getMovieListCount()
            if movieListCount == .zero || movieListCount >= Constant.itemsForPageValue {
                fetchMovieSearch(with: currentSearchQuery)
            }
        } else {
            fetchMovieList()
        }
    }
    
    func didSelectMovie(at index: Int) {
        guard validateInternetConnection() else {
            return
        }
        guard let movie = getMovie(at: index) else {
            return
        }
        
        let movieDetailsConfiguration = MovieDetailsConfiguration(
            id: movie.id,
            title: movie.title
        )
        router.showNiPostDetails(with: movieDetailsConfiguration)
    }
    
    func loadingAnimationCompletionHandler() {
        requestsGroup.leave()
    }
}

// MARK: - Private -

private extension DefaultMovieListViewModel {
    func fetchMovieList(
        isNewLoad: Bool = false,
        group: DispatchGroup? = nil
    ) {
        group?.enter()
        isRequestLoading = true
        
        let requestInfo = prepareForRequest(isNewRequest: isNewLoad)
        
        guard requestInfo.isPrepareToLoad else {
            group?.leave()
            return
        }
        
        apiService.fetchMovieList(
            by: sortType,
            for: requestInfo.page
        ) { [weak self] response in
            guard let self else { return }
            
            isRequestLoading = false
            
            switch response {
            case .success(let result):
                previousPage = requestInfo.page
                
                guard let result else {
                    return
                }
                let movieList = result.results
                
                if isNewLoad {
                    movieListResult = []
                    movieListViewState.movies.value = []
                    clearMovieModel()
                }
                if group == nil {
                    updateMovieListViewState(with: movieList)
                }
                movieListResult.append(contentsOf: movieList)
                updateMovieModel(with: movieList)
                isInternetConnectionErrorAvailable = true
                
            case .failure(let error):
                handleFailureMovieFetch(error: error)
            }
            
            group?.leave()
        }
    }
    
    func handleFailureMovieFetch(error: Error) {
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
        let requestInfo = prepareForRequest(isNewRequest: isNewSearch)
        
        guard requestInfo.isPrepareToLoad else {
            return
        }
        
        apiService.fetchSearch(
            with: query,
            for: requestInfo.page
        ) { [weak self] response in
            guard let self else { return }
            
            isRequestLoading = false
            
            switch response {
            case .success(let result):
                previousPage = requestInfo.page
                
                guard let result else {
                    return
                }
                
                if isNewSearch {
                    movieListViewState.movies.value = []
                    currentSearchQuery = query
                    movieListViewState.shouldShowSearchIndicator.value = false
                }
                updateMovieListViewState(with: result.results)
                
            case .failure(let error):
                handleFailureMovieFetch(error: error)
            }
        }
    }
    
    func updateMovieListViewState(with movieList: [MovieResult]) {
        lastMovieResult = movieList
        isInitialMoviesUpdate = getMovieListCount() == .zero
        movieListViewState.appendMovieList(movieList, with: moviesGenreList)
    }
    
    func searchMovies(query: String?) {
        searchWorkItem?.cancel()
        
        guard let query, !query.isEmpty else {
            if currentSearchQuery != nil {
                fetchMovieList(isNewLoad: true)
                currentSearchQuery = nil
            }
            return
        }
        
        guard query != currentSearchQuery else {
            return
        }
        movieListViewState.shouldShowSearchIndicator.value = true
        
        searchWorkItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.fetchMovieSearch(with: query, isNewSearch: true)
            }
        }
        
        DispatchQueue.global(qos: .userInteractive).asyncAfter(
            deadline: .now() + 0.5,
            execute: searchWorkItem!
        )
    }
    
    func searchMoviesLocally(query: String?) {
        guard let query, !query.isEmpty else {
            if currentSearchQuery != nil {
                movieListViewState.movies.value = []
                updateMovieListViewState(with: movieListResult)
                currentSearchQuery = nil
            }
            return
        }
        currentSearchQuery = query
        
        let filteredMovies = movieListResult.filter {
            return $0.title.localizedCaseInsensitiveContains(query)
        }
        
        movieListViewState.movies.value = []
        updateMovieListViewState(with: filteredMovies)
    }
    
    func prepareForRequest(isNewRequest: Bool) -> RequestPrepareInfo {
        if isNewRequest {
            previousPage = .zero
        }
        let requestPage = isNewRequest ? Constant.initialFetchPage : currentPage
        
        guard isRequestAvailable() else {
            isRequestLoading = false

            return RequestPrepareInfo(
                page: requestPage,
                isPrepareToLoad: false
            )
        }

        return RequestPrepareInfo(
            page: requestPage,
            isPrepareToLoad: true
        )
    }
    
    func initialLoadHandler() {
        requestsGroup.enter()
        movieListViewState.shouldShowLoadingAnimation.value = true
        
        if isConnectedToInternet {
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                guard let self else { return }
                
                fetchMoviesGenreList(group: requestsGroup)
                fetchMovieList(isNewLoad: true, group: requestsGroup)
            }
        } else {
            updateWithMovieModelData()
        }
        
        requestsGroup.notify(queue: .main) { [weak self] in
            guard let self else { return }
            
            updateMovieListViewState(with: movieListResult)
            movieListViewState.shouldShowLoadingAnimation.value = false
            
            if !validateInternetConnection() {
                isInternetConnectionErrorAvailable = false
                return
            }
        }
    }
    
    func updateWithMovieModelData() {
        DefaultMovieModelManager.shared.performMovieGenresUpdate(
            &moviesGenreList,
            group: requestsGroup,
            errorHandler: defaultErrorHandler
        )
        DefaultMovieModelManager.shared.performMovieListUpdate(
            &movieListResult,
            group: requestsGroup, 
            with: sortType,
            errorHandler: defaultErrorHandler
        )
    }
    
    func updateMovieModel<T>(with items: [T]) {
        DefaultMovieModelManager.shared.performModelUpdate(
            with: items,
            errorHandler: defaultErrorHandler
        )
    }
    
    func clearMovieModel() {
        DefaultMovieModelManager.shared.removeMovieItems(
            errorHandler: defaultErrorHandler
        )
    }
}
