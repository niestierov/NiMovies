//
//  MovieVideoResult.swift
//  NiMovies
//
//  Created by Denys Niestierov on 06.01.2024.
//

import Foundation

struct MovieVideoResult: Codable {
    let results: [MovieVideo]
}

struct MovieVideo: Codable {
    let name: String?
    let key: String?
    let site: String
    let type: String
}
