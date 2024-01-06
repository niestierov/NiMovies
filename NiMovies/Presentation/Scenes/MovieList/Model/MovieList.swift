//
//  MovieList.swift
//  NiMovies
//
//  Created by Denys Niestierov on 25.12.2023.
//

import Foundation

struct MovieListResult: Codable {
    let results: [MovieResult]
}

struct MovieResult: Codable {
    let backdropPath: String?
    let genreIds: [Int]
    let id: Int
    let releaseDate: String?
    let title: String
    let voteAverage: Double?
}
