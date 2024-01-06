//
//  AppLaunchService.swift
//  NiMovies
//
//  Created by Denys Niestierov on 02.01.2024.
//

import UIKit

final class AppLaunchService {
    
    // MARK: - Properties -
    
    private var window: UIWindow?
    private let appConfiguration: AppConfiguration
    
    // MARK: - Init -
    
    init(appConfiguration: AppConfiguration) {
        self.appConfiguration = appConfiguration
    }

    // MARK: - Internal -
    
    func start(in windowScene: UIWindowScene) {
        appConfiguration.configure()
        
        let movieListModule = DefaultMovieListAssembly().createMovieList()
        configureWindow(with: movieListModule, in: windowScene)
    }

    // MARK: - Private -

    private func configureWindow(
        with navigationController: UINavigationController,
        in windowScene: UIWindowScene
    ) {
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        self.window = window
    }
}
