//
//  AppConfiguration.swift
//  NiMovies
//
//  Created by Denys Niestierov on 02.01.2024.
//

import Foundation

protocol AppConfiguration {
    func configure()
}

final class DefaultAppConfiguration: AppConfiguration {
    func configure() {
        registerServices()
    }
    
    private func registerServices() { }
}
