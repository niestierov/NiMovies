//
//  MovieDetailsPresenter.swift
//  NiMovies
//
//  Created by Denys Niestierov on 06.01.2024.
//

import Foundation
import UIKit

struct MovieDetailsConfiguration {
    let id: Int
    let title: String
}

protocol MovieDetailsPresenter {
    func initialLoad()
    func getPosterUrl() -> String?
    func getVideoKeys() -> [String]?
    func getSectionCount() -> Int
    func getSection(by section: Int) -> MovieDetailsViewState.Section
    func getHeader() -> MovieDetailsViewState.MovieDetailsHeader?
    func getTitle() -> String
}

final class DefaultMovieDetailsPresenter: MovieDetailsPresenter {
    private struct Constant {
        static let youTubeTitle = "YouTube"
        static let suitableVideoTypes = ["Trailer", "Teaser"]
    }
    
    // MARK: - Properties -
    
    private unowned let view: MovieDetailsView
    private let apiService: MovieDetailsApiService
    private let configuration: MovieDetailsConfiguration
    private(set) var movieDetailsViewState: MovieDetailsViewState
    private let requestGroup = DispatchGroup()
    private var movieDetails: MovieDetailsResult?
    private var videoKeys: [String]?
    
    // MARK: - Init -
    
    init(
        view: MovieDetailsView,
        apiService: MovieDetailsApiService,
        configuration: MovieDetailsConfiguration
    ) {
        self.view = view
        self.apiService = apiService
        self.configuration = configuration
        
        movieDetailsViewState = MovieDetailsViewState.makeInitialViewState(with: configuration)
    }
    
    // MARK: - Internal -
    
    func initialLoad() {
        initialRequestsHander()
    }
    
    func getSectionCount() -> Int {
        movieDetailsViewState.sections.count
    }
    
    func getSection(by section: Int) -> MovieDetailsViewState.Section {
        movieDetailsViewState.sections[section]
    }
    
    func getHeader() -> MovieDetailsViewState.MovieDetailsHeader? {
        movieDetailsViewState.header
    }
    
    func getTitle() -> String {
        movieDetailsViewState.title
    }
    
    func getPosterUrl() -> String? {
        movieDetailsViewState.header?.poster ?? nil
    }
    
    func getVideoKeys() -> [String]? {
        videoKeys ?? nil
    }
}

// MARK: - Private -

private extension DefaultMovieDetailsPresenter {
    func fetchMovieDetails(group: DispatchGroup? = nil) {
        apiService.fetchMovieDetails(movieId: configuration.id) { [weak self] response in
            guard let self else { return }
            
            switch response {
            case .success(let movieDetails):
                guard let movieDetails else {
                    return
                }
                self.movieDetails = movieDetails

            case.failure(let error):
                view.showError(message: error.localizedDescription)
            }
            group?.leave()
        }
    }
    
    func fetchMovieVideos(group: DispatchGroup? = nil) {
        apiService.fetchMovieVideos(movieId: configuration.id) { [weak self] response in
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
                
            case .failure(let error):
                view.showError(message: error.localizedDescription)
            }
            group?.leave()
        }
    }
    
    func updateViewState() {
        if let movieDetails {
            movieDetailsViewState = MovieDetailsViewState.makeViewState(
                movieDetails: movieDetails,
                videoKeys: videoKeys
            )
        }
        view.update(with: getTitle())
    }
    
    func getVideoKeys(by movieVideo: [MovieVideo]) -> [String]? {
        let keys = movieVideo.compactMap { result -> String? in
            guard Constant.suitableVideoTypes.contains(result.type),
                  result.site == Constant.youTubeTitle,
                  let key = result.key else {
                return nil
            }
            return key
        }
        return keys
    }
    
    func initialRequestsHander() {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            
            requestGroup.enter()
            fetchMovieDetails(group: requestGroup)
            
            requestGroup.enter()
            fetchMovieVideos(group: requestGroup)
            
            requestGroup.notify(queue: .main) { [weak self] in
                self?.updateViewState()
            }
        }
    }
}
