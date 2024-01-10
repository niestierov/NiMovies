//
//  MovieApiConstant.swift
//  NiMovies
//
//  Created by Denys Niestierov on 02.01.2024.
//

import Foundation

struct MovieApiConstant {
    static let baseUrl = "https://api.themoviedb.org/3"
    static let basePosterUrl = "https://image.tmdb.org/t/p/w500"
    static let apiSecretKey = "API_KEY_THEMOVIEDB"
    static let apiKey = "api_key"
    
    static func getSecretKey() -> String {
        Bundle.main.object(forInfoDictionaryKey: apiSecretKey) as! String
    }
}
