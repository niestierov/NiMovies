//
//  MoviesGenreList.swift
//  NiMovies
//
//  Created by Denys Niestierov on 26.12.2023.
//

import Foundation

struct MoviesGenreList: Codable {
    let genres: [MovieGenre]
}

struct MovieGenre: Codable {
    let id: Int
    let name: String
}
