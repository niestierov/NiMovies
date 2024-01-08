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
    private struct Constant {
        static let youTubeTitle = "YouTube"
        static let suitableVideoTypes = ["Trailer", "Teaser"]
    }
    
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
        DispatchQueue.global().async { [weak self] in
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
        apiService.fetchMovieDetails(movieId: movieId) { [weak self] response in
            guard let self else { return }
            
            switch response {
            case .success(let movieDetails):
                guard let movieDetails else {
                    return
                }
                updateViewState(with: movieDetails)
            case.failure(let error):
                view.showError(message: error.localizedDescription)
            }
        }
    }
    
    func fetchMovieVideos() {
        apiService.fetchMovieVideos(movieId: movieId) { [weak self] response in
            guard let self else { return }
            
            switch response {
            case .success(let result):
                guard let result else {
                    return
                }
                guard let keys = self.getVideoKeys(by: result.results) else {
                    return
                }
                self.videoKeys = keys
                view.updateTrailerButton(isHidden: keys.isEmpty)

            case .failure(let error):
                view.showError(message: error.localizedDescription)
            }
        }
    }
    
    func updateViewState(with movieResult: MovieDetailsResult) {
        let movie = MovieDetailsViewState.makeMovie(movieResult)
        view.update(with: movie)
        movieDetailsViewState.movie = movie
    }
    
    func getVideoKeys(by movieVideo: [MovieVideo]) -> [String]? {
        let keys = movieVideo.compactMap { result -> String? in
            guard Constant.suitableVideoTypes.contains(result.type),
                  result.site == Constant.youTubeTitle,
                  let key = result.key
            else {
                return nil
            }
            return key
        }
        return keys
    }
}
