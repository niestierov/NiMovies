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
        self.fetchMoviesGenreList() {
            self.fetchMovieList(isInitial: false)
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
        showToTopButtonIfNeeded(for: index)
        
        guard getMovieListCount() - Constant.paginationValueUntilLoad <= index,
              !isRequestLoading else {
            return
        }
        
        if let latestSearchQuery {
            fetchMovieSearch(with: latestSearchQuery, isInitialSearch: false)
        } else {
            fetchMovieList(isInitial: false)
        }
    }
}

private extension DefaultMovieListPresenter {
    func fetchMovieList(isInitial: Bool) {
        isRequestLoading = true
        
        if isInitial {
            movieListViewState.movies = []
            view.initialUpdate()
        }
        
        apiService.fetchMovieList(
            by: sortType,
            for: currentPage,
            genres: moviesGenreList
        ) { [weak self] response in
            guard let self else {
                return
            }
            isRequestLoading = false
            
            switch response {
            case .success(let movieList):
                movieListViewState.movies.append(contentsOf: movieList)
                view.update()
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
            latestSearchQuery = query
        }
        
        apiService.fetchSearch(
            with: query,
            for: currentPage,
            genres: moviesGenreList
        ) { [weak self] response in
            guard let self else {
                return
            }
            isRequestLoading = false
            
            switch response {
            case .success(let movieList):
                movieListViewState.movies.append(contentsOf: movieList)
                view.update()
            case .failure(let error):
                view.showError(message: error.localizedDescription)
            }
        }
    }
    
    func fetchMoviesGenreList(completion: EmptyBlock? = nil) {
        apiService.fetchMoviesGenreList { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let genreList):
                moviesGenreList = genreList
                completion?()
            case .failure(let error):
                view.showError(message: error.localizedDescription)
            }
        }
    }
    
    func showToTopButtonIfNeeded(for index: Int) {
        if index == Constant.scrollToTopButtonScope {
            view.showScrollToTopButton(true)
        } else if index < Constant.scrollToTopButtonScope {
            view.showScrollToTopButton(false)
        }
    }
}
