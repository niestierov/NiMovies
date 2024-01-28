//
//  UINavigationController+Appearance.swift
//  NiMovies
//
//  Created by Denys Niestierov on 28.01.2024.
//

import UIKit

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
