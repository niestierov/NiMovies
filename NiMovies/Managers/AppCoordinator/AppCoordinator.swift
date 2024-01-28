//
//  AppCoordinator.swift
//  NiMovies
//
//  Created by Denys Niestierov on 02.01.2024.
//

import UIKit

final class AppCoordinator {
    
    // MARK: - Properties -
    
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
    
    func start() {
        appConfiguration.configure()
        
        let movieListModule = DefaultMovieListAssembly().createMovieList()
        navigationController.setViewControllers([movieListModule], animated: true)
    }

    func configureWindow(
        with window: inout UIWindow?,
        in windowScene: UIWindowScene
    ) {
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
