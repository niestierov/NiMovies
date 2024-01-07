//
//  MovieDetailsPresenter.swift
//  NiMovies
//
//  Created by Denys Niestierov on 06.01.2024.
//

import Foundation
import UIKit

protocol MovieDetailsPresenter {
    func initialLoad()
    func didTapTrailerButton()
    func getPosterUrl() -> String?
}

final class DefaultMovieDetailsPresenter: MovieDetailsPresenter {
    
    // MARK: - Properties -
    
    private unowned let view: MovieDetailsView
    private let apiService: MovieDetailsApiService
    private let movieId: Int
    private var movieDetailsViewState = MovieDetailsViewState()
    
    // MARK: - Init -
    
    init(
        view: MovieDetailsView,
        apiService: MovieDetailsApiService,
        movieId: Int
    ) {
        self.view = view
        self.apiService = apiService
        self.movieId = movieId
    }
    
    // MARK: - Internal -
    
    func initialLoad() {
        fetchMovieDetails()
    }
    
    func didTapTrailerButton() {
        fetchMovieVideos()
    }
    
    func getPosterUrl() -> String? {
        guard let posterUrl = movieDetailsViewState.movie?.posterUrlString else {
            return nil
        }
        return posterUrl
    }
}

// MARK: - Private -

private extension DefaultMovieDetailsPresenter {
    func fetchMovieDetails() {
        apiService.fetchMovieDetails(movieId: movieId) { [weak self] result in
            guard let self else {
                return
            }
            
            switch result {
            case .success(let movie):
                movieDetailsViewState.movie = movie
                view.update(with: movie)
            case.failure(let error):
                view.showError(message: error.localizedDescription)
            }
        }
    }
    
    func fetchMovieVideos() {
        apiService.fetchMovieVideos(movieId: movieId) { [weak self] result in
            guard let self else {
                return
            }
            
            switch result {
            case .success(let keys):
                view.showYouTubePlayer(with: keys)
            case.failure(let error):
                view.showError(message: error.localizedDescription)
            }
        }
    }
}
