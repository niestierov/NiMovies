//
//  MovieListAssembly.swift
//  NiMovies
//
//  Created by Denys Niestierov on 25.12.2023.
//

import UIKit

protocol MovieListAssembly {
    func createMovieList() -> UINavigationController
}

final class DefaultMovieListAssembly: MovieListAssembly {
    func createMovieList() -> UINavigationController {
        let networkService: NetworkService = ServiceLocator.shared.resolve()
        let apiService: MovieListApiService = DefaultMovieListApiService(networkService: networkService)
        
        let viewController = MovieListViewController()
        let router: MovieListRouter = DefaultMovieListRouter(root: viewController)
        let presenter = DefaultMovieListPresenter(
            view: viewController,
            router: router,
            apiService: apiService
        )
        
        viewController.inject(presenter: presenter)
        
        return UINavigationController(rootViewController: viewController)
    }
}
