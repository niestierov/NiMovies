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

extension UINavigationController {
    func setNavigationControllerAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .defaultBackground

        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.default,
            .font: UIFont.boldSystemFont(ofSize: 19)
        ]
        appearance.buttonAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.clear
        ]

        navigationBar.tintColor = .default
        navigationBar.standardAppearance = appearance
    }
}

