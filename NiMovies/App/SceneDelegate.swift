//
//  SceneDelegate.swift
//  NiMovies
//
//  Created by Denys Niestierov on 02.01.2024.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // MARK: - Properties -
    
    var window: UIWindow?
    private lazy var appConfiguration: AppConfiguration = DefaultAppConfiguration()
    private lazy var appCoordinator = AppCoordinator(appConfiguration: appConfiguration)
    
    // MARK: - Internal -
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        appCoordinator.start()
        appCoordinator.configureWindow(with: &window, in: windowScene)
    }
}

