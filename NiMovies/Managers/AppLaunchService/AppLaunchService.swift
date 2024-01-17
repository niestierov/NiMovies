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
    
    private lazy var navigationController: UINavigationController = {
        let controller = UINavigationController()
        controller.setNavigationControllerAppearance()
        return controller
    }()
    
    // MARK: - Init -
    
    init(appConfiguration: AppConfiguration) {
        self.appConfiguration = appConfiguration
    }

    // MARK: - Internal -
    
    func start(in windowScene: UIWindowScene) {
        appConfiguration.configure()
        
        let movieListModule = DefaultMovieListAssembly().createMovieList()
        navigationController.setViewControllers([movieListModule], animated: true)
        
        configureWindow(with: navigationController, in: windowScene)
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
