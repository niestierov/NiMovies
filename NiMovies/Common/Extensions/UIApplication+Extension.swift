//
//  UIApplication+Extension.swift
//  NiMovies
//
//  Created by Denys Niestierov on 05.01.2024.
//

import UIKit

extension UIApplication {
    static func openAppSettings() {
        if let appSettingsURL = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(appSettingsURL) {
            UIApplication.shared.open(appSettingsURL, options: [:])
        }
    }
}
