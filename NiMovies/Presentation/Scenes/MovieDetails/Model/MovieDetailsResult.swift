//
//  MovieDetailsResult.swift
//  NiMovies
//
//  Created by Denys Niestierov on 06.01.2024.
//

import Foundation

struct MovieDetailsResult: Codable {
    let backdropPath: String?
    let posterPath: String?
    let genres: [MovieDetailsGenres]
    let releaseDate: String?
    let title: String
    let overview: String?
    let voteAverage: Double
    let productionCountries: [MovieDetailsCountry]
}

struct MovieDetailsGenres: Codable {
    let name: String
}

struct MovieDetailsCountry: Codable {
    let name: String
}
