//
//  MovieDetailsAssembly.swift
//  NiMovies
//
//  Created by Denys Niestierov on 06.01.2024.
//

import Foundation

protocol MovieDetailsAssembly {
    func createMovieDetails(with configuration: MovieDetailsConfiguration) -> MovieDetailsViewController
}

final class DefaultMovieDetailsAssembly: MovieDetailsAssembly {
    
    // MARK: - Internal -
    
    func createMovieDetails(with configuration: MovieDetailsConfiguration) -> MovieDetailsViewController {
        let networkService: NetworkService = ServiceLocator.shared.resolve()
        let apiService: MovieDetailsApiService = DefaultMovieDetailsApiService(networkService: networkService)
        let imageScreenView: ImageScreenView = ImageScreenViewController()
        let youTubePlayerView: YouTubePlayerView = YouTubePlayerViewController()
        
        let viewController = MovieDetailsViewController()
        let presenter = DefaultMovieDetailsPresenter(
            view: viewController,
            apiService: apiService,
            configuration: configuration
        )
        
        viewController.inject(
            presenter: presenter,
            imageScreenView: imageScreenView,
            youTubePlayerView: youTubePlayerView
        )
        
        return viewController
    }
}
