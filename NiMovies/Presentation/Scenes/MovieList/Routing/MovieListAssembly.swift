//
//  MovieListAssembly.swift
//  NiMovies
//
//  Created by Denys Niestierov on 25.12.2023.
//

import UIKit

protocol MovieListAssembly {
    func createMovieList() -> UIViewController
}

final class DefaultMovieListAssembly: MovieListAssembly {
    func createMovieList() -> UIViewController {
        let networkService: NetworkService = ServiceLocator.shared.resolve()
        let apiService: MovieListApiService = DefaultMovieListApiService(networkService: networkService)
        let loadingAnimationView: LoadingAnimationView = LoadingAnimationViewController()
        
        let viewController = MovieListViewController()
        let router: MovieListRouter = DefaultMovieListRouter(root: viewController)
        let presenter = DefaultMovieListPresenter(
            view: viewController,
            router: router,
            apiService: apiService
        )
        
        viewController.inject(
            presenter: presenter,
            loadingAnimationView: loadingAnimationView
        )

        return viewController
    }
}
