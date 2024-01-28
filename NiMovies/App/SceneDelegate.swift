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
    private lazy var appLaunchService = AppLaunchService(appConfiguration: appConfiguration)
    
    // MARK: - Internal -
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        appLaunchService.start(in: windowScene)
    }
}

