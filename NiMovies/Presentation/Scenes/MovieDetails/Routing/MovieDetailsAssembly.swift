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
        
        let viewController = MovieDetailsViewController()
        let presenter = DefaultMovieDetailsPresenter(
            view: viewController,
            apiService: apiService,
            movieId: movieId
        )
        
        viewController.setPresenter(presenter)
        
        return viewController
    }
}
