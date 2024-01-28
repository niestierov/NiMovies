//
//  MovieDetailsViewModel.swift
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

protocol MovieDetailsViewModel {
    var movieDetailsViewState: Bindable<MovieDetailsViewState> { get set }
    func initialLoad()
    func getPosterUrl() -> String?
    func getVideoKeys() -> [String]?
    func getSectionCount() -> Int
    func getSection(by section: Int) -> MovieDetailsViewState.Section
    func getHeader() -> MovieDetailsViewState.MovieDetailsHeader?
}

final class DefaultMovieDetailsViewModel: MovieDetailsViewModel {
    private struct Constant {
        static let youTubeTitle = "YouTube"
        static let suitableVideoTypes = ["Trailer", "Teaser"]
    }
    
    // MARK: - Properties -
    
    lazy var movieDetailsViewState = Bindable(MovieDetailsViewState.makeInitialViewState(with: configuration))
    private let apiService: MovieDetailsApiService
    private let configuration: MovieDetailsConfiguration
    private let requestGroup = DispatchGroup()
    private var movieDetails: MovieDetailsResult?
    private var videoKeys: [String]?
    
    // MARK: - Init -
    
    init(
        apiService: MovieDetailsApiService,
        configuration: MovieDetailsConfiguration
    ) {
        self.apiService = apiService
        self.configuration = configuration
    }
    
    // MARK: - Internal -
    
    func initialLoad() {
        initialRequestsHander()
    }
    
    func getSectionCount() -> Int {
        movieDetailsViewState.value.sections.count
    }
    
    func getSection(by section: Int) -> MovieDetailsViewState.Section {
        movieDetailsViewState.value.sections[section]
    }
    
    func getHeader() -> MovieDetailsViewState.MovieDetailsHeader? {
        movieDetailsViewState.value.header
    }
    
    func getPosterUrl() -> String? {
        movieDetailsViewState.value.header?.poster ?? nil
    }
    
    func getVideoKeys() -> [String]? {
        videoKeys ?? nil
    }
}

// MARK: - Private -

private extension DefaultMovieDetailsViewModel {
    func fetchMovieDetails(group: DispatchGroup? = nil) {
        group?.enter()
        
        apiService.fetchMovieDetails(movieId: configuration.id) { [weak self] response in
            guard let self else { return }
            
            switch response {
            case .success(let movieDetails):
                guard let movieDetails else {
                    return
                }
                self.movieDetails = movieDetails

            case.failure(let error):
                movieDetailsViewState.value.showError = error.localizedDescription
            }
            group?.leave()
        }
    }
    
    func fetchMovieVideos(group: DispatchGroup? = nil) {
        group?.enter()
        
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
                
            case .failure:
                break
            }
            group?.leave()
        }
    }
    
    func updateViewState() {
        if let movieDetails {
            movieDetailsViewState.value = MovieDetailsViewState.makeViewState(
                movieDetails: movieDetails,
                videoKeys: videoKeys
            )
        }
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
            
            fetchMovieDetails(group: requestGroup)
            fetchMovieVideos(group: requestGroup)
            
            requestGroup.notify(queue: .main) { [weak self] in
                self?.updateViewState()
            }
        }
    }
}
