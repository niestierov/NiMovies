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
    func getPosterUrl() -> String?
    func getVideoKeys() -> [String]?
}

final class DefaultMovieDetailsPresenter: MovieDetailsPresenter {
    
    // MARK: - Properties -
    
    private unowned let view: MovieDetailsView
    private let apiService: MovieDetailsApiService
    private let movieId: Int
    private var movieDetailsViewState = MovieDetailsViewState()
    private var videoKeys: [String]?
    
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
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.fetchMovieDetails()
            self?.fetchMovieVideos()
        }
    }
    
    func getPosterUrl() -> String? {
        guard let posterUrl = movieDetailsViewState.movie?.posterUrlString else {
            return nil
        }
        return posterUrl
    }
    
    func getVideoKeys() -> [String]? {
        guard let videoKeys else {
            return nil
        }
        return videoKeys
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
                view.update(with: movie)
                movieDetailsViewState.movie = movie
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
            case .success(let videoKeys):
                self.videoKeys = videoKeys
            case.failure(let error):
                view.showError(message: error.localizedDescription)
            }
        }
    }
}
