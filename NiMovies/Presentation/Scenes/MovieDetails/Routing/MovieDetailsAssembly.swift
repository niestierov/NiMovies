//
//  MovieDetailsAssembly.swift
//  NiMovies
//
//  Created by Denys Niestierov on 06.01.2024.
//

import Foundation

protocol MovieDetailsAssembly {
    func createMovieDetails(movieId: Int) -> MovieDetailsViewController
}

final class DefaultMovieDetailsAssembly: MovieDetailsAssembly {
    
    // MARK: - Internal -
    
    func createMovieDetails(movieId: Int) -> MovieDetailsViewController {
        let networkService: NetworkService = ServiceLocator.shared.resolve()
        let apiService: MovieDetailsApiService = DefaultMovieDetailsApiService(networkService: networkService)
        let imageScreenView: ImageScreenView = ImageScreenViewController()
        let youtubePlayerView: YoutubePlayerView = YoutubePlayerViewController()
        
        let viewController = MovieDetailsViewController()
        let presenter = DefaultMovieDetailsPresenter(
            view: viewController,
            apiService: apiService,
            movieId: movieId
        )
        
        viewController.inject(
            presenter: presenter,
            imageScreenView: imageScreenView,
            youtubePlayerView: youtubePlayerView
        )
        
        return viewController
    }
}
